#
# Be sure to run `pod lib lint LYLeaksInspector.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LYLeaksInspector"
  s.version          = "1.0.2"
  s.summary          = "LYLeaksInspector is a read-time tool to detect view-leaks in your app."

  s.description      = <<-DESC
                      LYLeaksInspector is a read-time tool to detect view-leaks in your app efficiently.
                       DESC
  s.homepage         = "https://github.com/linyu92/LYLeaksInspector"
  s.license          = 'MIT'
  s.author           = { "levi92" => "330269630@qq.com" }
  s.source           = { :git => "https://github.com/linyu92/LYLeaksInspector.git", :tag => "1.0.2" }

  s.ios.deployment_target = '7.0'

  non_arc_files = 'LYLeaksInspector/Classes/MRC/*.{h,m}'

  s.source_files = 'LYLeaksInspector/Classes/{Categories,DebugUtils,MRC,UI}/*.{h,m}'

  s.ios.exclude_files = non_arc_files

  s.requires_arc = true

  s.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'LYListViewControllers=0' }

  s.subspec 'no-arc' do |sna|
    sna.requires_arc = false
    sna.source_files = non_arc_files
  end

  # s.frameworks = 'Foundation'
  # s.dependency 'AFNetworking', '~> 2.3'
end
