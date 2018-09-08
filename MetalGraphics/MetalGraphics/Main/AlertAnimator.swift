//
//  AlertAnimator.swift
//  TGFC
//
//  Created by shiyueli7 on 2017/11/11.
//  Copyright © 2017年 zack. All rights reserved.
//

import UIKit

public class AlertAnimator: NSObject, UIViewControllerAnimatedTransitioning, TransitionAnimatorable {
    public var originFrame: CGRect = .zero
    public var targetFrame: CGRect = .zero
    public var dimmingViewStartAlpha: CGFloat = 0
    public var dimmingViewEndAlpha: CGFloat = 1
    public var duration: TimeInterval = 0.25
    public var isPresent = false
    public var dimmingView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .black
        return vi
    }()
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        makePropertyAnimator(using: transitionContext)?.startAnimation()
    }
}
