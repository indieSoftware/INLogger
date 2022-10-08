Pod::Spec.new do |spec| 
  spec.name         = "INLogger"
  spec.version = "1.0.0" # auto-generated
  spec.swift_versions = ['5.5.2'] # auto-generated
  spec.summary      = "A customizing logger in Swift."
  spec.homepage     = "https://github.com/indieSoftware/INLogger"
  spec.author       = { "Sven Korset" => "sven.korset@indie-software.com" }
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.ios.deployment_target = "16.0"
  spec.source       = { :git => "https://github.com/indieSoftware/INLogger.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/INLogger/**/*.{swift}"
  spec.module_name = 'INLogger'
  spec.dependency 'INCommons'
end
