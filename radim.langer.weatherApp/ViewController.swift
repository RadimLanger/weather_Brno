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
    var refreshControl: UIRefreshControl!
    
    // For quick future forecast
    
    @IBOutlet weak var firstForecastTitle: UILabel!
    @IBOutlet weak var firstForecastInfo: UILabel!
    @IBOutlet weak var firstForecastImg: UIImageView!
    
    
    @IBOutlet weak var secondForecastTitle: UILabel!
    @IBOutlet weak var secondForecastInfo: UILabel!
    @IBOutlet weak var secondForecastImg: UIImageView!
    
    
    @IBOutlet weak var thirdForecastTitle: UILabel!
    @IBOutlet weak var thirdForecastInfo: UILabel!
    @IBOutlet weak var thirdForecastImg: UIImageView!
    
    
    @IBOutlet weak var fourthForecastTitle: UILabel!
    @IBOutlet weak var fourthForecastInfo: UILabel!
    @IBOutlet weak var fourthForecastImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Creates pullToRefresh function
        createPullRefresh()
        
        // Notification for getting back from background
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        // Sets crollView content height to 1001, to enable scrolling, also the refreshing
        scrollView.contentSize.height = 2000

    }
    
    // Refresh app data after getting back from background
    func appDidBecomeActive(notification: NSNotification){
        getAllData()
    }

    // Gets all the data
    func getAllData(){
        // For getting current weather
        getWeatherData("https://api.wunderground.com/api/3d920a10506e59e6/conditions/q/CA/Brno.json")
        // For sunrise/sunset
        getWeatherData("https://api.wunderground.com/api/3d920a10506e59e6/astronomy/q/Brno.json")
        // For 3 day forecast
        getWeatherData("https://api.wunderground.com/api/3d920a10506e59e6/forecast/q/Brno.json")
    }

    // Creating function for refreshing data while pulling down the scrollView
    func createPullRefresh(){
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        self.scrollView.addSubview(refreshControl)
    }
    
    // Function for refreshing data after pulling down the
    func refreshData(sender:AnyObject){
        getAllData()
        self.refreshControl.endRefreshing()
    }

    
    // Parse and sets all the labels
    func setLabels(weatherData: NSData){
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(weatherData, options: []) as! NSDictionary
            
            // Parsing information about sunrise / sunset time
            
                if let b = json["sun_phase"] as? NSDictionary {
                    if let sunrise = b["sunrise"] as?  NSDictionary {
                        if let sunriseHour = sunrise["hour"] as? String {
                            if let sunriseMin = sunrise["minute"] as? String {
                                print("Sunrise: \(sunriseHour):\(sunriseMin)")
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
            
            // Parsing information about current weather

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
                        imgLabel.image = UIImage(named: setIcon(iconWeather))
                    }
            }
            
            // Parsing information about future weather
            
            if let forecast = json["forecast"] as? NSDictionary {
                if let future_forecast = forecast["txt_forecast"] as? NSDictionary {
                    if let forecast_day = future_forecast["forecastday"] as? NSArray {
                        if let firstForecast = forecast_day[0] as? NSDictionary{
                            if let icon = firstForecast["icon"] as? String{
                                firstForecastImg.image = UIImage(named: setIcon(icon))
                            }
                            if let title = firstForecast["title"] as? String{
                                firstForecastTitle.text = title
                            }
                            if let info = firstForecast["fcttext_metric"] as? String{
                                firstForecastInfo.text = info
                            }
                        }
                        if let secondtForecast = forecast_day[1] as? NSDictionary{
                            if let icon = secondtForecast["icon"] as? String{
                                secondForecastImg.image = UIImage(named: setIcon(icon))
                            }
                            if let title = secondtForecast["title"] as? String{
                                secondForecastTitle.text = title
                            }
                            if let info = secondtForecast["fcttext_metric"] as? String{
                                secondForecastInfo.text = info
                            }
                            
                        }
                        if let thirdForecast = forecast_day[2] as? NSDictionary{
                            if let icon = thirdForecast["icon"] as? String{
                                thirdForecastImg.image = UIImage(named: setIcon(icon))
                            }
                            if let title = thirdForecast["title"] as? String{
                                thirdForecastTitle.text = title
                            }
                            if let info = thirdForecast["fcttext_metric"] as? String{
                                thirdForecastInfo.text = info
                            }
                            
                        }
                        if let fourthForecast = forecast_day[3] as? NSDictionary{
                            if let icon = fourthForecast["icon"] as? String{
                                fourthForecastImg.image = UIImage(named: setIcon(icon))
                            }
                            if let title = fourthForecast["title"] as? String{
                                fourthForecastTitle.text = title
                            }
                            if let info = fourthForecast["fcttext_metric"] as? String{
                                fourthForecastInfo.text = info
                            }
                            
                        }
                        
                    }
                }
            }
            
            
            
        } catch {
                alert("JSON error", message: "Error occured while calling API")
        }
        
        
        
    }
    
    
    // If something wrong happends, alert is called
    func alert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // Setting icon depending on what icon is on their API
    func setIcon(weather: String)->String{
        if (weather.rangeOfString("flurries") != nil) || (weather.rangeOfString("snow") != nil){
            return "snow.png"
        } else if (weather.rangeOfString("rain") != nil){
            return "rain.png"
        } else if (weather.rangeOfString("sleet") != nil){
            return "sleet.png"
        } else if (weather.rangeOfString("storm") != nil){
            return "storm.png"
        } else if (weather.rangeOfString("nt_clear") != nil) || (weather.rangeOfString("nt_sunny") != nil){
            return "moon.png"
        } else if (weather.rangeOfString("clear") != nil) || (weather.rangeOfString("sunny") != nil){
            return "sun.png"
        } else if (weather.rangeOfString("cloudy") != nil){
            return "cloudy.png"
        } else if (weather.rangeOfString("fog") != nil) || (weather.rangeOfString("hazy") != nil){
            return "fog.png"
        } else if (weather.rangeOfString("nt_mostlycloudy") != nil) || (weather.rangeOfString("nt_mostlysunny") != nil) || (weather.rangeOfString("nt_partlycloudy") != nil) || (weather.rangeOfString("nt_partlysunny") != nil){
            return "moonCloudy.png"
        } else if (weather.rangeOfString("mostlycloudy") != nil) || (weather.rangeOfString("mostlysunny") != nil) || (weather.rangeOfString("partlycloudy") != nil) || (weather.rangeOfString("partlysunny") != nil){
            return "sunCloudy.png"
        } else {
            alert("Icon error", message: "Error occured while setting icon")
            return "error"
        }
    }

    
    // Gets all the data in differend thread
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

