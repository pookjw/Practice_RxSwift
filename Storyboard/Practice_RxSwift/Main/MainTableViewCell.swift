//
//  MainTableViewCell.swift
//  Practice_RxSwift
//
//  Created by pook on 3/31/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
