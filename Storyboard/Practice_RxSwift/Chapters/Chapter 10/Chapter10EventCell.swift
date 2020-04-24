//
//  Chapter10EventCell.swift
//  Practice_RxSwift
//
//  Created by pook on 4/24/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit

class Chapter10EventCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var details: UILabel!
    
    func configure(event: Chapter10EOEvent) {
        title.text = event.title
        
        if event.description.count == 0 {
            details.text = "No description."
        } else {
            details.text = event.description
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        if let when = event.date {
            date.text = formatter.string(from: when)
        } else {
            date.text = ""
        }
    }
}
