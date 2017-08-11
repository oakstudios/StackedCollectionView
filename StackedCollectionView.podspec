# Be sure to run `pod lib lint StackedCollectionView.podspec' to ensure this is a
# valid spec before submitting.

Pod::Spec.new do |s|
  s.name             = 'StackedCollectionView'
  s.version          = '1.0.0'
  s.summary          = 'Drag, drop, and combine items into stacks.'
  s.homepage         = 'https://github.com/oakstudios/StackedCollectionView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alex Givens' => 'alex@oakmade.com' }
  s.source           = { :git => 'https://github.com/oakstudios/StackedCollectionView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'Source/**/*'
  s.frameworks = 'UIKit'
end
