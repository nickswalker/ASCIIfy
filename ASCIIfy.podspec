Pod::Spec.new do |s|
  s.name             = "ASCIIfy"
  s.version          = "0.1.0"
  s.summary          = "UIImage/NSImage to ASCII art"
  s.description      = <<-DESC
Includes UIImage and NSImage extensions. String and image output available.
                       DESC

  s.homepage         = "https://github.com/nickswalker/ASCIIfy"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Nick Walker" => "nick@nickwalker.us" }
  s.source           = { :git => "https://github.com/nickswalker/ASCIIfy.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'ASCIIfy' => ['Pod/Assets/*.png']
  }
  s.frameworks = 'UIKit'
end
