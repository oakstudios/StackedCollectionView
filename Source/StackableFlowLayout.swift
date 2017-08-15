//
//  StackableFlowLayout.swift
//
//  Created by Alex Givens http://alexgivens.com on 5/5/17
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

@objc public protocol StackedCollectionViewDelegate {
    @objc optional func collectionView(_ collectionView: UICollectionView, willBeginDraggingItemAt indexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, didBeginDraggingItemAt indexPath: IndexPath)
    @objc optional func collectionViewGestureDidMoveOutsideTriggerRadius(_ collectionView: UICollectionView)
    @objc optional func collectionView(_ collectionView: UICollectionView, willEndDraggingItemAt indexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, didEndDraggingItemAt indexPath: IndexPath)
    
    @objc optional func collectionView(_ collectionView: UICollectionView, animationControllerFor indexPath: IndexPath) -> UICollectionViewCellAnimatedTransitioning?
}

@objc public protocol StackedCollectionViewDataSource {
    @objc optional func collectionView(_ collectionView: UICollectionView, shouldRefreshStackCellAt indexPath: IndexPath) -> Bool
    @objc optional func collectionView(_ collectionView: UICollectionView, canMoveItemAt sourceIndexPath: IndexPath, into stackDestinationIndexPath: IndexPath) -> Bool
    @objc optional func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, into stackDestinationIndexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, finishMovingItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

open class StackedFlowLayout: UICollectionViewFlowLayout, UIGestureRecognizerDelegate {
    
    struct KeyPath {
        static let CollectionView = "collectionView"
    }
    
    enum AutoScrollDirection {
        case up
        case down
        case left
        case right
    }
    
    var delegate: StackedCollectionViewDelegate?
    var dataSource: StackedCollectionViewDataSource?
    
    // Configurable
    public var scrollingTriggerEdgeInsets = UIEdgeInsets(top: 64.0, left: 64.0, bottom: 64.0, right: 64.0)
    public var maxScrollingSpeed: CGFloat = 800.0
    public var stackTriggerZone: CGFloat = 0.6
    public var longPressGestureDuration: CFTimeInterval = 0.15
    public var maxTriggerVelocity: CGFloat = 200.0
    public var gestureTriggerRadius: CGFloat = 12.0
    
    // Internal
    public var longPressGestureRecognizer: UILongPressGestureRecognizer?
    public var panGestureRecognizer: UIPanGestureRecognizer?
    
    private var fingerPoint = CGPoint.zero
    
