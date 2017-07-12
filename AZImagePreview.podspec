Pod::Spec.new do |s|
  s.name         = "AZImagePreview"
  s.version      = "1.0.0"
  s.summary      = "iOS Framework that makes it easy to preview images on any UIImageView."
  s.homepage     = "https://github.com/Minitour/AZImagePreview"
  s.license      = "MIT"
  s.author       = { "Antonio Zaitoun" => "tony.z.1711@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/Minitour/AZImagePreview.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/**/*.{swift}"
end
