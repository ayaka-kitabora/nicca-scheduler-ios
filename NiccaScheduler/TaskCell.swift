//
//  TaskCell.swift
//  NiccaScheduler
//
//  Created by 北洞亜也加 on 2021/05/23.
//

import UIKit

class TaskCell: UITableViewCell {

    @IBOutlet weak var taskLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func tapCheckButton(_ sender: CheckBox) {
        print(sender.isChecked)
    }
}