    private var selectedItemSourceIndexPath: IndexPath?
    private var selectedItemDestinationIndexPath: IndexPath?
    private var selectedItemStackDestinationIndexPath: IndexPath? {
        set {
            guard newValue != _selectedItemStackDestinationIndexPath, let collectionView = self.collectionView else { return }
            
            let originalselectedItemStackDestinationIndexPath = _selectedItemStackDestinationIndexPath
            _selectedItemStackDestinationIndexPath = newValue
            
            // Animate the dragging snapshot
            if _selectedItemStackDestinationIndexPath == nil {
                
                let placeholderIndex = _selectedItemStackDestinationIndexPath ?? IndexPath(item: 0, section: 0)
                let animationController = animationControllerFor(indexPath: placeholderIndex)
                let animationContext = UICollectionViewCellContext()
                animationContext._stateDict = [ .from : .normal, .to : .drag ]
                let animationDuration = animationController.transitionDuration(transitionContext: animationContext)
                UIView.animate(withDuration: animationDuration) {
                    self.selectedItemSnapshotView?.showDrag()
                }
                
            } else {
                
                let animationController = animationControllerFor(indexPath: _selectedItemStackDestinationIndexPath!)
                let animationContext = UICollectionViewCellContext()
                animationContext._stateDict = [ .from : .drag, .to : .stackDrag ]
                let animationDuration = animationController.transitionDuration(transitionContext: animationContext)
                UIView.animate(withDuration: animationDuration) {
                    self.selectedItemSnapshotView?.showStack()
                }
                
            }
            
            // Animate the original cell, if necessary
            if
                let originalStackIndexPath = originalselectedItemStackDestinationIndexPath,
                let cell = collectionView.cellForItem(at: originalStackIndexPath)
            {
                let animationController = self.animationControllerFor(indexPath: originalStackIndexPath)
                let context = UICollectionViewCellContext()
                context._cell = cell
                context._stateDict = [ .from : .stackBase, .to : .normal ]
                let animationDuration = animationController.transitionDuration(transitionContext: context)
                context._animationDuration = animationDuration
                animationController.animateTransition(transitionContext: context)
            }
            
            // Animate the destination cell, if necessary
            if
                let destinationIndexPath = _selectedItemStackDestinationIndexPath,
                let cell = collectionView.cellForItem(at: destinationIndexPath)
            {
                let animationController = self.animationControllerFor(indexPath: destinationIndexPath)
                let context = UICollectionViewCellContext()
                context._cell = cell
                context._stateDict = [ .from : .normal, .to : .stackBase ]
                let animationDuration = animationController.transitionDuration(transitionContext: context)
                context._animationDuration = animationDuration
                animationController.animateTransition(transitionContext: context)
            }
            
        }
        get {
            return _selectedItemStackDestinationIndexPath
        }
    }
    private var _selectedItemStackDestinationIndexPath: IndexPath?
    
