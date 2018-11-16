Pod::Spec.new do |s|

  s.name     = 'RHScan'
  s.version  = '1.0.2'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = '实现二维码扫描功能，含各种UI、手势放大缩小镜头、仿微信扫码放大。'
  s.homepage = 'https://github.com/huangkunhe/RHScan'
  s.author   = { 'huangkunhe' => 'river_hkh@163.com' }
  s.source           = { :git => 'https://github.com/huangkunhe/RHScan.git', :tag => s.version }
  s.platform = :ios , '8.0'
  s.source_files = 'RHScan/Scan/*.{h,m}'
  s.resources = "RHScan/Scan/*.png"
  s.framework = 'UIKit', 'Foundation','AVFoundation'
  s.requires_arc = true  
  
end
