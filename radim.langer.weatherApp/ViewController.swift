//
//  ViewController.swift
//  radim.langer.weatherApp
//
//  Created by Radim Langer on 12/01/16.
//  Copyright © 2016 Radim Langer. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var imgLabel: UIImageView!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var humidLabel: UILabel!
    @IBOutlet weak var visibLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var speedDirLabel: UILabel!
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getAllData()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize.height = 1001
        // Do any additional setup after loading the view, typically from a nib.
        getAllData()
    }

    func getAllData(){
        // For getting current weather
        getWeatherData("https://api.wunderground.com/api/3d920a10506e59e6/conditions/q/CA/Brno.json")
        // For sunrise/sunset
        getWeatherData("https://api.wunderground.com/api/3d920a10506e59e6/astronomy/q/Brno.json")
        // Hourly information
        getWeatherData("http://api.wunderground.com/api/3d920a10506e59e6/hourly/q/Brno.json")
        // For 3 day forecast
        getWeatherData("http://api.wunderground.com/api/3d920a10506e59e6/forecast/q/Brno.json")
        
    }
    
    
    
    
    func setLabels(weatherData: NSData){
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(weatherData, options: []) as! NSDictionary
            
            
                if let b = json["sun_phase"] as? NSDictionary {
                    if let sunrise = b["sunrise"] as?  NSDictionary {
                        if let sunriseHour = sunrise["hour"] as? String {
                            if let sunriseMin = sunrise["minute"] as? String {
                                //print("Sunrise: \(sunriseHour):\(sunriseMin)")
                                sunriseLabel.text = "\(sunriseHour):\(sunriseMin)"
                            }
                        }
                    }
                    
                    if let sunset = b["sunset"] as? NSDictionary {
                        if let sunsetHour = sunset["hour"] as? String {
                            if let sunsetMin = sunset["minute"] as? String {
                                //print("Sunset: \(sunsetHour):\(sunsetMin)")
                                sunsetLabel.text = "\(sunsetHour):\(sunsetMin)"
                            }
                        }
                    }
                }
            
            
                if let a = json["current_observation"] as? NSDictionary{
                    // For current weather situation
                    if let weatherSituation = a["weather"] as? String {
                        //print("Current weather:    \(weatherSituation)")
                        currentLabel.text = weatherSituation
                    }
                    // For current temperature in °C
                    if let temp_c = a["temp_c"] as? Int {
                        //print("Temperature now:    \(temp_c) °C")
                        tempLabel.text = "\(temp_c)"
                    }
                    // For temperatureThatFeelsLike in °C
                    if let feelsLike = a["feelslike_c"] as? String {
                        //print("Feels like: \(feelsLike) °C")
                        feelsLikeLabel.text = "\(feelsLike) °C"
                    }
                    // For current humidity in %
                    if let humidity = a["relative_humidity"] as? String {
                        //print("Humidity:        \(humidity)")
                        humidLabel.text = humidity
                    }
                    //
                    if let windDir = a["wind_dir"] as? String {
                        if let windKph = a["wind_kph"] as? Int {
                            //print("Wind speed \(windKph) km/h and direction: \(windDir)")
                            speedDirLabel.text = "\(windKph) km/h \(windDir)"
                        }
                    }
                    if let visibilityKm = a["visibility_km"] as? String {
                        //print("Visibility is: \(visibilityKm) km")
                        visibLabel.text = "\(visibilityKm) km"
                    }
                    // For current weather icon
                    if let iconWeather = a["icon_url"] as? String {
                        //print(iconWeather)
                        setIcon(iconWeather)
                    }
            }
            
        } catch {
                alert("JSON error", message: "Error occured while calling API")
        }
        
        
        
    }
    
    func alert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func setIcon(weather: String){
        if (weather.rangeOfString("flurries") != nil) || (weather.rangeOfString("snow") != nil){
            imgLabel.image = UIImage(named: "snow.png")
        } else if (weather.rangeOfString("rain") != nil){
            imgLabel.image = UIImage(named: "rain.png")
        } else if (weather.rangeOfString("sleet") != nil){
            imgLabel.image = UIImage(named: "sleet.png")
        } else if (weather.rangeOfString("storm") != nil){
            imgLabel.image = UIImage(named: "storm.png")
        } else if (weather.rangeOfString("nt_clear") != nil) || (weather.rangeOfString("nt_sunny") != nil){
            imgLabel.image = UIImage(named: "moon.png")
        } else if (weather.rangeOfString("clear") != nil) || (weather.rangeOfString("sunny") != nil){
            imgLabel.image = UIImage(named: "sun.png")
        } else if (weather.rangeOfString("cloudy") != nil){
            imgLabel.image = UIImage(named: "cloudy.png")
        } else if (weather.rangeOfString("fog") != nil) || (weather.rangeOfString("hazy") != nil){
            imgLabel.image = UIImage(named: "fog.png")
        } else if (weather.rangeOfString("nt_mostlycloudy") != nil) || (weather.rangeOfString("nt_mostlysunny") != nil) || (weather.rangeOfString("nt_partlycloudy") != nil) || (weather.rangeOfString("nt_partlysunny") != nil){
            imgLabel.image = UIImage(named: "moonCloudy.png")
        } else if (weather.rangeOfString("mostlycloudy") != nil) || (weather.rangeOfString("mostlysunny") != nil) || (weather.rangeOfString("partlycloudy") != nil) || (weather.rangeOfString("partlysunny") != nil){
            imgLabel.image = UIImage(named: "sunCloudy.png")
        }  else {
            alert("Icon error", message: "Error occured while setting icon")
        }
    }
    
    
    func getWeatherData(urlString: String){
        let url = NSURL(string: urlString)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
            dispatch_sync(dispatch_get_main_queue(), { self.setLabels(data!) } )
        }
        task.resume()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

