//
//  Weather.swift
//  WeatherAppExample
//
//  Created by Stanley Delacruz on 3/11/16.
//  Copyright © 2016 Delacruz Inc. All rights reserved.
//

import Foundation

struct Weather {
    let cityName: String
    let temp: Double
    let description: String
    let icon: String
    let cloud: Double
    let max: Double
    let low: Double
    
    
    init(city: String, temp: Double, desp: String, icon: String, cloud: Double, max: Double, low: Double) {
        cityName = city
        self.temp = temp
        description = desp
        self.icon = icon
        self.cloud = cloud
        self.max = max
        self.low = low
    }
}