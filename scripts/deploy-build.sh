#!/bin/bash
###############################################################################
# Include common functions...
# -----------------------------------------------------------------------------
TOP=$(dirname $0)
source "${TOP}/common-functions.sh"
source "${TOP}/config-apple-ext.sh"
SRC_ROOT="`( cd \"$TOP/..\" && pwd )`"

# -----------------------------------------------------------------------------
# USAGE prints help and exits the script with error code from provided parameter
# Parameters:
#   $1   - error code to be used as return code from the script
# -----------------------------------------------------------------------------
function USAGE
{
    echo ""
    echo "Usage:  $CMD  [options] version"
    echo ""
    echo "  version             is version to be published to repositories"
    echo "                      Only X.Y.Z format is accepted"
    echo ""
    echo "options are:"
    echo "    -v0               turn off all prints to stdout"
    echo "    -v1               print only basic log about build progress"
    echo "    -v2               print full build log with rich debug info"
    echo "    -h | --help       print this help information"
    echo ""
    echo "dangerous options:"
    echo "    --any-branch      allow deployment from any git branch"
    echo "                      This version will not be merged to master"
    echo ""
    echo "    --skip-tag        skip version creation and tagging"
    echo "                      This is useful when publishing fails and"
    echo "                      version files are already pushed in repo."
    echo ""
    echo "    --create-tag      prepares versioning files only, no deploy"
    echo "                      This is useful when you need to prepare"
    echo "                      versioning files only, without pushing"
    echo "                      changes to remote repository"
    echo ""
    exit $1
}

###############################################################################
# Config
PODSPEC_EXT="PowerAuth2ForExtensions.podspec"
PODSPEC_WOS="PowerAuth2ForWatch.podspec"
INFO_PLIST_EXT="Sources/PowerAuth2ForExtensions/Info.plist"
INFO_PLIST_WOS="Sources/PowerAuth2ForWatch/Info.plist"

MASTER_BRANCH="main"
DEV_BRANCH="develop"
# Runtime global vars
GIT_VALIDATE_DEVELOPMENT_BRANCH=1
GIT_SKIP_TAGS=0
GIT_ONLY_TAGS=0
STANDARD_BRANCH=0
SCRIPT_VERBOSE=
POD_VERBOSE=

# -----------------------------------------------------------------------------
# Validate whether git branch is 'develop'
# -----------------------------------------------------------------------------
function VALIDATE_GIT_STATUS
{
    LOG "----- Validating git status..."
    PUSH_DIR "${SRC_ROOT}"
    ####
    local GIT_CURRENT_CHANGES=`git status -s`
    if [ ! -z "$GIT_CURRENT_CHANGES" ]; then
        FAILURE "Git status must be clean."
    fi

    local GIT_CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
    if [ x$GIT_VALIDATE_DEVELOPMENT_BRANCH == x1 ]; then
        if [ "$GIT_CURRENT_BRANCH" != ${DEV_BRANCH} ]; then
            FAILURE "You have to be at '${DEV_BRANCH}' git branch."
        fi
        STANDARD_BRANCH=1
    else
        WARNING "Going to publish '${VERSION}' from non-standard branch '${GIT_CURRENT_BRANCH}'"
        STANDARD_BRANCH=0
    fi

    git fetch origin
    local CURRENT_TAGS=(`git tag -l`)
    local TAG   
    for TAG in ${CURRENT_TAGS[@]}; do
        if [ "$TAG" == ${VERSION} ]; then 
            if [ x$GIT_SKIP_TAGS == x0 ]; then
                FAILURE "Version '${VERSION}' is already published."
            else
                WARNING "Version '${VERSION}' is already published."
            fi
        fi 
    done
    ####
    POP_DIR
}

# -----------------------------------------------------------------------------
# Prepares all versioning files and commit & tag changes
# -----------------------------------------------------------------------------
function PREPARE_VERSIONING_FILES
{
    PUSH_DIR "${SRC_ROOT}"
    ####

    if [[ $BUILD_TARGET_PLATFORM == 'extensions' ]]; then
        # PowerAuth2ForExtensions
        LOG "----- Generating ${PODSPEC_EXT}..."
        sed -e "s/%DEPLOY_VERSION%/$VERSION/g" "${TOP}/templates/${PODSPEC_EXT}" > "$SRC_ROOT/${PODSPEC_EXT}"
        LOG "----- Generating ${INFO_PLIST_EXT}..."
        sed -e "s/%DEPLOY_VERSION%/$VERSION/g" "${TOP}/templates/PA2Ext-Info.plist" > "$SRC_ROOT/${INFO_PLIST_EXT}"
        git add ${PODSPEC_EXT} ${INFO_PLIST_EXT}
    else
        # PowerAuth2ForWatch
        LOG "----- Generating ${PODSPEC_WOS}..."
        sed -e "s/%DEPLOY_VERSION%/$VERSION/g" "${TOP}/templates/${PODSPEC_WOS}" > "$SRC_ROOT/${PODSPEC_WOS}"
        LOG "----- Generating ${INFO_PLIST_WOS}..."
        sed -e "s/%DEPLOY_VERSION%/$VERSION/g" "${TOP}/templates/PA2Watch-Info.plist" > "$SRC_ROOT/${INFO_PLIST_WOS}"
        git add ${PODSPEC_WOS} ${INFO_PLIST_WOS}
    fi
    
    local TAG_MESSAGE="Version $VERSION"

    LOG "----- Commiting versioning files..."
    git commit -m "Deployment: Update versioning file[s] to ${VERSION}"
    
    LOG "----- Tagging version ${VERSION}..."
    git tag -a ${VERSION} -m "${TAG_MESSAGE}"
    ####
    POP_DIR
}

