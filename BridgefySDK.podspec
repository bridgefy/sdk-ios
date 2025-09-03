Pod::Spec.new do |s|
  s.name             = 'BridgefySDK'
  s.version          = '1.2.4'
  s.summary          = 'Make your mobile app work without the Internet.'
  s.description      = 'The Bridgefy SDK is as versatile as you need it to be. Hundreds of millions of people lose access to the Internet every day, but they still need to use mobile apps. Open your mobile app to immense new markets that are waiting to use gaming, messaging, education, and payments apps, but can’t because of lack of an Internet connection.'
  s.homepage         = 'https://bridgefy.me/sdk/'
  s.license          = { :type => 'Commercial', :file => 'LICENSE.md' }
  s.author           = { 'Bridgefy' => 'contact@bridgefy.me' }
  s.platform         = :ios, '13.0'
  s.source           = { :git => 'https://github.com/bridgefy/sdk-ios.git', :tag => s.version.to_s }
  s.xcconfig     =  { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/BridgefySDK/"' }
  s.requires_arc = true
  s.source_files = 'BridgefySDK.xcframework/ios-arm64/BridgefySDK.framework/Headers/*.{h}'
  s.vendored_frameworks = 'BridgefySDK.xcframework'
end
