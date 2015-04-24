Pod::Spec.new do |s|
  s.name         = "LightningClient"
  s.version      = "0.0.1"
  s.summary      = ""
  s.homepage     = "http://LightningSDK.net"
  s.license      = 'mit'
  s.author       = "Dan B"
  s.source       = { :git => "https://github.com/macdabby/LightningiOSClient.git" }
  s.platform     = :ios, '6.1'
  s.source_files = 'Classes/*.{h,m,c}'
  s.resources = 'Nibs/*.{png,nib,xib}', 'Images/*.png'
  #s.frameworks   = ''
  s.requires_arc = true
end

