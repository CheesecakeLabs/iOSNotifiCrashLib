Pod::Spec.new do |s|
  s.name             = "NotifiCrash"
  s.version          = "1.2"
  s.summary          = "Library for crashes notification."
  s.description      = <<-DESC
                        Library that sends crashes information to a remote server.
                        DESC
  s.homepage         = "http://www.ckl.io"
  s.license          = 'MIT'
  s.author           = { "Pedro Henrique Prates Peralta" => "developer@ckl.io" }
  s.source           = { :git => "https://github.com/CheesecakeLabs/iOSNotifiCrashLib.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.public_header_files = 'Pod/Classes/*.h'
end
