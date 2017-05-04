

Pod::Spec.new do |s|
  s.name         = 'ZJCImagePickerController'
  s.version      = '0.0.1'
  s.summary      = 'A TZImagePickerController for iOS.'

  s.homepage     = "http://blog.csdn.net/codingfire/article/details/52470802"
  


  s.license      = 'MIT'
  

  s.author       = { "zjc372948336" => "372948336@qq.com" }
 

  s.source       = { :git => "https://github.com/zjc372948336/Test.git", :tag => "0.0.1" }


  s.ios.deployment_target = '7.0'

  s.source_files  = "TZImagePickerController/*"
  s.exclude_files = "Classes/Exclude"


end
