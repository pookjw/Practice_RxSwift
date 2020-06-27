//
//  ViewController.swift
//  Practice_RxSwift2
//
//  Created by pook on 6/25/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let lastFoo = Practice.last else { return }
        let (name, foo): (String, () -> ()) = lastFoo
        print("===== \(name) =====")
        foo()
    }

    private func setupUI() {
        self.title = "Practice_RxSwift2"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(rightButtonAction(_:)))
        self.navigationItem.rightBarButtonItem?.tintColor = .red
        self.view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    @objc private func rightButtonAction(_ sender: UIBarButtonItem) {
        disposeBag = DisposeBag()
        print("Disposed all!")
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Practice.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = Practice[indexPath.row].name
        cell.textLabel?.textColor = self.view.tintColor
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (name, foo): (String, () -> ()) = Practice[indexPath.row]
        print("===== \(name) =====")
        foo()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