# -----------------------------------------------------------------------------
# Prepares local files which contains version string, then commits those
# files with appropriate tag and pushes everything to the remote git repository
# -----------------------------------------------------------------------------
function PUSH_VERSIONING_FILES
{
    if [ x$GIT_SKIP_TAGS == x1 ]; then
        WARNING "Skipping versioning files creation."
        return
    fi
    
    PREPARE_VERSIONING_FILES
    
    if [ x$GIT_ONLY_TAGS == x1 ]; then
        LOG "All versioning files has been created. Check your local git repository for details."
        LOG "Exiting process as requested."
        exit 0
    fi
    
    PUSH_DIR "${SRC_ROOT}"
    ###
    LOG "----- Pushing changes..."
    git push --follow-tags 
    ####
    POP_DIR
}

# -----------------------------------------------------------------------------
# Validate build before library publishing
# -----------------------------------------------------------------------------
function VALIDATE_BEFORE_PUBLISH
{
    "${TOP}/test-build.sh" $SCRIPT_VERBOSE lint
}

# -----------------------------------------------------------------------------
# Deploys recently tagged version to repositories
# -----------------------------------------------------------------------------
function DEPLOY_BUILD
{
    PUSH_DIR "${SRC_ROOT}"
    ####
    
    if [[ $BUILD_TARGET_PLATFORM == 'extensions' ]]; then
        LOG "----- Publishing ${PODSPEC_EXT} to CocoaPods..."
        pod $POD_VERBOSE trunk push ${PODSPEC_EXT}
    else
        LOG "----- Publishing ${PODSPEC_WOS} to CocoaPods..."
        pod $POD_VERBOSE trunk push ${PODSPEC_WOS}
    fi
    
    ####
    POP_DIR
}

# -----------------------------------------------------------------------------
# Merges recent changes to the 'master' branch
# -----------------------------------------------------------------------------
function MERGE_TO_MASTER
{
    if [ x$STANDARD_BRANCH == x0 ]; then
        LOG "----- OK, but not merged to '${MASTER_BRANCH}'"
    else
        PUSH_DIR "${SRC_ROOT}"
        ####
        LOG "----- Merging to '${MASTER_BRANCH}'..."
        git fetch origin
        git checkout ${MASTER_BRANCH}
        git rebase origin/${DEV_BRANCH}
        git push
        git checkout ${DEV_BRANCH}
        ####
        POP_DIR
        LOG "----- OK"
    fi
    exit 0
}


###############################################################################
# Script's main execution starts here...
# -----------------------------------------------------------------------------
while [[ $# -gt 0 ]]
do
    opt="$1"
    case "$opt" in
        -h | --help)
            USAGE 0
            ;;
        -v*)
            SET_VERBOSE_LEVEL_FROM_SWITCH $opt
            SCRIPT_VERBOSE=$opt
            POD_VERBOSE=$VERBOSE_VARIANT3
            ;;
        --any-branch)
            GIT_VALIDATE_DEVELOPMENT_BRANCH=0
            ;;
        --skip-tag)
            GIT_SKIP_TAGS=1
            ;;
        --create-tag)
            GIT_ONLY_TAGS=1
            ;;
        *)
            VALIDATE_AND_SET_VERSION_STRING $opt
            ;;
    esac
    shift
done
#
# Mandatory parameters validation
#
if [ -z "$VERSION" ]; then
    FAILURE "You have to provide version string."
fi
#
# Main job starts here...
#
case "$TOP" in
    *\ *)
        # Yes, this is lame, but better exit now than publish broken builds
        FAILURE "Current path contains space character. This script has not been tested for such case."
        ;;
esac
VALIDATE_GIT_STATUS
VALIDATE_BEFORE_PUBLISH
PUSH_VERSIONING_FILES
DEPLOY_BUILD
MERGE_TO_MASTER

