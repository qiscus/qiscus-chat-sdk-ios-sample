Pod::Spec.new do |s|

s.name         = "MyChat"
s.version      = "0.1.1"
s.summary      = "Custom chat base on QiscusCore"
s.description  = <<-DESC
Custom Chat SDK Base on QiscusCore-Example.
DESC
s.homepage     = "https://qiscus.com"
s.license      = "MIT"
s.author       = "Qiscus"
s.source       = { :path => "MyChat/" }
s.source_files  = "MyChat/**/*.{swift}"
s.resource_bundles = {
    'MyChat' => ['MyChat/**/*.{xcassets,imageset,png,xib}']
}
s.platform      = :ios, "9.0"

s.dependency 'QiscusCore'
s.dependency 'SwiftyJSON' 
s.dependency 'Alamofire'
s.dependency 'AlamofireImage'
s.dependency 'UICircularProgressRing'
s.dependency 'SimpleImageViewer'
s.dependency 'SDWebImage'

end
