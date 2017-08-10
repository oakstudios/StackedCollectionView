//
//  SnapshotView.swift
//
//  Created by Alex Givens http://alexgivens.com on 6/6/17
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

public class SnapshotView: UIView {
    
    struct ViewContainer {
        var view = UIView()
        var size = CGSize.zero
        var widthConstraint: NSLayoutConstraint!
        var heightConstraint: NSLayoutConstraint!
    }
    
    var normal: ViewContainer!
    var drag: ViewContainer!
    var stack: ViewContainer!
    
    var allViewContainers: [ViewContainer] {
        return [normal, drag, stack]
    }
    
    init(frame: CGRect, normalView: UIView, dragView: UIView, stackView: UIView) {
        super.init(frame: frame)
        
        normal = add(view: normalView)
        drag = add(view: dragView)
        stack = add(view: stackView)
        
        showNormal()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func add(view: UIView) -> ViewContainer {
        let size = view.bounds.size
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        let widthConstraint = view.widthAnchor.constraint(equalToConstant: view.bounds.width)
        widthConstraint.isActive = true
        let heightConstraint = view.heightAnchor.constraint(equalToConstant: view.bounds.height)
        heightConstraint.isActive = true
        return ViewContainer(view: view, size: size, widthConstraint: widthConstraint, heightConstraint: heightConstraint)
    }
    
    func showNormal() {
        show(showViewContainer: normal)
    }
    
    func showDrag() {
        show(showViewContainer: drag)
    }
    
    func showStack() {
        show(showViewContainer: stack)
    }
    
    func showVanished() {
        for viewContainer in allViewContainers {
            viewContainer.widthConstraint.constant = 0.0
            viewContainer.heightConstraint.constant = 0.0
        }
        layoutIfNeeded()
    }
    
    func show(showViewContainer: ViewContainer) {
        for viewContainer in allViewContainers {
            viewContainer.view.alpha = viewContainer.view == showViewContainer.view ? 1.0 : 0.0
            viewContainer.widthConstraint.constant = showViewContainer.size.width
            viewContainer.heightConstraint.constant = showViewContainer.size.height
        }
        layoutIfNeeded()
    }
}
