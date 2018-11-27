StackedCollectionView
=======================

[![Version](https://img.shields.io/cocoapods/v/StackedCollectionView.svg?style=flat)](http://cocoapods.org/pods/StackedCollectionView)
[![License](https://img.shields.io/cocoapods/l/StackedCollectionView.svg?style=flat)](http://cocoapods.org/pods/StackedCollectionView)
[![Platform](https://img.shields.io/cocoapods/p/StackedCollectionView.svg?style=flat)](http://cocoapods.org/pods/StackedCollectionView)
[![Twitter](https://img.shields.io/badge/twitter-%40oakstudios-blue.svg)](http://twitter.com/oakstudios)

## Introduction
`StackedCollectionView` is a `UICollectionViewFlowLayout` subclass written in Swift to provide drag-and-drop interactions within a `UICollectionView`. The behaviors include reorder and "stack" gestures, which emulate folder creation similar to the iOS home screen.

## Demo
![alt tag](https://raw.githubusercontent.com/oakstudios/StackedCollectionView/master/Demo.gif)

Check out the example project for a customized `UICollectionView` similar to what is used in [Dropmark for iOS](https://itunes.apple.com/us/app/dropmark/id999122556?mt=8).

To run the example project, clone the repo, and run `pod install` from the *Example* directory first.

## Installation

Install the library through [CocoaPods](http://cocoapods.org). Add the following line to your *Podfile*, then run `pod install`.

```ruby
pod 'StackedCollectionView', '~> 2.0'
```

Be sure to import the library when needed.

```swift
import StackedCollectionView
```

## Migration

### Version 2.0.0

This version requires Xcode 9.0 and Swift 4.

### Version 1.0.0

StackedCollectionView supports iOS 9.0+, Swift 3, and Xcode 8.0.

## Credits

Created by [Oak](https://oak.is) for [Dropmark](https://www.dropmark.com).

Portions of the reordering logic are referenced from [LXReorderableCollectionViewFlowLayout](https://github.com/lxcid/LXReorderableCollectionViewFlowLayout) and [this blog post](http://blog.karmadust.com/drag-and-rearrange-uicollectionviews-through-layouts/).

Example images provided by [Unsplash](https://unsplash.com).

## License

The MIT License (MIT)

Copyright (c) 2017 Oak, LLC [https://oak.is](https://oak.is)
