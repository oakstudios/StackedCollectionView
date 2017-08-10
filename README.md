# StackedCollectionView

[![Version](https://img.shields.io/cocoapods/v/StackedCollectionView.svg?style=flat)](http://cocoapods.org/pods/StackedCollectionView)
[![License](https://img.shields.io/cocoapods/l/StackedCollectionView.svg?style=flat)](http://cocoapods.org/pods/StackedCollectionView)
[![Platform](https://img.shields.io/cocoapods/p/StackedCollectionView.svg?style=flat)](http://cocoapods.org/pods/StackedCollectionView)
[![Twitter](https://img.shields.io/badge/twitter-%40oakstudios-blue.svg)](http://twitter.com/oakstudios)

StackedCollectionView is a UICollectionViewFlowLayout which, in combination with the StackedCollectionViewDelegate and StackedCollectionViewDataSource, provide the tools necessary to easily create drag-and-drop interactions within a UICollectionView. The behaviors include reorder and "stack" gestures, which emulate folder creation like the iOS home screen. Check out the example project for a customized UICollectionView similar to what is used in Dropmark for iOS.

## Installation

Install the library through [CocoaPods](http://cocoapods.org). Add the following line to your Podfile, then run `pod install`.

```ruby
pod 'StackedCollectionView', '~> 1.0'
```

StackedCollectionView supports iOS 9.0+.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Created by [Alex Givens](http://alexgivens.com) for [Oak](https://oak.is). Portions of the reordering logic are referenced from [LXReorderableCollectionViewFlowLayout](https://github.com/lxcid/LXReorderableCollectionViewFlowLayout) and [this blog post](http://blog.karmadust.com/drag-and-rearrange-uicollectionviews-through-layouts/). Example images provided by [Unsplash](https://unsplash.com).

## License

StackedCollectionView is available under the MIT license. See the LICENSE file for more info.
