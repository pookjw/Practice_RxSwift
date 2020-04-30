//
//  Chapter11TableViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 4/25/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit
import RxSwift

class Chapter11TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chapter11TableViewCell", for: indexPath) as! Chapter11TableViewCell
        
        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.actionButton.setTitle("Test Action", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action1(_:)), for: .touchUpInside)
        case 1:
            cell.actionButton.setTitle("buffer", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action2(_:)), for: .touchUpInside)
        default:
            ()
        }
        
        return cell
    }
    
    // MARK: Private Methods
    @objc private func action1(_ sender: UIButton) {
        print("Test Action Activated")
    }
    
    @objc private func action2(_ sender: UIButton) {
        let elementsPerSecond = 1
        let maxElements = 5
        let replayedElements = 5
        let replayDelay: TimeInterval = 3
        
        let sourceObservable = Observable<Int>.create { observer in
            var value = 1
            let timer = DispatchSource.timer(interval: 1.0, queue: .main) {
                if value <= maxElements {
                    observer.onNext(value)
                    value += 1
                }
            }
            return Disposables.create {
                timer.suspend()
            }
        }
        .replay(replayedElements)
        
        let sourceTimeline = TimelineView<Int>.make()
        let replayedTimeline = TimelineView<Int>.make()
        
        let stack = UIStackView.makeVertical([
            UILabel.makeTitle("replay"),
            UILabel.make("Emit \(elementsPerSecond) per second:"),
            sourceTimeline,
            UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:"),
            replayedTimeline
        ])
        
        DispatchQueue.asyncAfter(deadline: .now()) {
            
        }
        _ = sourceObservable.subscribe(sourceTimeline)
    }
    
    @objc private func action(_ sender: UIButton) {
        
    }
}
