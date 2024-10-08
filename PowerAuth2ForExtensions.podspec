Pod::Spec.new do |s|
    # General information
    s.cocoapods_version = '>= 1.10'
    s.name              = 'PowerAuth2ForExtensions'
    s.version           = '1.9.0'
    s.summary           = 'PowerAuth Mobile SDK for iOS and tvOS App Extensions'
    s.homepage          = 'https://github.com/wultra/powerauth-mobile-sdk'
    s.social_media_url  = 'https://twitter.com/wultra'
    s.documentation_url = 'https://developers.wultra.com/products/mobile-security-suite/develop/powerauth-mobile-sdk/PowerAuth-SDK-for-iOS-Extensions'
    s.author            = { 
      'Wultra s.r.o.' => 'support@wultra.com'
    }
    s.license = { 
        :type => 'Apache License, Version 2.0', 
        :file => 'LICENSE' 
    }
        
    # Source files
    s.source = { 
        :git => 'https://github.com/wultra/powerauth-mobile-extensions-sdk.git',
        :tag => "#{s.version}"
    }
    
    # Library build
    s.ios.deployment_target  = '12.0'
    s.tvos.deployment_target = '12.0'
    
    s.prepare_command = <<-CMD
        ./scripts/ios-build-extensions.sh --out-dir Build/PowerAuth2ForExtensions extensions --optional-tvos
    CMD
    
    # Produced files
    s.vendored_frameworks   = 'Build/PowerAuth2ForExtensions/PowerAuth2ForExtensions.xcframework'
    
end