    private var selectedItemSnapshotView: SnapshotView?
    private var autoScroll: (direction: AutoScrollDirection, magnitude: CGFloat)? {
        get {
            return _autoScroll
        }
        set {
            
            if newValue == _autoScroll { return }
            _autoScroll = newValue
            if let displayLink = self.displayLink, displayLink.isPaused == false {
                displayLink.invalidate()
            }
            displayLink = nil
            if _autoScroll != nil {
                displayLink = CADisplayLink(target: self, selector: #selector(handleAutoScroll(_:)))
                displayLink!.add(to: RunLoop.main, forMode: .commonModes)
            }
        }
    }
    private var _autoScroll: (direction: AutoScrollDirection, magnitude: CGFloat)?
    private var displayLink: CADisplayLink?
    var gestureOrigin: CGPoint?
    var gestureDidMoveOutsideTriggerRadius: Bool {
        get {
            return _gestureDidMoveOutsideTriggerRadius
        }
        set {
            guard newValue != _gestureDidMoveOutsideTriggerRadius else { return }
            _gestureDidMoveOutsideTriggerRadius = newValue
            if _gestureDidMoveOutsideTriggerRadius, let collectionView = self.collectionView {
                delegate?.collectionViewGestureDidMoveOutsideTriggerRadius?(collectionView)
            }
        }
    }
    var _gestureDidMoveOutsideTriggerRadius = false
    
    override public init() {
        super.init()
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    private func initialize() {
        addObserver(self, forKeyPath: KeyPath.CollectionView, options: [ .new ], context: nil)
    }
    
    deinit {
        removeObserver(self, forKeyPath: KeyPath.CollectionView)
    }
    
    // MARK: Gestures
    
    func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        
        guard let collectionView = self.collectionView else { return }
        
        switch gesture.state {
            
        case .began:
            
            guard let sourceIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { return }
            let canMoveItem = collectionView.dataSource?.collectionView?(collectionView, canMoveItemAt: sourceIndexPath) ?? true
            guard canMoveItem, let sourceCollectionViewCell = collectionView.cellForItem(at: sourceIndexPath) else { return }
            
            updateFingerPoint()
            
            selectedItemSourceIndexPath = sourceIndexPath
            selectedItemDestinationIndexPath = sourceIndexPath
            sourceCollectionViewCell.isHighlighted = false
            
            delegate?.collectionView?(collectionView, willBeginDraggingItemAt: sourceIndexPath)
            
            selectedItemSnapshotView = SnapshotView(frame: sourceCollectionViewCell.frame)
            updateSnapshotViewForCell(at: selectedItemSourceIndexPath!)
            collectionView.addSubview(selectedItemSnapshotView!)
            
            delegate?.collectionView?(collectionView, didBeginDraggingItemAt: sourceIndexPath)
            
            let animationController = animationControllerFor(indexPath: sourceIndexPath)
            let animationContext = UICollectionViewCellContext()
            animationContext._cell = sourceCollectionViewCell
            animationContext._stateDict = [ .from : .normal, .to : .drag ]
            let animationDuration = animationController.transitionDuration(transitionContext: animationContext)
            
            UIView.animate(
                withDuration: animationDuration,
                delay: 0.0,
                options: [ .beginFromCurrentState ],
                animations: {
                    self.selectedItemSnapshotView!.center = self.fingerPoint
                    self.selectedItemSnapshotView!.showDrag()
                },
                completion: { (finished) in
                    self.hapticFeedback()
                }
            )
            
            self.invalidateLayout()
            
        case .ended:
            
            guard let destinationIndexPath = self.selectedItemDestinationIndexPath else { return }
            
            updateFingerPoint()
            
            selectedItemDestinationIndexPath = nil
            
            delegate?.collectionView?(collectionView, willEndDraggingItemAt: destinationIndexPath)
            
            longPressGestureRecognizer?.isEnabled = false
            
            if
                let stackDestinationIndexPath = selectedItemStackDestinationIndexPath,
                canMoveItemAt(destinationIndexPath, into: stackDestinationIndexPath)
            {
                
                guard
                    let stackDestinationCenter = self.layoutAttributesForItem(at: stackDestinationIndexPath)?.center
                else {
                    return
                }
                
                selectedItemStackDestinationIndexPath = nil
                
                dataSource?.collectionView?(collectionView, moveItemAt: destinationIndexPath, into: stackDestinationIndexPath)
                
                let shouldRefreshStackCell = dataSource?.collectionView?(collectionView, shouldRefreshStackCellAt: stackDestinationIndexPath) ?? true
                
                collectionView.performBatchUpdates({
                    collectionView.deleteItems(at: [ destinationIndexPath ])
                    if shouldRefreshStackCell {
                        collectionView.reloadItems(at: [ stackDestinationIndexPath ])
                    }
                }, completion: nil)
                
                // If the final item is deleted, the scroll jumps
                // Fix? https://stackoverflow.com/a/13403772/4197332
                
                let animationController = animationControllerFor(indexPath: destinationIndexPath)
                let animationContext = UICollectionViewCellContext()
                animationContext._stateDict = [ .from : .drag, .to : .normal ]
                let animationDuration = animationController.transitionDuration(transitionContext: animationContext)
                
                UIView.animate(
                    withDuration: animationDuration,
                    delay: 0.0,
                    options: [ .beginFromCurrentState ],
                    animations: {
                        self.selectedItemSnapshotView?.center = stackDestinationCenter
                        self.selectedItemSnapshotView?.showVanished()
                },
                    completion: { (finished) in
                        self.longPressGestureRecognizer?.isEnabled = true
                        self.selectedItemSnapshotView?.removeFromSuperview()
                        self.selectedItemSnapshotView = nil
                        self.gestureDidMoveOutsideTriggerRadius = false
                        self.gestureOrigin = nil
                        self.hapticFeedback()
                        self.delegate?.collectionView?(collectionView, didEndDraggingItemAt: stackDestinationIndexPath)
                        self.invalidateLayout()
                    }
                )
                
            } else {
                
                selectedItemStackDestinationIndexPath = nil
                
                guard
                    let layoutAttributes = self.layoutAttributesForItem(at: destinationIndexPath)
                else {
                    return
                }
                
                let animationController = animationControllerFor(indexPath: destinationIndexPath)
                let animationContext = UICollectionViewCellContext()
                animationContext._stateDict = [ .from : .drag, .to : .normal ]
                let animationDuration = animationController.transitionDuration(transitionContext: animationContext)
                
                UIView.animate(
                    withDuration: animationDuration,
                    delay: 0.0,
                    options: [ .beginFromCurrentState ],
                    animations: {
                        self.selectedItemSnapshotView?.center = layoutAttributes.center
                        self.selectedItemSnapshotView?.showNormal()
                },
                    completion: { (finished) in
                        self.longPressGestureRecognizer?.isEnabled = true
                        self.selectedItemSnapshotView?.removeFromSuperview()
                        self.selectedItemSnapshotView = nil
                        self.gestureDidMoveOutsideTriggerRadius = false
                        self.gestureOrigin = nil
                        self.hapticFeedback()
                        self.delegate?.collectionView?(collectionView, didEndDraggingItemAt: destinationIndexPath)
                        if
                            let sourceIndexPath = self.selectedItemSourceIndexPath,
                            sourceIndexPath != destinationIndexPath
                        {
                            self.dataSource?.collectionView?(collectionView, finishMovingItemAt: sourceIndexPath, to: destinationIndexPath)
                        }
                        self.selectedItemSourceIndexPath = nil
                        self.invalidateLayout()
                    }
                )
            }
            
        case .cancelled, .failed:
            selectedItemDestinationIndexPath = nil
            selectedItemStackDestinationIndexPath = nil
            selectedItemSnapshotView?.removeFromSuperview()
            selectedItemSnapshotView = nil
            gestureDidMoveOutsideTriggerRadius = false
            gestureOrigin = nil
            
        default:
            break
            
        }
        
    }
    
    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        
        guard let collectionView = self.collectionView /*, extraLongGestureTimer == nil */ else { return }
        
        switch gesture.state {
            
        case .changed:
            
            updateFingerPoint()
            
            if // We were hovering over a stack preview, but just left the stack zone
                let stackIndexPath = self.selectedItemStackDestinationIndexPath,
                let stackCell = collectionView.cellForItem(at: stackIndexPath),
                fingerPointIsInStackZone(for: stackCell) == false
            {
                selectedItemStackDestinationIndexPath = nil
            }
            
            // If the user's finger is within the trigger insets, begin auto scroll
            switch scrollDirection {
                
            case .horizontal:
                
                if fingerPoint.x < collectionView.bounds.minX + scrollingTriggerEdgeInsets.left {  // Scroll left
                    
                    let magnitude = mapValue(fingerPoint.y,
                                             inMin: collectionView.bounds.minX + scrollingTriggerEdgeInsets.left,
                                             inMax: collectionView.bounds.minX,
                                             outMin: 0.0,
                                             outMax: maxScrollingSpeed)
                    autoScroll = (direction: .left, magnitude: magnitude)
                    
                } else if fingerPoint.x > collectionView.bounds.maxX - scrollingTriggerEdgeInsets.right { // Scroll right
                    
                    let magnitude = mapValue(fingerPoint.y,
                                             inMin: collectionView.bounds.maxX - scrollingTriggerEdgeInsets.right,
                                             inMax: collectionView.bounds.maxX,
                                             outMin: 0.0,
                                             outMax: maxScrollingSpeed)
                    autoScroll = (direction: .right, magnitude: magnitude)
                    
                } else { // Don't scroll
                    autoScroll = nil
                }
                
            case .vertical:
                
                if fingerPoint.y < collectionView.bounds.minY + scrollingTriggerEdgeInsets.top { // Scroll up
                    
                    let magnitude = mapValue(fingerPoint.y,
                                             inMin: collectionView.bounds.minY + scrollingTriggerEdgeInsets.top,
                                             inMax: collectionView.bounds.minY,
                                             outMin: 0.0,
                                             outMax: maxScrollingSpeed)
                    autoScroll = (direction: .up, magnitude: magnitude)
                    
                } else if fingerPoint.y > collectionView.bounds.maxY - scrollingTriggerEdgeInsets.bottom { // Scroll down
                    
                    let magnitude = mapValue(fingerPoint.y,
                                             inMin: collectionView.bounds.maxY - scrollingTriggerEdgeInsets.bottom,
                                             inMax: collectionView.bounds.maxY,
                                             outMin: 0.0,
                                             outMax: maxScrollingSpeed)
                    autoScroll = (direction: .down, magnitude: magnitude)
                    
                } else { // Don't scroll
                    autoScroll = nil
                }
            }
            
            if autoScroll == nil {
                updateSnapshotCenterPointIfNecessary()
                
                if
                    abs(gesture.velocity(in: collectionView).x) < maxTriggerVelocity,
                    abs(gesture.velocity(in: collectionView).y) < maxTriggerVelocity
                {
                    updateItemLayoutIfNecessary()
                }
            }
        
        case .ended, .cancelled, .failed:
            autoScroll = nil
            
        default:
            break
            
        }
        
    }
    
