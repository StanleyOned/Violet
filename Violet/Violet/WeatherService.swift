//
//  WeatherService.swift
//  WeatherAppExample
//
//  Created by Stanley Delacruz on 3/11/16.
//  Copyright © 2016 Delacruz Inc. All rights reserved.
//

import Foundation

protocol WeatherServiceDelegate: class {
    func setWeather(weather: Weather)
    func weatherErrorWithMessage(message: String)
}

class WeatherService {
    var delegate: WeatherServiceDelegate?
    
    func getWeather(city: String) {
        //get weather data from weather api
        let cityEscape = city.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let path = "http://api.openweathermap.org/data/2.5/weather?q=\(cityEscape!)&appid=553f36b39fae351d08ceae9570aefad3"
        let url = NSURL(string: path)
        let session = NSURLSession.sharedSession() //reference to our session
        let task =  session.dataTaskWithURL(url!) { (data: NSData?, response:NSURLResponse?, error: NSError?) -> Void in
        
            //if let httpresponse = response as? NSHTTPURLResponse {
                
           // }
            
            let json = JSON(data: data!)
            
            //check for status code.
            var status = 0
            if let cod = json["cod"].int {
                status = cod
            } else if let cod = json["cod"].string {
                status = Int(cod)!
            }
            
            if status == 200 {
                
                let temp = json["main"]["temp"].double
                let name = json["name"].string //city
                let desp = json["weather"][0]["description"].string
                let icon = json["weather"][0]["icon"].string
                let cloud = json["clouds"]["all"].double
                let max = json["main"]["temp_max"].double
                let low = json["main"]["temp_min"].double
                
                print("\(max) low: \(low)")
                
                let weather = Weather(city: name!, temp: temp!, desp: desp!, icon: icon!,cloud: cloud!, max: max!, low: low!)
                print("temp: \(temp), city: \(city)")
                if self.delegate != nil {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        _ in
                        self.delegate?.setWeather(weather)
                    })
                    
                    
                }
            } else if status == 404 {
                //city not found
                dispatch_async(dispatch_get_main_queue(), {
                    _ in
                self.delegate?.weatherErrorWithMessage("City not found!")
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    _ in
                self.delegate?.weatherErrorWithMessage("Something went wrong, please check your internet connection")
                })
            }
         
        }
        task.resume() // start the task...
        
        //request weather data
        //then wait..
        //process data
        
       // let weather = Weather(city: city, temp: 237.12, desp: "A nice day")
        
       // delegate?.setWeather(weather)
    }
}