//
//  CustomFlowLayout.swift
//
//  Copyright © 2018 Oak, LLC (https://oak.is)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import StackedCollectionView

class CustomFlowLayout: StackedFlowLayout {
    
    var maxItemWidth: CGFloat = 256.0
    var labelsHeight: CGFloat = 44.0
    
    var inset: UIEdgeInsets = UIEdgeInsets(top: Constant.Margin, left: Constant.Margin, bottom: Constant.Margin, right: Constant.Margin) {
        didSet {
            setupLayout()
        }
    }
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    func setupLayout() {
        gestureTriggerRadius = 30.0
        minimumInteritemSpacing = Constant.Margin
        minimumLineSpacing = Constant.Margin
        scrollDirection = .vertical
        sectionInset = inset
    }

    func itemWidth() -> CGFloat {
        let viewWidth = collectionView!.frame.width
        let colCount = ceil(viewWidth / maxItemWidth)
        let totalSpacing = Constant.Margin * (colCount - 1) + inset.left + inset.right
        var itemWidth = (viewWidth - totalSpacing) / colCount
        itemWidth = roundToDecimalPlace(itemWidth, place: 2)
        return itemWidth
    }
    
    override var itemSize: CGSize {
        set {
            self.itemSize = CGSize(width: itemWidth(), height: itemWidth() + labelsHeight)
        }
        get {
            return CGSize(width: itemWidth(), height: itemWidth() + labelsHeight)
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView!.contentOffset
    }
    
    // Utility
    
    func roundToDecimalPlace(_ x: CGFloat, place: CGFloat) -> CGFloat {
        let multiplier = pow(10.0, place)
        return floor(multiplier * x) / multiplier
    }
}

