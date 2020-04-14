Pod::Spec.new do |s|

  s.name         = "RXDemo"
  s.version      = "1.0.0"
  s.summary      = "自定义分段标签滚动视图-Swift"
  #s.description  = ""
    
  s.homepage     = "https://github.com/splsylp/RXDemo"
  s.license      = "MIT"
  s.author       = { "Tony" => "961505161@qq.com" }

  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/splsylp/RXDemo.git", :tag => "0.0.1" }

  s.source_files = "lib/IMHeaders/*"
  
  s.vendored_libraries = "lib/IMLibs/libAddressBook.a", "lib/IMLibs/libDialing.a", "lib/IMLibs/libUserCenter.a", "lib/IMLibs/libYHCCustonUI.a", "lib/IMLibs/libYHCECSDKManager.a", "lib/IMLibs/libYHCGeneral.a", "lib/IMLibs/libYHCManager.a", "lib/IMLibs/libYHCServerManeger.a", "lib/IMLibs/libYHCSettingManager.a"
 
  #s.resources    = "lib/IMResource/**/*" 
  
  s.resources = ['lib/IMResource/Bundle/*.bundle', 'lib/IMResource/CustonUI/*', 'lib/IMResource/Images/*.png', 'lib/IMResource/Others/**/*', 'lib/IMResource/Plist/*.plist', 'lib/IMResource/Xib/*.xib']

  s.requires_arc = true

end
