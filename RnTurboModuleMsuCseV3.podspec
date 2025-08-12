require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RnTurboModuleMsuCseV3"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://github.com/bogdan-boksan-ananas/rn-turbo-module-msu-cse-v3.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.private_header_files = "ios/**/*.h"
  
  # Enable Swift support
  s.swift_version = "5.0"
  
  # Link Security framework for RSA encryption
  s.frameworks = "Security"


  install_modules_dependencies(s)
end
