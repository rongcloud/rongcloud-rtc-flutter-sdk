current_version = ENV['CURRENT_VERSION']
im_sdk_version = ENV['IM_SDK_VERSION']
rtc_sdk_version = ENV['RTC_SDK_VERSION']

Pod::Spec.new do |s|
  s.name             = 'rongcloud_rtc_plugin'
  s.version          = current_version
  s.summary          = 'RongCloud RTC Flutter Plugin.'
  s.homepage         = 'https://www.rongcloud.cn/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'GP-Moon' => 'pmgd19881226@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  
  s.dependency 'Libyuv', '1703'
  
#  local = ENV['USE_LOCAL_SDK']
#  if local and local == 'true'
#    im_framework = '../../ios-imsdk/imlib/bin/RongIMLib.framework'
#    rtc_framework = '../../ios-rtcsdk/RongRTCLib/bin/RongRTCLib.framework'
#    s.vendored_frameworks = im_framework, rtc_framework
#    s.frameworks = "AssetsLibrary","VideoToolbox", "GLKit", "MapKit", "ImageIO", "CoreLocation", "SystemConfiguration", "QuartzCore", "OpenGLES", "CoreVideo", "CoreTelephony", "CoreMedia", "CoreAudio", "CFNetwork", "AudioToolbox", "AVFoundation", "UIKit", "CoreGraphics"
#    s.libraries = "c++","z","sqlite3","bz2"
#  else
    s.dependency 'RongCloudIM/IMLib', im_sdk_version
    s.dependency 'RongRTCLib', rtc_sdk_version
#  end

  s.static_framework = true
  
  s.ios.deployment_target = '8.0'
  
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64'
  }
end

