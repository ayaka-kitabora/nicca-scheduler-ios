//
//  CheckBox.swift
//  NiccaScheduler
//
//  Created by 北洞亜也加 on 2021/06/20.
//  https://qiita.com/bohebohechan/items/49aa25ed9a24b04619a0

import UIKit

class CheckBox: UIButton {
    // Images
    let checkedImage = UIImage(named: "check_on")! as UIImage
    let uncheckedImage = UIImage(named: "check_off")! as UIImage

    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }

    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }

    @objc func buttonClicked(sender: UIButton) {

    }
    
    func setChecked(_ check: Bool){
        isChecked = check
    }
}
