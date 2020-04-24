//
//  Chapter10EventsViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 4/24/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Chapter10EventsViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var daysLabel: UILabel!
    
    let events = BehaviorRelay<[Chapter10EOEvent]>(value: [])
    let days = BehaviorRelay<Int>(value: 360)
    let filteredEvents = BehaviorRelay<[Chapter10EOEvent]>(value: [])
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        Observable.combineLatest(days, events) { days, events -> [Chapter10EOEvent] in
            let maxInterval = TimeInterval(days * 24 * 3600)
            return events.filter { event in
                if let date = event.date {
                    return abs(date.timeIntervalSinceNow) < maxInterval
                }
                return true
            }
        }
        .bind(to: filteredEvents)
        .disposed(by: self.disposeBag)
        
        filteredEvents.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
                }
        )
            .disposed(by: self.disposeBag)
        
        days.asObservable()
            .subscribe(onNext: { [weak self] days in
                self?.daysLabel.text = "Last \(days) days"
                }
        )
            .disposed(by: self.disposeBag)
    }
    
    @IBAction func sliderAction(slider: UISlider) {
        self.days.accept(Int(slider.value))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chapter10EventCell") as! Chapter10EventCell
        let event = filteredEvents.value[indexPath.row]
        cell.configure(event: event)
        return cell
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
