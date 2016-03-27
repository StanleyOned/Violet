//
//  ViewController.swift
//  Violet
//
//  Created by Stanley Delacruz on 3/11/16.
//  Copyright © 2016 Delacruz Inc. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var lowest: UILabel!
    @IBOutlet weak var highest: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var temp: UILabel!
    var didTouch = false
    let weatherService = WeatherService()
    var locationGot = ""
    
    //location
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: NSError?
    
    //geocoding var
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImage.layer.backgroundColor = UIColor(white: 0.8, alpha: 0.3).CGColor
        backgroundView.layer.backgroundColor = UIColor.clearColor().colorWithAlphaComponent(0.5).CGColor
        weatherService.delegate = self
        getLocation()
        
    }
    
    func getLocation() {
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
            return
        }
        
        if authStatus == .Denied || authStatus == .Restricted {
            denied()
        }
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
        
    }
    
    func denied() {
        //JSAlertViewController
        let alert = UIAlertController(title: "Location Service Disabled", message: "Please enable your location for this app in Settings.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        didTouch = !didTouch
        
        if didTouch {
            UIView.animateWithDuration(0.5, delay: 0, options: [UIViewAnimationOptions.CurveEaseInOut], animations: {
                self.backgroundView.layer.opacity = 0
                }, completion: nil)
        } else {
            UIView.animateWithDuration(0.5, delay: 0, options: [UIViewAnimationOptions.CurveEaseInOut], animations: {
                self.backgroundView.layer.opacity = 1.0
                }, completion: nil)
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    func startLocationManager() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            updatingLocation = true
        }
    }
    
    func updateLabels() {
        if let _ = location {
            if let placemark = placemark {
                locationGot = placemark.locality!
                self.weatherService.getWeather(locationGot)
                
                //JSAlertView
                
            } else {
                // city not found.
            }
        }
    }

}

extension WeatherViewController: WeatherServiceDelegate {
    func weatherErrorWithMessage(message: String) {
        //JAlertViewController
        print("weather hey")
    }
    
    func setWeather(weather: Weather) {
        let temper = Int(1.8 * (weather.temp - 273) + 32)
        desc.text = weather.description
        temp.text = String(temper) + "°"
        cityName.text = weather.cityName
        highest.text = String(Int(1.8 * (weather.max - 273) + 32)) + "°"
        lowest.text = String(Int(1.8 * (weather.low - 273) + 32)) + "°"
    }
    
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("location error")
        
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        stopLocationManager()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        lastLocationError = nil
        //location = newLocation
        //update weather. labels
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        //2
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        if location == nil || location?.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            //update labels, weather
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                stopLocationManager()
            }
            
            if !performingReverseGeocoding {
                //start geocoding
                performingReverseGeocoding = true
                
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: { placemarks, error in
                
                    self.lastGeocodingError = error
                    
                    if error == nil, let p = placemarks where !p.isEmpty {
                        self.placemark = p.last
                    } else {
                        self.placemark = nil
                    }
                    
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
        }
        
    }
}

