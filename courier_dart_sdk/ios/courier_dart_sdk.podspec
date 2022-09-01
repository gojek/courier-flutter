#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint courier_dart_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'courier_dart_sdk'
  s.version          = '0.0.1'
  s.summary          = 'Flutter SDK for Courier'
  s.description      = <<-DESC
Flutter SDK for Courier
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'CourierCore', '0.0.8'
  s.dependency 'CourierMQTT', '0.0.8'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
