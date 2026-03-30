#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint courier_dart_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'courier_dart_sdk'
  s.version          = '0.2.0'
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
  s.dependency 'CourierCore', '1.0.10'
  s.dependency 'CourierMQTT', '1.0.10'
  s.dependency 'CourierMQTTChuck', '1.0.10'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '6.0'
end
