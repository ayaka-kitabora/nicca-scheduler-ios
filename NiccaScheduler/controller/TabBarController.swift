//
//  TabBarController.swift
//  NiccaScheduler
//
//  Created by 北洞亜也加 on 2021/08/31.
//

import UIKit

class TabBarController: UITabBarController, UITabBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }
    

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // ViewControllerの切り替えアニメーション
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
          return false
        }
        if fromView != toView {
          UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
        }
        return true
    }

}
