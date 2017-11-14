Pod::Spec.new do |s|
  s.name             = 'Pellicola'
  s.version          = '0.1.0'
  s.summary          = 'A replacement for UIImagePickerController with multiselection support.'

  s.description      = <<-DESC
  A replacement for UIImagePickerController with multiselection support.
  
  Features:
    - Specify a maximum number of items to select
    - Objective-C compatibility
                       DESC

  s.homepage         = 'https://github.com/francybiga/Pellicola'
  s.license          = 'Apache License, Version 2.0'  
  s.author           = { 'francybiga' => 'francesco.bigagnoli@scmitaly.it' }
  s.source           = { :git => 'https://github.com/Subito-it/Pellicola.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Pellicola/Classes/**/*'
  s.resources = ['Pellicola/Classes/**.xib', 'Pellicola/Resources/*']

  
end
