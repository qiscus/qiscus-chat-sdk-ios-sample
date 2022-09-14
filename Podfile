# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'Example' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Example
  pod 'QiscusCore'

    # 3rd party
  pod 'SDWebImage', '5.12.0'
  pod 'SimpleImageViewer', :git => 'https://github.com/aFrogleap/SimpleImageViewer'
  pod 'SwiftyJSON'
  pod 'Alamofire'
  pod 'AlamofireImage'
  pod 'UICircularProgressRing', :git => 'https://github.com/luispadron/UICircularProgressRing'
  pod 'SDWebImageWebPCoder'
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
        target.build_configurations.each do |config|
            config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        end
      end
    end
  end
  
end
