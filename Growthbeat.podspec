Pod::Spec.new do |s|
  s.name = "Growthbeat"
  s.version = "2.0.3"
  s.summary = "Growthbeat SDK for iOS"
  s.description = <<-DESC
  Growthbeat is growth hack platform for smart devices.
  https://growthbeat.com/
  DESC
  s.homepage = "https://github.com/growthbeat/growthbeat-ios"
  s.license = {:type => "Apache License, Version 2.0", :file => "LICENSE"}
  s.author = {"SIROK, Inc." => "support@growthbeat.com"}

  s.source = {:git => "https://github.com/growthbeat/growthbeat-ios.git", :tag => "#{s.version}"}
  s.source_files = [
      "Growthbeat/**/*.h",
      "Growthbeat/**/*.m"
  ]
  s.frameworks = [
      "AdSupport",
      "SafariServices",
      "SystemConfiguration",
      "CoreGraphics",
      "CFNetwork",
      "UIKit",
      "Foundation"
  ]
  s.vendored_frameworks = "Growthbeat.framework"
  s.preserve_paths = "README.*"

  s.platform = :ios, "8.0"
  s.requires_arc = true
end
