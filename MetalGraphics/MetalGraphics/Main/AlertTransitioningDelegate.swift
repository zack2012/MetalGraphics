//
//  AlertTransitioningDelegate.swift
//  TGFC
//
//  Created by shiyueli7 on 2017/11/11.
//  Copyright © 2017年 zack. All rights reserved.
//

import UIKit

public class AlertTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public var originFrame: CGRect = .zero
    public var targetFrame: CGRect = .zero
    public var dimmingViewStartAlpha: CGFloat = 0.7
    public var dimmingViewEndAlpha: CGFloat = 0.7
    public var duration: TimeInterval = 0.5
    public var animator: AlertAnimator?
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator = AlertAnimator()
        animator?.originFrame = originFrame
        animator?.targetFrame = targetFrame
        animator?.isPresent = true
        animator?.dimmingViewStartAlpha = dimmingViewStartAlpha
        animator?.dimmingViewEndAlpha = dimmingViewEndAlpha
        animator?.duration = duration
        return animator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator?.isPresent = false
        animator?.originFrame = targetFrame
        animator?.targetFrame = originFrame
        return animator
    }
}
