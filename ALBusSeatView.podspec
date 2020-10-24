#
# Be sure to run `pod lib lint ALBusSeatView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'ALBusSeatView'
    s.version          = '0.2.4'
    s.summary          = 'A customizable bus seat selection view'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = 'ALBusSeatView allows you to build the bus seat selection process easier and fully customizable'
    
    s.homepage         = 'https://github.com/applogistdev/ALBusSeatView'
    s.screenshots      = 'https://raw.githubusercontent.com/applogistdev/ALBusSeatView/master/Screenshots/ss1.png', 'https://raw.githubusercontent.com/applogistdev/ALBusSeatView/master/Screenshots/ss2.png'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'sonifex' => 'sonerguler93@gmail.com' }
    s.source           = { :git => 'https://github.com/applogistdev/ALBusSeatView.git', :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/sonifex'
    
    s.ios.deployment_target = '10.3'
    
    s.source_files = 'ALBusSeatView/Classes/**/*'
    s.swift_version = "5.0"
    s.resource_bundles = {
        'ALBusSeatView' => ['ALBusSeatView/Assets/*.xcassets']
    }
    
    # s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'UIKit'
    # s.dependency 'AFNetworking', '~> 2.3'
end
