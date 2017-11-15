//
//  Created by Anastasiya Gorban on 4/14/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//
//  Licensed under the MIT license: http://opensource.org/licenses/MIT
//  Latest version can be found at https://github.com/Yalantis/PullToRefresh
//

import Foundation
import UIKit
import ObjectiveC

private var topPullToRefreshKey: UInt8 = 0

public extension UIScrollView {
    
    fileprivate(set) var topPullToRefresh: PullToRefresh? {
        get {
            return objc_getAssociatedObject(self, &topPullToRefreshKey) as? PullToRefresh
        }
        set {
            objc_setAssociatedObject(self, &topPullToRefreshKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    internal func defaultFrame(forPullToRefresh pullToRefresh: PullToRefresh) -> CGRect {
        let view = pullToRefresh.refreshView
        var originY: CGFloat
        originY = -view.frame.size.height
        return CGRect(x: 0.0, y: originY, width: view.frame.width, height: view.frame.height)
    }
    
    internal func defaultiOS11Frame(forPullToRefresh pullToRefresh: PullToRefresh) -> CGRect {
        let view = pullToRefresh.refreshView
        return CGRect(x: 0.0, y: 10.0, width: view.frame.width, height: view.frame.height)
    }
    
    public func addPullToRefresh(_ pullToRefresh: PullToRefresh, navigationController: UINavigationController?, action: @escaping () -> ()) {
        pullToRefresh.scrollView = self
        pullToRefresh.action = action
        
        let view = pullToRefresh.refreshView
        
        removePullToRefresh()
        topPullToRefresh = pullToRefresh

        if #available(iOS 11, *) {
            view.frame = defaultiOS11Frame(forPullToRefresh: pullToRefresh)
            navigationController?.navigationBar.addSubview(view)
            navigationController?.navigationBar.sendSubview(toBack: view)
        }
        else {
            view.frame = defaultFrame(forPullToRefresh: pullToRefresh)
            addSubview(view)
            sendSubview(toBack: view)
        }
    }
    
    func removePullToRefresh() {
            topPullToRefresh?.refreshView.removeFromSuperview()
            topPullToRefresh = nil
    }
    
    func removeAllPullToRefresh() {
        removePullToRefresh()
    }
    
    func startRefreshing() {
        topPullToRefresh?.startRefreshing()
    }
    
    func endRefreshing() {
        topPullToRefresh?.endRefreshing()
    }
    
    func endAllRefreshing() {
        endRefreshing()
    }
}

private var topPullToRefreshInsetsHandlerKey: UInt8 = 0
private var bottomPullToRefreshInsetsHandlerKey: UInt8 = 0
private var implementationSwapedKey: UInt8 = 0

@available(iOS 11.0, *)
extension UIScrollView {
    
    private var topPullToRefreshInsetsHandler: ((UIEdgeInsets) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &topPullToRefreshInsetsHandlerKey) as? ((UIEdgeInsets) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &topPullToRefreshInsetsHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var bottomPullToRefreshInsetsHandler: ((UIEdgeInsets) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &bottomPullToRefreshInsetsHandlerKey) as? ((UIEdgeInsets) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &bottomPullToRefreshInsetsHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var isImplementationSwaped: Bool {
        get{
            return objc_getAssociatedObject(self, &implementationSwapedKey) as? Bool ?? false
        }
        set{
             objc_setAssociatedObject(self, &implementationSwapedKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    internal func addAdjustedContentInsetsHandler(handler: @escaping ((UIEdgeInsets) -> Void)) {
        topPullToRefreshInsetsHandler = handler
        if !isImplementationSwaped {
            swapAdjustedContentInsetDidChangeImplementation()
            isImplementationSwaped = true
        }
    }
    
    private func swapAdjustedContentInsetDidChangeImplementation() {
        let originalSelector = #selector(adjustedContentInsetDidChange)
        let swizzledSelector = #selector(patchedAdjustedContentInsetDidChange)
        
        if let originalMethod = class_getInstanceMethod(UIScrollView.self, originalSelector),
           let swizzledMethod = class_getInstanceMethod(UIScrollView.self, swizzledSelector) {
           method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    internal func removeAdjustedContentInsetsHandler() {
        topPullToRefreshInsetsHandler = nil
        if topPullToRefreshInsetsHandler == nil && bottomPullToRefreshInsetsHandler == nil {
            swapAdjustedContentInsetDidChangeImplementation()
            isImplementationSwaped = false
        }
    }
    
    @objc internal func patchedAdjustedContentInsetDidChange() {
        topPullToRefreshInsetsHandler?(adjustedContentInset)
        bottomPullToRefreshInsetsHandler?(adjustedContentInset)
        patchedAdjustedContentInsetDidChange()
    }
}
