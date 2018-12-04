Pod::Spec.new do |spec|
  spec.name = "MKToolTip"
  spec.version = "1.0.6"
  spec.summary = "Simple tooltip view written in Swift."
  spec.description = "MKToolTip is a customizable tooltip view written in Swift that can be used as a informative tip."
  spec.homepage = "https://github.com/metinkilicaslan/MKToolTip"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Metin Kilicaslan" => 'metinkilicaslan@gmail.com' }

  spec.ios.deployment_target = "9.0"
  spec.swift_version = "4.2"
  spec.requires_arc = true
  spec.source = { :git => "https://github.com/metinkilicaslan/MKToolTip.git", :tag => "v#{spec.version}"}
  spec.source_files = "MKToolTip/MKToolTip/*.{h,swift}"
end
