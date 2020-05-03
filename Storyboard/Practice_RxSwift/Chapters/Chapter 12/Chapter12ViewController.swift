//
//  Chapter12ViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 5/3/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Chapter12ViewController: UIViewController {
    @IBOutlet var searchCityName: UITextField!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var iconLabel: UILabel!
    @IBOutlet var cityNameLabel: UILabel!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        
        /*
         Chapter12ApiController.shared.currentWeather(city: "Irvine")
         .observeOn(MainScheduler.instance)
         .subscribe(onNext: { data in
         self.tempLabel.text = "\(data.temperature)° C"
         self.iconLabel.text = data.icon
         self.humidityLabel.text = "\(data.humidity)%"
         self.cityNameLabel.text = data.cityName
         }
         ).disposed(by: self.bag)
         
         let search = searchCityName.rx.text.orEmpty
         .filter { !$0.isEmpty }
         .flatMapLatest { text in
         return Chapter12ApiController.shared.currentWeather(city: text)
         .catchErrorJustReturn(Chapter12ApiController.Weather.empty)
         }
         .share(replay: 1)
         .observeOn(MainScheduler.instance)
         
         search.map { "\($0.temperature)° C" }
         .bind(to: tempLabel.rx.text)
         .disposed(by: bag)
         search.map { "\($0.icon)" }
         .bind(to: iconLabel.rx.text)
         .disposed(by: bag)
         search.map { "\($0.humidity)%" }
         .bind(to: humidityLabel.rx.text)
         .disposed(by: bag)
         search.map { "\($0.cityName)" }
         .bind(to: cityNameLabel.rx.text)
         .disposed(by: bag)
         */
        
        let initial = Chapter12ApiController.shared.currentWeather(city: "Irvine")
            .asDriver(onErrorJustReturn: Chapter12ApiController.Weather.empty)
        
        initial.map { "\($0.temperature)° C" }
            .drive(tempLabel.rx.text)
            .disposed(by: bag)
        initial.map { "\($0.icon)" }
            .drive(iconLabel.rx.text)
            .disposed(by: bag)
        initial.map { "\($0.humidity)%" }
            .drive(humidityLabel.rx.text)
            .disposed(by: bag)
        initial.map { "\($0.cityName)" }
            .drive(cityNameLabel.rx.text)
            .disposed(by: bag)
        
        let search = searchCityName.rx.controlEvent(.editingDidEndOnExit)
            .map { self.searchCityName.text ?? "" }
            .filter { !$0.isEmpty }
            .flatMapLatest { text in
                return Chapter12ApiController.shared.currentWeather(city: text)
        }
        .asDriver(onErrorJustReturn: Chapter12ApiController.Weather.empty)
        
        search.map { "\($0.temperature)° C" }
            .drive(tempLabel.rx.text)
            .disposed(by: bag)
        search.map { "\($0.icon)" }
            .drive(iconLabel.rx.text)
            .disposed(by: bag)
        search.map { "\($0.humidity)%" }
            .drive(humidityLabel.rx.text)
            .disposed(by: bag)
        search.map { "\($0.cityName)" }
            .drive(cityNameLabel.rx.text)
            .disposed(by: bag)
    }
    
    
    // MARK: - Style
    private func style() {
        view.backgroundColor = UIColor.aztec
        searchCityName.textColor = UIColor.ufoGreen
        tempLabel.textColor = UIColor.cream
        humidityLabel.textColor = UIColor.cream
        iconLabel.textColor = UIColor.cream
        cityNameLabel.textColor = UIColor.cream
    }
}
