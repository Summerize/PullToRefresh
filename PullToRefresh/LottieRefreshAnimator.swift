//
//  LottieRefreshAnimator.swift
//  PullToRefresh
//
//  Created by Paul-Anatole CLAUDOT on 15/11/2017.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import Lottie

class LottieViewAnimator: RefreshViewAnimator {
    var animationShouldContinue = true
    fileprivate let refreshView: LOTAnimationView
    
    init(refreshView: LOTAnimationView) {
        self.refreshView = refreshView
    }
    
    func animate(_ state: State) {
        switch state {
        case .initial:
            
            animationShouldContinue = false
            refreshView.stop()
            UIView.animate(withDuration: 0.1, animations: {
                self.refreshView.alpha = 0.0
            })
        case .releasing(let progress):
            print(progress)
            if (progress < 0.05) {
                UIView.animate(withDuration: 0.1, animations: {
                    self.refreshView.alpha = 0.0
                })
            }
            else {
                refreshView.alpha = 1.0
            }
            refreshView.animationProgress = progress * 0.22
        case .loading:
            animationShouldContinue = true
            loopAnimation()
        default: break
        }
    }
    
    func loopAnimation() {
        if animationShouldContinue {
            refreshView.play(fromProgress: 0.2, toProgress: 1.0) { [weak self] (_) in
                self?.loopAnimation()
            }
        }
    }
}

