current_version = 'Unknown'

yaml = File.expand_path(File.join('..', '..' ,'pubspec.yaml'), __FILE__)

File.foreach(yaml) do |line|
    matches = line.match(/version\:(.*)/)
    if matches
      current_version = matches[1].split("#")[0].strip
    end
end

if current_version == 'Unknown'
    raise "No version info in pubspec.yaml!!"
end

im_sdk_version = 'Unknown'
rtc_sdk_version = 'Unknown'

config = File.expand_path(File.join('..', '..', 'version.config'), __FILE__)

File.foreach(config) do |line|
    matches = line.match(/im_sdk_version\=(.*)/)
    if matches
      im_sdk_version = matches[1].split("#")[0].strip
    end
    matches = line.match(/rtc_sdk_version\=(.*)/)
    if matches
      rtc_sdk_version = matches[1].split("#")[0].strip
    end
end

if im_sdk_version == 'Unknown'
    raise "You need to config im_sdk_version in version.config!!"
end
if rtc_sdk_version == 'Unknown'
    raise "You need to config rtc_sdk_version in version.config!!"
end

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
  s.dependency 'RongCloudIM/IMLib', im_sdk_version
  s.dependency 'RongCloudRTC/RongRTCLib', rtc_sdk_version

  s.static_framework = true
  
  s.ios.deployment_target = '8.0'
  
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64'
  }
end

