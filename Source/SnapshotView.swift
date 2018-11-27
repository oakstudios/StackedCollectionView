//
//  SnapshotView.swift
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

public class SnapshotView: UIView {
    
    struct ViewContainer {
        var view = UIView()
        var size = CGSize.zero
        var widthConstraint: NSLayoutConstraint!
        var heightConstraint: NSLayoutConstraint!
    }
    
    var state: UICollectionViewCellState = .unknown
    
    var normalViewContainer: ViewContainer?
    var dragViewContainer: ViewContainer?
    var stackViewContainer: ViewContainer?
    
    var allViewContainers: [ViewContainer?] {
        return [normalViewContainer, dragViewContainer, stackViewContainer]
    }
    
    func set(normalView: UIView) {
        normalViewContainer?.view.removeFromSuperview()
        normalViewContainer = nil
        normalViewContainer = add(view: normalView)
    }
    
    func set(dragView: UIView) {
        dragViewContainer?.view.removeFromSuperview()
        dragViewContainer = nil
        dragViewContainer = add(view: dragView)
        
    }
    
    func set(stackView: UIView) {
        stackViewContainer?.view.removeFromSuperview()
        stackViewContainer = nil
        stackViewContainer = add(view: stackView)
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
        guard let normalViewContainer = self.normalViewContainer else { return }
        show(showViewContainer: normalViewContainer)
        state = .normal
    }
    
    func showDrag() {
        guard let dragViewContainer = self.dragViewContainer else { return }
        show(showViewContainer: dragViewContainer)
        state = .drag
    }
    
    func showStack() {
        guard let stackViewContainer = self.stackViewContainer else { return }
        show(showViewContainer: stackViewContainer)
        state = .stackDrag
    }
    
    func showVanished() {
        for viewContainer in allViewContainers {
            viewContainer?.widthConstraint.constant = 0.0
            viewContainer?.heightConstraint.constant = 0.0
        }
        layoutIfNeeded()
    }
    
    func show(showViewContainer: ViewContainer) {
        for viewContainer in allViewContainers {
            viewContainer?.view.alpha = viewContainer?.view == showViewContainer.view ? 1.0 : 0.0
            viewContainer?.widthConstraint.constant = showViewContainer.size.width
            viewContainer?.heightConstraint.constant = showViewContainer.size.height
        }
        layoutIfNeeded()
    }
}
