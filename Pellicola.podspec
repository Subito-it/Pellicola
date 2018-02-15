Pod::Spec.new do |s|
  s.name             = 'Pellicola'
  s.version          = '0.2.0'
  s.summary          = 'A replacement for UIImagePickerController with multiple selection'
  s.description      = 'A replacement for UIImagePickerController with multiple selection support written in Swift.'
  s.homepage         = 'https://github.com/Subito-it/Pellicola'
  s.license          = 'Apache License, Version 2.0'  
  s.author           = 'Subito'
  s.source           = { :git => 'https://github.com/Subito-it/Pellicola.git', :tag => s.version.to_s }

  s.platform = :ios
  s.ios.deployment_target = '9.0'
  s.swift_version = '4.0'

  s.requires_arc = true

  s.source_files = 'Pellicola/Classes/**/*'
  s.resources = ['Pellicola/Classes/**.xib', 'Pellicola/Resources/*']

  
end
