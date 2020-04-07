//
//  Chapter8TableViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 4/7/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRealm
import Kingfisher

class Chapter8TableViewController: UITableViewController {
    
    private let repo = "pookjw/SidecarPatcher"
    private let eventsFileURL: URL = Chapter8TableViewController.cachedFileURL("events.json")
    private let events = BehaviorRelay<[Chapter8Event]>(value: [])
    private let modifiedFileURL: URL = Chapter8TableViewController.cachedFileURL("modified.txt")
    private let lastModified = BehaviorRelay<String?>(value: nil)
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = repo
        
        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl!
        
        refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        let decoder = JSONDecoder()
        if let eventsData = try? Data(contentsOf: self.eventsFileURL), let persistedEvents = try? decoder.decode([Chapter8Event].self, from: eventsData) {
            self.events.accept(persistedEvents)
        }
        refresh()
        if let lastModifiedString = try? String(contentsOf: self.modifiedFileURL, encoding: .utf8) {
            self.lastModified.accept(lastModifiedString)
        }
    }
    
    @objc func refresh() {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let self = self else { return }
            self.fetchEvents(repo: self.repo)
        }
    }
    
    func fetchEvents(repo: String) {
        let response = Observable.from([repo])
            .map { urlString -> URL in
                return URL(string: "https://api.github.com/repos/\(urlString)/events")!
        } // String to URL
            .map { [weak self] url -> URLRequest in
                var request = URLRequest(url: url)
                if let modifiedHeader = self?.lastModified.value {
                    request.addValue(modifiedHeader, forHTTPHeaderField: "Last-Modified")
                }
                return request // If "events.json" is up-to-date (it checks using "modified.txt"), GitHub responses which don’t return any data won’t count towards your GitHub API usage limit.
        }
        .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
            return URLSession.shared.rx.response(request: request)
        }
        .share(replay: 1)
        /*
         .share(replay:scope:)
         
         scope:
         “The former will buffer elements up to the point where it has no subscribers, and the latter will keep the buffered elements forever. That sounds nice, but consider the implications on how much memory is used by the app.”
         
         Excerpt From: By Marin Todorov. “RxSwift - Reactive Programming with Swift.” Apple Books.
         */
        
        response
            .filter { response, _ in
                return 200..<300 ~= response.statusCode
        }
        .map { _, data -> [Chapter8Event] in
            let decoder = JSONDecoder()
            let events = try? decoder.decode([Chapter8Event].self, from: data)
            return events ?? []
        }
        .filter { objects in
            return !objects.isEmpty
        }
        .subscribe(
            onNext: { [weak self] newEvents in
                self?.processEvents(newEvents)
            }
        ).disposed(by: self.bag)
        
        // Get "Last-Modified" header String
        
        response
            .filter { response, _ in
                return 200..<400 ~= response.statusCode
        }
        .flatMap { response, _ -> Observable<String> in
            guard let value = response.allHeaderFields["Last-Modified"] as? String else {
                return Observable.empty()
            }
            return Observable.just(value)
        }
        .subscribe(
            onNext: { [weak self] modifiedHeader in
                guard let self = self else { return }
                
                self.lastModified.accept(modifiedHeader)
                try? modifiedHeader.write(to: self.modifiedFileURL, atomically: true, encoding: .utf8)
            }
        ).disposed(by: self.bag)
    }
    
    func processEvents(_ newEvents: [Chapter8Event]) {
        var updatedEvents = newEvents + events.value
        if updatedEvents.count > 50 {
            updatedEvents = [Chapter8Event](updatedEvents.prefix(upTo: 50))
        }
        events.accept(updatedEvents)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
        
        let encoder = JSONEncoder()
        if let eventsData = try? encoder.encode(updatedEvents) {
            try? eventsData.write(to: self.eventsFileURL, options: .atomicWrite)
        }
    }
    
    static func cachedFileURL(_ fileName: String) -> URL {
        return FileManager.default
            .urls(for: .cachesDirectory, in: .allDomainsMask)
            .first!
            .appendingPathComponent(fileName)
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.events.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = self.events.value[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = event.actor.name
        cell.detailTextLabel?.text = event.repo.name + ", " + event.action.replacingOccurrences(of: "Event", with: "").lowercased()
        cell.imageView?.kf.setImage(with: event.actor.avatar, placeholder: UIImage(named: "blank-avatar"))
        
        return cell
    }
}
