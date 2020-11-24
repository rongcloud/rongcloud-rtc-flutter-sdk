require 'pathname'
current_path = Pathname.new(__FILE__).realpath

config = File.expand_path(File.join('..', '..' ,'version.config'), current_path)

rongcloud_rtc_plugin_version = 'Unknown'
im_sdk_version = 'Unknown'
rtc_sdk_version = 'Unknown'

File.foreach(config) do |line|
    matches = line.match(/rongcloud_rtc_plugin_version\=(.*)/)
    if matches
      rongcloud_rtc_plugin_version = matches[1].split("#")[0].strip
    end
    matches = line.match(/im_sdk_version\=(.*)/)
    if matches
      im_sdk_version = matches[1].split("#")[0].strip
    end
    matches = line.match(/rtc_sdk_version\=(.*)/)
    if matches
      rtc_sdk_version = matches[1].split("#")[0].strip
    end
end

if rongcloud_rtc_plugin_version == 'Unknown'
    raise "You need to config rongcloud_rtc_plugin_version in version.config!!"
end
if im_sdk_version == 'Unknown'
    raise "You need to config im_sdk_version in version.config!!"
end
if rtc_sdk_version == 'Unknown'
    raise "You need to config rtc_sdk_version in version.config!!"
end

Pod::Spec.new do |s|
  s.name             = 'rongcloud_rtc_plugin'
  s.version          = rongcloud_rtc_plugin_version
  s.summary          = 'RongCloud RTC Flutter Plugin.'
  s.homepage         = 'https://www.rongcloud.cn/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'GP-Moon' => 'pmgd19881226@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  
  s.dependency 'Libyuv', '1703'
  
  s.dependency 'RongCloudIM/IMLib', im_sdk_version
  s.dependency 'RongRTCLib', rtc_sdk_version
  
  s.ios.deployment_target = '8.0'
  
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64'
  }
end

