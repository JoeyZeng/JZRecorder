#
# Be sure to run `pod lib lint JZRecorder.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "JZRecorder"
  s.version          = "1.0.0"
  s.summary          = "Record an audio and store to file simply."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                        JZRecorder简单封装了IOS系统API，让使用更加方便。支持保存录音到本地，返回本地路径。录音格式采用双声道ACC文件，生成的录音文件体积小，无需压缩，可以直接上传到Server。
                       DESC

  s.homepage         = "https://github.com/JoeyZeng/JZRecorder"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "ZengJoey" => "zzying77@qq.com" }
  s.source           = { :git => "https://github.com/JoeyZeng/JZRecorder.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'JZRecorder' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
