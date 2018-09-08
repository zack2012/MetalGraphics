//
//  TransitionAnimatorable.swift
//  TGFC
//
//  Created by shiyueli7 on 2017/11/11.
//  Copyright © 2017年 zack. All rights reserved.
//

import UIKit

public protocol TransitionAnimatorable: class {
    var originFrame: CGRect { get }
    var targetFrame: CGRect { get }
    var isPresent: Bool { get }
    var dimmingView: UIView { get }
    var dimmingViewStartAlpha: CGFloat { get }
    var dimmingViewEndAlpha: CGFloat { get }
    var duration: TimeInterval { get }
    
    func makePropertyAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator?
}

extension TransitionAnimatorable {
    public func makePropertyAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator? {
        return isPresent ? makePresentPropertyAnimator(using: transitionContext) : makeDisappearPropertyAnimator(using: transitionContext)
    }
    
    private func makePresentPropertyAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator? {
        guard let toVC = transitionContext.viewController(forKey: .to), isPresent else {
            return nil
        }
        
        let containerView = transitionContext.containerView
        
        containerView.addSubview(dimmingView)
        containerView.addSubview(toVC.view)
        
        toVC.view.center = CGPoint(x: self.originFrame.midX, y: self.originFrame.midY)
        toVC.view.bounds = CGRect(origin: .zero, size: self.targetFrame.size)
        toVC.view.layer.masksToBounds = true
        
        dimmingView.alpha = dimmingViewStartAlpha
        dimmingView.frame = UIScreen.main.bounds
        
        toVC.view.backgroundColor = .clear
        
        let parameter = UISpringTimingParameters(dampingRatio: 0.7)
        let property = UIViewPropertyAnimator(duration: duration,
                                              timingParameters: parameter)
        property.addAnimations {
            toVC.view.center = CGPoint(x: self.targetFrame.midX, y: self.targetFrame.midY)
            toVC.view.backgroundColor = .black
            toVC.view.transform = .identity
            toVC.view.layer.sublayerTransform = CATransform3DMakeAffineTransform(.identity)
            self.dimmingView.alpha = self.dimmingViewEndAlpha
        }
        
        property.addCompletion { (position) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        return property
    }
    
    private func makeDisappearPropertyAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator? {
        guard let targetVC = transitionContext.viewController(forKey: .from), !isPresent else {
            return nil
        }
        
        targetVC.view.layer.masksToBounds = true
        
        let parameter = UISpringTimingParameters(dampingRatio: 1)
        let property = UIViewPropertyAnimator(duration: duration,
                                              timingParameters: parameter)
        
        targetVC.view.backgroundColor = .clear
        property.addAnimations {
            targetVC.view.center = CGPoint(x: self.targetFrame.midX, y: self.targetFrame.midY)
            self.dimmingView.alpha = self.dimmingViewStartAlpha
        }
        
        property.addCompletion { (position) in
            let isCancel = transitionContext.transitionWasCancelled
            if !isCancel {
                targetVC.view.removeFromSuperview()
                self.dimmingView.removeFromSuperview()
            }
            transitionContext.completeTransition(!isCancel)
        }
        
        return property
    }
}
