//
//  Chapter10CategoriesViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 4/15/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Chapter10CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    let categories = BehaviorRelay<[Chapter10EOCategory]>(value: [])
    let disposeBag = DisposeBag()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.categories
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.tableView?.reloadData()
                }
            })
            .disposed(by: self.disposeBag)
        
        startDownload()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.categories.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chapter10CategoryCell")!
        let category = self.categories.value[indexPath.row]
        cell.textLabel?.text = "\(category.name) (\(category.events.count))"
        cell.accessoryType = (category.events.count > 0) ? .disclosureIndicator : .none
        cell.detailTextLabel?.text = category.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = self.categories.value[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard !category.events.isEmpty else { return }
        
        let eventsController = storyboard!.instantiateViewController(identifier: "Chapter10EventsViewController") as! Chapter10EventsViewController
        eventsController.title = category.name
        eventsController.events.accept(category.events)
        navigationController!.pushViewController(eventsController, animated: true)
    }
    
    private func startDownload() {
        let eoCategories = Chapter10EONET.categories
        
        /*
        let downloadedEvents = Chapter10EONET.events(forLast: 360)
        let updatedCategories = Observable.combineLatest(eoCategories, downloadedEvents) {
            (categories, events) -> [Chapter10EOCategory] in
            
            return categories.map { category in
                var cat = category
                cat.events = events.filter {
                    $0.categories.contains(where: { $0.id == category.id })
                }
                return cat
            }
        }*/
        
        let downloadedEvents = eoCategories
            .flatMap { categories in
                return Observable.from(categories.map { category in
                    Chapter10EONET.events(forLast: 360, category: category)
                })
        }
        .merge(maxConcurrent: 2)
        
        let updatedCategories = eoCategories.flatMap { categories in
            return downloadedEvents.scan(categories) { updated, events in
                return updated.map { category in
                    let eventsForCategory = Chapter10EONET.filteredEvents(events: events, forCategory: category)
                    
                    if !eventsForCategory.isEmpty {
                        var cat = category
                        cat.events = cat.events + eventsForCategory
                        return cat
                    }
                    return category
                }
            }
        }
        
        eoCategories
            .concat(updatedCategories)
            .bind(to: categories)
            .disposed(by: self.disposeBag)
    }
}
