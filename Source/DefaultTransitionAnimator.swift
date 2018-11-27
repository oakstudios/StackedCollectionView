//
//  DefaultTransitionAnimator.swift
//
//  Created by Alex Givens http://alexgivens.com on 6/1/17
//  Copyright © 2017 Oak, LLC (https://oak.is)
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

public class DefaultTransitionAnimator: NSObject, UICollectionViewCellAnimatedTransitioning {
    
    public func transitionDuration(transitionContext: UICollectionViewCellContextTransitioning) -> TimeInterval {
        return 0.15
    }
    
    public func animateTransition(transitionContext: UICollectionViewCellContextTransitioning) {
        
        let toState = transitionContext.stateFor(key: .to)
        let cell = transitionContext.cell()
        let animationDuration = transitionContext.animationDuration()
        
        UIView.animate(withDuration: animationDuration) {
            
            switch toState {
                
            case .drag:
                cell.alpha = 0.7
                cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                
            default:
                cell.alpha = 1.0
                cell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
}
