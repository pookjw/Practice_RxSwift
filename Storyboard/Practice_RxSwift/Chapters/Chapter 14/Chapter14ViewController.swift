//
//  Chapter14ViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 5/3/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit
import CoreLocation

class Chapter14ViewController: UIViewController {
    
    @IBOutlet var keyButton: UIButton!
    @IBOutlet var geoLocationButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var searchCityName: UITextField!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var iconLabel: UILabel!
    @IBOutlet var cityNameLabel: UILabel!
    
    private let locationManager = CLLocationManager()
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initial = Chapter14ApiController.shared.currentWeather(city: "Busan")
            .asDriver(onErrorJustReturn: Chapter14ApiController.Weather.empty)
        
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
        
        //
        
        style()
        
        //
        
        let currentLocation = locationManager.rx.didUpdateLocations
            .map { locations in locations[0] }
            .filter { location in
                return location.horizontalAccuracy < kCLLocationAccuracyHundredMeters
        }
        
        let geoInput = geoLocationButton.rx.tap.asObservable()
            .do(onNext: {
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.startUpdatingLocation()
            }
        )
        
        let geoLocation = geoInput.flatMap {
            return currentLocation.take(1)
        }
        
        let geoSearch = geoLocation.flatMap { location -> Observable<Chapter14ApiController.Weather> in
            return Chapter14ApiController.shared.currentWeather(at: location.coordinate)
                .catchErrorJustReturn(.dummy)
        }
        
        let searchInput = searchCityName.rx.controlEvent(.editingDidEndOnExit)
            .map { self.searchCityName.text ?? "" }
            .filter { !$0.isEmpty }
        
        let textSearch = searchInput.flatMap { text in
            return Chapter14ApiController.shared.currentWeather(city: text)
                .catchErrorJustReturn(.dummy)
        }
        
        let search = Observable
            .merge(geoSearch, textSearch)
            .asDriver(onErrorJustReturn: .dummy)
        
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
        
        //
        
        
        let running = Observable.merge(
            searchInput.map { _ in true },
            geoInput.map { _ in true },
            search.map { _ in false}.asObservable()
        )
            //.startWith(true)
            .asDriver(onErrorJustReturn: false)
        
        running
            //.skip(1)
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: bag)
        
        running
            .drive(tempLabel.rx.isHidden)
            .disposed(by: bag)
        
        running
            .drive(humidityLabel.rx.isHidden)
            .disposed(by: bag)
        
        running
            .drive(cityNameLabel.rx.isHidden)
            .disposed(by: bag)
        
        //
        
        /*
         geoLocationButton.rx.tap
         .subscribe(onNext: { [weak self] _ in
         guard let self = self else {return}
         
         self.locationManager.requestWhenInUseAuthorization()
         self.locationManager.startUpdatingLocation()
         }
         )
         .disposed(by: bag)
         
         locationManager.rx.didUpdateLocations // You can check this rx extension.
         .subscribe(onNext: { locations in
         print(locations)
         }
         )
         .disposed(by: bag)
         */
        
        //
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