    func handleApplicationWillResignActive(_ notification: NSNotification) {
        panGestureRecognizer?.isEnabled = false
        panGestureRecognizer?.isEnabled = true
    }
    
    // MARK: Layout
    
    func handleAutoScroll(_ displayLink: CADisplayLink) {
        
        guard let autoScroll = self.autoScroll, let collectionView = self.collectionView else { return }
        
        let frameSize = collectionView.bounds.size
        let contentSize = collectionView.contentSize
        let contentOffset = collectionView.contentOffset
        let contentInset = collectionView.contentInset
        
        var distance = rint(autoScroll.magnitude * CGFloat(displayLink.duration))
        var translation = CGPoint.zero
        
        switch autoScroll.direction {
            
        case .up:
            distance = -distance
            let minY = -contentInset.top
            if contentOffset.y + distance <= minY {
                distance = -contentOffset.y - contentInset.top
            }
            translation = CGPoint(x: 0.0, y: distance)
            
        case .down:
            let maxY = max(contentSize.height, frameSize.height) - frameSize.height + contentInset.bottom
            if contentOffset.y + distance >= maxY {
                distance = maxY - contentOffset.y
            }
            translation = CGPoint(x: 0.0, y: distance)
            
        case .left:
            distance = -distance
            let minX = -contentInset.left
            if contentOffset.x + distance <= minX {
                distance = -contentOffset.x - contentInset.left
            }
            translation = CGPoint(x: distance, y: 0.0)
            
        case .right:
            let maxX = max(contentSize.width, frameSize.width) - frameSize.width + contentInset.right
            if contentOffset.x + distance >= maxX {
                distance = maxX - contentOffset.x
            }
            translation = CGPoint(x: distance, y: 0.0)
        }
        
        updateFingerPoint()
        updateSnapshotCenterPointIfNecessary()
        
        if let newOffset = contentOffset + translation {
            collectionView.contentOffset = newOffset
        }
        
        self.invalidateLayout()
    }
    
