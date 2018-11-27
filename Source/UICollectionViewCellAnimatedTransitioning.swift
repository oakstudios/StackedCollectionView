//
//  UICollectionViewCellAnimatedTransitioning.swift
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

@objc public enum UICollectionViewCellState: Int {
    case unknown
    case normal
    case drag
    case stackBase
    case stackDrag
}

@objc public enum UITransitionContextCellStateKey: Int {
    case from, to
}

@objc public protocol UICollectionViewCellAnimatedTransitioning {
    func transitionDuration(transitionContext: UICollectionViewCellContextTransitioning) -> TimeInterval
    func animateTransition(transitionContext: UICollectionViewCellContextTransitioning)
}

public class UICollectionViewCellContext: UICollectionViewCellContextTransitioning {
    
    var _cell = UICollectionViewCell()
    var _stateDict: [UITransitionContextCellStateKey: UICollectionViewCellState] = [.from: .normal, .to: .normal]
    var _animationDuration: TimeInterval = 0.25
    
    public func cell() -> UICollectionViewCell {
        return _cell
    }
    
    public func stateFor(key: UITransitionContextCellStateKey) -> UICollectionViewCellState {
        return _stateDict[key] ?? .normal
    }

    public func animationDuration() -> TimeInterval {
        return _animationDuration
    }
}

@objc public protocol UICollectionViewCellContextTransitioning {
    func cell() -> UICollectionViewCell
    func stateFor(key: UITransitionContextCellStateKey) -> UICollectionViewCellState
    func animationDuration() -> TimeInterval
}
