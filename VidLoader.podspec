Pod::Spec.new do |spec|
  spec.name         = "VidLoader"
  spec.version      = "1.2.0"
  spec.summary      = "HLS video streaming download library"
  spec.description  = "A library used to download HLS video streaming with AES-128 encryption"
  spec.homepage     = "https://github.com/Cyklet/VidLoader"
  spec.license      = { type: 'MIT', file: 'LICENSE' }
  spec.authors      = { "Petre Plotnic" => "www.linkedin.com/in/petre-plotnic" }
  spec.platform     = :ios, "12.0"
  spec.swift_version = "4.2"
  spec.requires_arc = true
  spec.source = { :git => "https://github.com/Cyklet/VidLoader.git", :tag => "#{spec.version}"}
  spec.source_files = "VidLoader/VidLoader/**/*.{h,swift}"
end
