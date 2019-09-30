//
//  WeatherViewController.swift
//  Clima
//
//  Created by Esmaeil MIRZAEE on 2019-09-22.
//  Copyright © 2019 Esmaeil MIRZAEE. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "894f130231441d5e5b0c37596bc79c58"
    
    // Declaring instance variable here
    let locationManager = CLLocationManager()
    
    
    // weatherDataModel object
    let weatherDataModel = WeatherDataModel()
    // Pre-linked IBOutlets
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up location manager
        locationManager.delegate = self
        
        // Choose suitable acciracy considering your application responsiblity
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        // Asking for consent
        locationManager.requestWhenInUseAuthorization()
        
        
    }
    
    //MARK: - Networking
    func getWeatherData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                let weatherJSON: JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                print(weatherJSON)
            } else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issue"
            }
        }
    }
    
    
    //MARK: - JSON Parsing
    // the updateWeatherData method
    func updateWeatherData(json: JSON) {
        if json["main"]["temp"].double != nil {
            weatherDataModel.temperature = Int(json["main"]["temp"].double! - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        } else {
            cityLabel.text = "Weather unavailable! ☹️"
        }
    }
    
    //MARK: - UI Update
    // the updateUIWithWeatherData method
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature)
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    //MARK: - Location Manager Delegate Methods
    // the didUpdateLocations method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 1 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let params: [String:String] = ["lat": String(location.coordinate.latitude), "lang": String(location.coordinate.longitude), "appid": APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params)
        } else {
            cityLabel.text = "Unvalid location"
        }
    }
    
    // the didFailWithError method
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location's unavailable! 😔"
    }
    
    
    //MARK: - Change City Delegate methods
    // the userEnteredANewCityName Delegate Method
    
    // the PrepareForSegure Method
    
}
