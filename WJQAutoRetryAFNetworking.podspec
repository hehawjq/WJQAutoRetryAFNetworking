Pod::Spec.new do |spec|
  spec.name         = "WJQAutoRetryAFNetworking"
  spec.version      ="1.0.0"
  spec.summary      = "Auto retry for AFNetworking."
  spec.homepage     = "https://github.com/hehawjq/WJQAutoRetryAFNetworking"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "hehawjq" => "hehawjq@163.com" }
  spec.source   = { :git => 'https://github.com/hehawjq/WJQAutoRetryAFNetworking.git', :tag => spec.version }
  
  spec.platform     = :ios
  spec.ios.deployment_target = "9.0"
  
  spec.ios.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER' => 'com.wjq.WJQAutoRetryAFNetworking' }

  spec.source_files  = "WJQAutoRetryAFNetworking", "*.{h,m}"

  spec.dependency "AFNetworking", "~> 4.0.1"

end
