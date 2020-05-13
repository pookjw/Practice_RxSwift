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
    private var cache = [String: Chapter14Weather]()
    
    var keyTextField: UITextField?
    
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
        
        keyButton.rx.tap
            .subscribe(onNext: {
                self.requestKey()
            })
            .disposed(by: bag)
        
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
        
        /*
         .catchErrorJustReturn(element:) -> If there's error, return element
         .catchError({SwiftError -> Observable}:) -> If there's error, return custom observable
         
         .retry() -> Retry infinitly until no error
         .retry(Int:) -> Retry Int times
         .retryWhen({Observable<Error> -> TriggerObservable}:) -> Retry with custom observable
         */
        
        let retryHandler: (Observable<Error>) -> Observable<Int> = { e in
            return e.enumerated().flatMap { attempt, error -> Observable<Int> in
                let maxAttempts = 3
                if attempt >= maxAttempts - 1 {
                    return Observable.error(error)
                }
                
                print("== retrying after \(attempt + 1) seconds ==")
                
                return Observable<Int>
                    .timer(Double(attempt+1), scheduler: MainScheduler.instance)
                    .take(1)
            }
        }
        
        let textSearch = searchInput.flatMap { text in
            return Chapter14ApiController.shared.currentWeather(city: text)
                .do(onNext: { data in
                    self.cache[text] = data
                },
                    onError: { e in
                        DispatchQueue.main.async {
                            self.showError(error: e)
                        }
                })
                /*
                 .retryWhen { e in
                 return e.enumerated().flatMap { attempt, error -> Observable<Int> in
                 let maxAttempts = 3
                 if attempt >= maxAttempts - 1 {
                 return Observable.error(error)
                 }
                 
                 print("== retrying after \(attempt + 1) seconds ==")
                 
                 return Observable<Int>
                 .timer(Double(attempt+1), scheduler: MainScheduler.instance)
                 .take(1)
                 }
                 }*/
                .retryWhen(retryHandler)
                .catchError { error in
                    guard let cachedData = self.cache[text] else {
                        return Observable.just(.dummy)
                    }
                    
                    return Observable.just(cachedData)
            }
            
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
    
    func requestKey() {
        func configurationTextField(textField: UITextField!) {
            self.keyTextField = textField
            self.keyTextField?.text = OpenWeatherApiKey
        }
        
        let alert = UIAlertController(title: "API Key",
                                      message: "Add the API ket:",
                                      preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField(configurationHandler: configurationTextField)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive))
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            Chapter14ApiController.shared.apiKey.onNext(self?.keyTextField?.text ?? "")
            }
        )
        
        self.present(alert, animated: true)
    }
    
    private func showError(error e: Error) {
        guard let e = e as? Chapter14ApiController.ApiError else {
            Chapter14InfoView.showIn(viewController: self, message: "An error occured")
            return
        }
        
        switch e {
        case .cityNotFound:
            Chapter14InfoView.showIn(viewController: self, message: "City Name is invalid")
        case .invalidKey:
            Chapter14InfoView.showIn(viewController: self, message: "Key is invalid")
        case .serverFailure:
            Chapter14InfoView.showIn(viewController: self, message: "Server error")
        }
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
