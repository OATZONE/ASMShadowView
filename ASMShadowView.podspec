

Pod::Spec.new do |spec|


spec.name         = "ASMShadowView"
spec.version      = "1.4"
spec.summary      = "ASMShadowView"
spec.description  = "ASMShadowView version 1.4"

spec.homepage     = "https://github.com/OATZONE/ASMShadowView"
spec.license        = { :type => 'MIT', :file => 'LICENSE' }
spec.author             = { "OATZONE" => "oatzone1@hotmail.com" }
spec.platform     = :ios, "11.0"
spec.ios.deployment_target = "11.0"
spec.swift_version         = "5.0.0"


spec.source       = { :git => "https://github.com/OATZONE/ASMShadowView.git", :tag => "#{spec.version}" }

spec.source_files  = "ASMShadowView", "ASMShadowView/**/*.{h,m,swift}"
spec.exclude_files = "ASMShadowView/Exclude"
#spec.public_header_files = 'Classes/**/*.h'
spec.framework = "UIKit"

end
