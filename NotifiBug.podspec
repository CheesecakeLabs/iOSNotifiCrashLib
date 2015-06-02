# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "NotifiBug"
  s.version          = "2.0.0"
  s.summary          = "Library for crashes notification."
  s.description      = <<-DESC
                        Library that sends crashes information to a remote server.
                        DESC
  s.homepage         = "http://www.ckl.io"
  s.license          = 'MIT'
  s.author           = { "Pedro Henrique Prates Peralta" => "pedro@ckl.io" }
  s.source           = { :git => "https://github.com/CheesecakeLabs/iOSNotifiBug.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'NotifiBug' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/*.h'
end
