//
//  Chapter11ActionViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 4/30/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit
import RxSwift

class Chapter11ActionViewController: UIViewController {
    @IBOutlet var presentView: UIStackView!
    var viewTitle: String = "Timeline"
    var stack: [UILabel] = []
    var tlv: [TimelineViewBase] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presentView.addArrangedSubview(UILabel.makeTitle(viewTitle))
        // Do any additional setup after loading the view.
        for n in 0..<(stack.count>tlv.count ? stack.count : tlv.count) {
            if stack.count > n {
                presentView.addArrangedSubview(stack[n])
            }
            if tlv.count > n {
                presentView.addArrangedSubview(tlv[n])
            }
        }
    }
 
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
