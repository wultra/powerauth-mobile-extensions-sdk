/**
 * Copyright 2021 Wultra s.r.o.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// PA2_SHARED_SOURCE PowerAuth2ForWatch .

// Do not edit this file in PowerAuth2ForWatch project. Use version in
// PowerAuht2ForExtensions and the shared file will be copied in the next
// copy-shared-sources.sh run.

#import <PowerAuth2ForExtensions/PowerAuthMacros.h>

#if PA2_HAS_LACONTEXT == 1
#import <LocalAuthentication/LocalAuthentication.h>
#endif

/** Class representing a multi-factor authentication object.
 */
@interface PowerAuthAuthentication : NSObject

/// No longer available. Use static methods instead.
- (nonnull instancetype) init NS_UNAVAILABLE;

/// Indicates if a possession factor should be used.
@property (nonatomic, assign, readonly) BOOL usePossession;

/// Indicates if a biometry factor should be used.
@property (nonatomic, assign, readonly) BOOL useBiometry;

/// Contains password in case that knowledge factor is required in authentication.
@property (nonatomic, strong, readonly, nullable) NSString * password;

/// Specifies the text displayed on Touch or Face ID prompt in case biometry is required to obtain data.
///
/// Use this value to give user a hint on what is biometric authentication used for in this specific authentication.
/// For example, include a name of the account user uses to log in.
@property (nonatomic, strong, nullable, readonly) NSString *biometryPrompt;

/// Indicates if a biometry factor should be used. If both biometryContext and biometryPrompt properties are set, then the context will be applied.
@property (nonatomic, strong, nullable, readonly) LAContext *biometryContext API_UNAVAILABLE(watchos, tvos);

/// If 'usePossession' is set to YES, this value may specify possession key data. If no custom data is specified, default possession key is used.
@property (nonatomic, strong, nullable, readonly) NSData *overridenPossessionKey;

/// If 'useBiometry' is set to YES, this value may specify biometry key data. If no custom data is specified, default biometry key is used for the PowerAuthSDK instance, based on the keychain configuration and SDK instance configuration.
@property (nonatomic, strong, nullable, readonly) NSData *overridenBiometryKey;

@end

@interface PowerAuthAuthentication (EasyAccessors)

// Signing, Possession only

/// Create a new instance of authentication object preconfigured for signing with a possession factor.
/// @return Instance of PowerAuthAuthentication configured for signing with a possession factor.
+ (nonnull PowerAuthAuthentication *) possession;

/// Create a new instance of authentication object preconfigured for signing with a possession factor, with using custom possession key.
/// @param customPossessionKey Custom key used for possession factor.
/// @return Instance of PowerAuthAuthentication configured for signing with a possession factor with using custom possession key.
+ (nonnull PowerAuthAuthentication *) possessionWithCustomPossessionKey:(nonnull NSData*)customPossessionKey
                        NS_SWIFT_NAME(possession(customPossessionKey:));

// Signing, Possession + Biometry

/// Create a new instance of authentication object preconfigured for signing with a possession and biometry factors.
/// @return Instance of PowerAuthAuthentication configured for signing with a possession and biometry factors.
+ (nonnull PowerAuthAuthentication *) possessionWithBiometry;


/// Returns a new instance of authentication object preconfigured for a combination of possession and biometry factors.
/// @param customBiometryKey Custom key used for biometry factor.
/// @param customPossessionKey Custom key used for possession factor.
/// @return New instance of authentication object configured for signing with a possession and biometry factors, with custom biometry and possession keys.
+ (nonnull PowerAuthAuthentication *) possessionWithBiometryWithCustomBiometryKey:(nullable NSData*)customBiometryKey
                                                              customPossessionKey:(nullable NSData*)customPossessionKey
                        NS_SWIFT_NAME(possessionWithBiometry(customBiometryKey:customPossessionKey:));

/// Create a new instance of authentication object preconfigured for signign with combination of possession and biometry factors and with prompt,
/// displayed in the system biometric authentication dialog.
/// @param biometryPrompt Prompt displayed in the system biometric authentication dialog.
/// @return New instance of authentication object configured for signing with a possession and biometry factors, with custom prompt displayed in the system biometric authentication dialog.
+ (nonnull PowerAuthAuthentication *) possessionWithBiometryPrompt:(nonnull NSString*)biometryPrompt
                        NS_SWIFT_NAME(possessionWithBiometry(prompt:));

/// Create a new instance of authentication object preconfigured for signign with combination of possession and biometry factors and with prompt,
/// displayed in the system biometric authentication dialog. This variant of function allows you also use the custom possession key for the possession factor.
/// @param biometryPrompt Prompt displayed in the system biometric authentication dialog.
/// @return New instance of authentication object configured for signing with a custom possession key and biometry factors, with custom prompt displayed in the system biometric authentication dialog.
+ (nonnull PowerAuthAuthentication *) possessionWithBiometryPrompt:(nonnull NSString*)biometryPrompt
                                               customPossessionKey:(nonnull NSData*)customPossessionKey
                        NS_SWIFT_NAME(possessionWithBiometry(prompt:customPossessionKey:));

/// Create a new instance of authentication object preconfigured for signing with combination of possession and biometry factors and with local
/// authentication context. The context allows you to better customize the system biometric authentication dialog.
/// @param context LAContext for the system biometric authentication dialog.
/// @return New instance of authentication object configured for signing with a possession and biometry factors, with local authentication context.
+ (nonnull PowerAuthAuthentication *) possessionWithBiometryContext:(nonnull LAContext*)context
                        NS_SWIFT_NAME(possessionWithBiometry(context:))
                        API_UNAVAILABLE(watchos, tvos);

/// Create a new instance of authentication object preconfigured for signing with combination of possession and biometry factors and with local
/// authentication context. The context allows you to better customize the system biometric authentication dialog. This variant of function allows
/// you also use the custom possession key for the possession factor.
/// @param context LAContext for the system biometric authentication dialog.
/// @return New instance of authentication object configured for signing with a custom possession key and biometry factor, with local authentication context.
+ (nonnull PowerAuthAuthentication *) possessionWithBiometryContext:(nonnull LAContext*)context
                                                customPossessionKey:(nonnull NSData*)customPossessionKey
                        NS_SWIFT_NAME(possessionWithBiometry(context:customPossessionKey:))
                        API_UNAVAILABLE(watchos, tvos);


// Signing, Possession + Knowledge

/// Create a new instance of authentication object preconfigured for combination of possesion and knowledge factors.
/// @param password Password used for the knowledge factor.
/// @return New instance of authentication object configured for signing with a possession and knowledge factors.
+ (nonnull PowerAuthAuthentication *) possessionWithPassword:(nonnull NSString*)password
                        NS_SWIFT_NAME(possessionWithPassword(password:));

/// Create a new instance of authentication object preconfigured for combination of possesion and knowledge factors, with using custom possession key.
/// @param password Password used for the knowledge factor.
/// @param customPossessionKey Custom key used for possession factor.
/// @return New instnace of authentication object configured for signing with custom possession key and knowledge factor.
+ (nonnull PowerAuthAuthentication *) possessionWithPassword:(nonnull NSString*)password
                                         customPossessionKey:(nonnull NSData*)customPossessionKey
                        NS_SWIFT_NAME(possessionWithPassword(password:customPossessionKey:));

@end
