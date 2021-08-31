//
//  UINavigationBar.swift
//  NiccaScheduler
//
//  Created by 北洞亜也加 on 2021/08/31.
//

import Foundation
extension UINavigationBar {

    func enableTransparency() {
        setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
    }

    func disableTransparency() {
        setBackgroundImage(nil, for: .default)
        self.shadowImage = nil
    }

}