    func updateFingerPoint() {
        guard let collectionView = self.collectionView, let panGestureRecognizer = self.panGestureRecognizer else { return }
        let newFingerPoint = panGestureRecognizer.location(in: collectionView)
        guard newFingerPoint != fingerPoint else { return }
        fingerPoint = newFingerPoint
        
        if gestureOrigin == nil {
            gestureOrigin = fingerPoint
        } else if distance(gestureOrigin!, fingerPoint) > gestureTriggerRadius {
            gestureDidMoveOutsideTriggerRadius = true
        }
        
    }
    
    func updateSnapshotCenterPointIfNecessary() {
        guard selectedItemSnapshotView?.center != fingerPoint else { return }
        selectedItemSnapshotView?.center = fingerPoint
    }
    
//    public func updateSelectedItemSnapshotViewIfNecessary() {
//        guard
//            let selectedItemSourceIndexPath = self.selectedItemSourceIndexPath,
//            let cell = collectionView?.cellForItem(at: selectedItemSourceIndexPath)
//        else {
//            return
//        }
//        cell.alpha = 1.0
//        updateSnapshotViewForCell(at: selectedItemSourceIndexPath)
//        cell.alpha = 0.0
//    }
    
    func updateItemLayoutIfNecessary() {
        
        // The stored selectedItemDestinationIndexPath value is our starting point
        // The destination is the index under the user's finger
        
        guard
            let collectionView = self.collectionView,
            let sourceIndexPath = self.selectedItemDestinationIndexPath,
            let destinationIndexPath = collectionView.indexPathForItem(at: fingerPoint),
            let destinationCell = collectionView.cellForItem(at: destinationIndexPath),
            sourceIndexPath != destinationIndexPath
        else {
            return
        }
        
        // At this point, we know the user has panned to a new cell
        
        func triggerReorder() {
            selectedItemStackDestinationIndexPath = nil
            selectedItemDestinationIndexPath = destinationIndexPath
            
            collectionView.dataSource?.collectionView?(collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath)
            
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [ sourceIndexPath ])
                collectionView.insertItems(at: [ destinationIndexPath ])
            }) { (finished) in
                self.hapticFeedback()
            }
        }
        
        if fingerPointIsInStackZone(for: destinationCell) { // Prepare for stack
            
            if canMoveItemAt(sourceIndexPath, into: destinationIndexPath) {
                selectedItemStackDestinationIndexPath = destinationIndexPath
            } else {
                selectedItemStackDestinationIndexPath = nil
                triggerReorder()
            }
            
        } else { // Trigger reorder
            
            triggerReorder()
        }

    }
    
    // MARK: UIGestureRecognizerDelegate methods
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if panGestureRecognizer == gestureRecognizer {
            return selectedItemDestinationIndexPath != nil
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if longPressGestureRecognizer == gestureRecognizer {
            return panGestureRecognizer == otherGestureRecognizer
        }
        
        if panGestureRecognizer == gestureRecognizer {
            return longPressGestureRecognizer == otherGestureRecognizer
        }
        
        return false
    }
    
    // MARK: UICollectionViewLayout override
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let layoutAttributesForElementsInRect = super.layoutAttributesForElements(in: rect) else { return nil }
        for layoutAttributes in layoutAttributesForElementsInRect {
            hideItem(inLayoutAttributes: layoutAttributes)
        }
        return layoutAttributesForElementsInRect
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
        hideItem(inLayoutAttributes: layoutAttributes)
        return layoutAttributes
    }
    
    func hideItem(inLayoutAttributes layoutAttributes: UICollectionViewLayoutAttributes) {
        switch layoutAttributes.representedElementCategory {
        case .cell:
            if layoutAttributes.indexPath == selectedItemDestinationIndexPath {
                layoutAttributes.isHidden = true
            }
        default:
            break
        }
    }
    
    // MARK: KVO
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == KeyPath.CollectionView {
            if collectionView != nil {
                setupCollectionView()
            } else {
                autoScroll = nil
                tearDownCollectionView()
            }
        }
    }
    
    // MARK: Utility
    
    private func setupCollectionView() {
        
        guard let collectionView = self.collectionView else { return }
        
        // Long Press
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        longPressGestureRecognizer!.delegate = self
        longPressGestureRecognizer!.numberOfTouchesRequired = 1
        longPressGestureRecognizer!.minimumPressDuration = longPressGestureDuration
        
        if let collectionViewGestureRecognizers = collectionView.gestureRecognizers {
            for case let gestureRecognizer as UILongPressGestureRecognizer in collectionViewGestureRecognizers {
                gestureRecognizer.require(toFail: longPressGestureRecognizer!)
            }
        }
        
        collectionView.addGestureRecognizer(longPressGestureRecognizer!)
        
        // Pan
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer!.delegate = self
        panGestureRecognizer!.maximumNumberOfTouches = 1
        collectionView.addGestureRecognizer(panGestureRecognizer!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationWillResignActive(_:)), name: Notification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    private func tearDownCollectionView() {
        
        // Long Press
        if let longPressGestureRecognizer = longPressGestureRecognizer {
            longPressGestureRecognizer.view?.removeGestureRecognizer(longPressGestureRecognizer)
            longPressGestureRecognizer.delegate = nil
        }
        longPressGestureRecognizer = nil
        
        // Pan
        if let panGestureRecognizer = panGestureRecognizer {
            panGestureRecognizer.view?.removeGestureRecognizer(panGestureRecognizer)
            panGestureRecognizer.delegate = nil
        }
        panGestureRecognizer = nil
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    func updateSnapshotViewForCell(at indexPath: IndexPath) {
        guard let selectedItemSnapshotView = self.selectedItemSnapshotView else { return }
        selectedItemSnapshotView.set(dragView: snapshotViewOfCell(at: indexPath, ofState: .drag))
        selectedItemSnapshotView.set(stackView: snapshotViewOfCell(at: indexPath, ofState: .stackDrag))
        selectedItemSnapshotView.set(normalView: snapshotViewOfCell(at: indexPath, ofState: .normal))
        switch selectedItemSnapshotView.state {
        case .drag:
            selectedItemSnapshotView.showDrag()
        case .stackDrag:
            selectedItemSnapshotView.showStack()
        default:
            selectedItemSnapshotView.showNormal()
        }
    }
    
    func snapshotViewOfCell(at indexPath: IndexPath, ofState state: UICollectionViewCellState) -> UIView {
        
        guard
            let collectionView = self.collectionView,
            let cell = collectionView.cellForItem(at: indexPath)
        else {
            return UIView()
        }
        
        let animationController = animationControllerFor(indexPath: indexPath)
        
        let context = UICollectionViewCellContext()
        context._cell = cell
        context._stateDict = [ .from : .normal, .to : state ]
        context._animationDuration = 0.0
        
        animationController.animateTransition(transitionContext: context)
        
        return cell.snapshotView
    }
    
    func animationControllerFor(indexPath: IndexPath) -> UICollectionViewCellAnimatedTransitioning {
        guard let collectionView = self.collectionView else { return DefaultTransitionAnimator() }
        let delegateAnimationController = delegate?.collectionView?(collectionView, animationControllerFor: indexPath)
        return delegateAnimationController ?? DefaultTransitionAnimator()
    }
    
    func canMoveItemAt(_ sourceIndexPath: IndexPath, into stackDestinationIndexPath: IndexPath) -> Bool {
        guard let collectionView = self.collectionView else { return true }
        return dataSource?.collectionView?(collectionView, canMoveItemAt: sourceIndexPath, into: stackDestinationIndexPath) ?? true
    }
    
    func fingerPointIsInStackZone(for cell: UICollectionViewCell) -> Bool {
        guard let collectionView = self.collectionView else { return false }
        let fingerPointInCell = collectionView.convert(fingerPoint, to: cell)
        let minX = cell.bounds.width * (1.0 - stackTriggerZone) / 2
        let maxX = cell.bounds.width - minX
        let minY = cell.bounds.height * (1.0 - stackTriggerZone) / 2
        let maxY = cell.bounds.height - minY
        return minX < fingerPointInCell.x && fingerPointInCell.x < maxX && minY < fingerPointInCell.y && fingerPointInCell.y < maxY
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        return hypot(a.x - b.x, a.y - b.y)
    }
    
    func hapticFeedback() {
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UIImpactFeedbackGenerator()
            feedbackGenerator.impactOccurred()
        }
    }
    
}
