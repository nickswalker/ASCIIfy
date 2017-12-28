Pod::Spec.new do |s|
  s.name             = "ASCIIfy"
  s.version          = "1.0.0"
  s.summary          = "UIImage/NSImage to ASCII art"
  s.description      = <<-DESC
Includes UIImage and NSImage extensions. String and image output available.
                       DESC

  s.homepage         = "https://github.com/nickswalker/ASCIIfy"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Nick Walker" => "nick@nickwalker.us" }
  s.source           = { :git => "https://github.com/nickswalker/ASCIIfy.git", :tag => s.version.to_s }
  s.dependency "KDTree"  
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11'

  s.swift_version = '4.1'
  s.source_files = 'Pod/Classes/**/*'

end
