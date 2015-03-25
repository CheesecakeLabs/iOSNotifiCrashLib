Pod::Spec.new do |s|
  s.name             = "CheeseBug"
  s.version          = "1.1.1"
  s.summary          = "Library for crashes notification."
  s.description      = <<-DESC
                        Library that sends crashes information to a remote server.
                        DESC
  s.homepage         = "http://ckl.io"
  s.license          = 'MIT'
  s.author           = { "Pedro Henrique Prates Peralta" => "pedro@ckl.io" }
  s.source           = { :git => "https://github.com/CheesecakeLabs/cheese-crash-ios.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.public_header_files = 'Pod/Classes/*.h'

  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 2.0'
end
