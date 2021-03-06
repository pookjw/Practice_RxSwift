//
//  Chapter14ApiController.swift
//  Practice_RxSwift
//
//  Created by pook on 5/3/20.
//  Copyright © 2020 pook. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation
import MapKit

typealias Chapter14Weather = Chapter14ApiController.Weather

class Chapter14ApiController {
    struct Weather: Decodable {
        let cityName: String
        let temperature: Int
        let humidity: Int
        let icon: String
        let coordinate: CLLocationCoordinate2D
        
        static let empty = Weather(
            cityName: "Unknown",
            temperature: -1000,
            humidity: 0,
            icon: iconNameToChar(icon: "e"),
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
        )
        
        static let dummy = Weather(
            cityName: "RxCity",
            temperature: 20,
            humidity: 90,
            icon: iconNameToChar(icon: "01d"),
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
        )
        
        init(cityName: String, temperature: Int, humidity: Int, icon: String, coordinate: CLLocationCoordinate2D) {
            self.cityName = cityName
            self.temperature = temperature
            self.humidity = humidity
            self.icon = icon
            self.coordinate = coordinate
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            cityName = try values.decode(String.self, forKey: .cityName)
            let info = try values.decode([AdditionalInfo].self, forKey: .weather)
            icon = iconNameToChar(icon: info.first?.icon ?? "")
            
            let mainInfo = try values.nestedContainer(keyedBy: MainKeys.self, forKey: .main)
            temperature = Int(try mainInfo.decode(Double.self, forKey: .temp))
            humidity = try mainInfo.decode(Int.self, forKey: .humidity)
            
            let coordinate = try values.decode(Coordinate.self, forKey: .coordinate)
            self.coordinate = CLLocationCoordinate2D(latitude: coordinate.lat, longitude: coordinate.lon)
        }
        
        enum CodingKeys: String, CodingKey {
            case cityName = "name"
            case main
            case weather
            case coordinate = "coord"
        }
        
        enum MainKeys: String, CodingKey {
            case temp
            case humidity
        }
        
        private struct AdditionalInfo: Decodable {
            let id: Int
            let main: String
            let description: String
            let icon: String
        }
        
        private struct Coordinate: Decodable {
            let lat: CLLocationDegrees
            let lon: CLLocationDegrees
        }
    }
    
    enum ApiError: Error {
        case cityNotFound
        case serverFailure
        case invalidKey
    }
    
    /// The shared instance
    static var shared = Chapter14ApiController()
    
    /// The api key to communicate with openweathermap.org
    /// Create you own on https://home.openweathermap.org/users/sign_up
    let apiKey = BehaviorSubject(value: OpenWeatherApiKey)
    
    /// API base URL
    let baseURL = URL(string: "http://api.openweathermap.org/data/2.5")!
    
    init() {
        Logging.URLRequests = { request in
            return true
        }
    }
    
    // MARK: - Api Calls
    func currentWeather(city: String) -> Observable<Weather> {
        return buildRequest(pathComponent: "weather", params: [("q", city)])
            .map { data in
                let decoder = JSONDecoder()
                return try decoder.decode(Weather.self, from: data)
        }
    }
    
    func currentWeather(at coordinate: CLLocationCoordinate2D) -> Observable<Weather> {
        return buildRequest(
            pathComponent: "weather",
            params: [
                ("lat", "\(coordinate.latitude)"),
                ("lon", "\(coordinate.longitude)")
            ]
        )
            .map { data in
                let decoder = JSONDecoder()
                return try decoder.decode(Weather.self, from: data)
        }
    }
    
    // MARK: - Private Methods
    private func buildRequest(method: String = "GET", pathComponent: String, params: [(String, String)]) -> Observable<Data> {
        let url = baseURL.appendingPathComponent(pathComponent)
        var request = URLRequest(url: url)
        let keyQueryItem = URLQueryItem(name: "appid", value: try? self.apiKey.value())
        let unitsQueryItem = URLQueryItem(name: "units", value: "metric")
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        if method == "GET" {
            var queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
            queryItems.append(keyQueryItem)
            queryItems.append(unitsQueryItem)
            urlComponents.queryItems = queryItems
        } else {
            urlComponents.queryItems = [keyQueryItem, unitsQueryItem]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request.httpBody = jsonData
        }
        
        request.url = urlComponents.url!
        request.httpMethod = method
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        
        return session.rx.response(request: request).map { response, data in
            switch response.statusCode {
            case 200..<300:
                return data
            case 401:
                throw ApiError.invalidKey
            case 400..<500:
                throw ApiError.cityNotFound
            default:
                throw ApiError.serverFailure
            }
            
        }
    }
    
    /**
     * Maps an icon information from the API to a local char
     * Source: http://openweathermap.org/weather-conditions
     */
    static func iconNameToChar(icon: String) -> String {
        switch icon {
        case "01d":
            return "\u{f11b}"
        case "01n":
            return "\u{f110}"
        case "02d":
            return "\u{f114}"
        case "02n":
            return "\u{f104}"
        case "03d", "03n":
            return "\u{f111}"
        case "04d", "04n":
            return "\u{f111}"
        case "09d", "09n":
            return "\u{f116}"
        case "10d", "10n":
            return "\u{f114}"
        case "11d", "11n":
            return "\u{f10d}"
        case "14d", "14n":
            return "\u{f119}"
        case "50d", "50n":
            return "\u{f10e}"
        default:
            return "E"
        }
    }
    
    static func imageFromText(text: String, font: UIFont) -> UIImage {
        let size = text.size(withAttributes: [NSAttributedString.Key.font: font])
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        text.draw(at: CGPoint(x: 0, y: 0), withAttributes: [NSAttributedString.Key.font: font])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
}
