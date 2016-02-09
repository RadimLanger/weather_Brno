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
        
        // Sets crollView content height to specific number, depends which device you're using, to enable scrolling, also the refreshing
//        setScrollViewHeight()
        scrollView.contentSize.height = 1300
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //print(self.view.frame.size.height)

    }
    
    
    // Refresh app data after getting back from background
    func appDidBecomeActive(notification: NSNotification){
        getAllData()
    }

    // Gets all the data
    func getAllData(){
        // For getting current weather
        getWeatherData("https://api.wunderground.com/api/32ca3e99da3f6f09/conditions/q/CA/Brno.json")
        // For sunrise/sunset
        getWeatherData("https://api.wunderground.com/api/32ca3e99da3f6f09/astronomy/q/Brno.json")
        // For 3 day forecast
        getWeatherData("https://api.wunderground.com/api/bf53178fe77e23cb/forecast/q/Brno.json")
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

    func setScrollViewHeight(){
        switch UIDevice.currentDevice().modelName{
        case "iPhone 6":
            scrollView.contentSize.height = 1300
            break

        default: break
        }

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
                        imgLabel.image = UIImage(named: setIcon(substringLink(iconWeather)))
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
            
            
            // Parsing json to see if there is an error, maybe invalid API key
            if let checkingError = json["response"] as? NSDictionary{
                if let error = checkingError["error"] as? NSDictionary{
                    if let type = error["type"] as? String{
                        if let desc = error["description"] as? String{
                            alert(type, message: desc)
                        }
                    }
                }
            }
        } catch {
                alert("JSON error", message: "Error occured while calling API")
        }
        
        
        
    }
    
    
    // If something wrong happends, alert with info is called
    func alert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // Function to substring link, to get name of picture
    func substringLink(fullLink: String)->String{
        let delete1 = fullLink.rangeOfString("/", options: .BackwardsSearch)?.startIndex
        let slashGifLink = fullLink.substringFromIndex(delete1!)
        let delete2 = slashGifLink.startIndex.advancedBy(1)
        let gifLink = slashGifLink.substringFromIndex(delete2)
        let delete3 = gifLink.endIndex.advancedBy(-4)
        let nameOfPicture = gifLink.substringToIndex(delete3)
        return nameOfPicture
    }
    
    
    // Setting icon depending on what icon is on their API
    func setIcon(weather: String)->String{
        switch(weather){
            case "flurries","snow","chanceflurries","chancesnow","nt_chanceflurries","nt_chancesnow","nt_flurries","nt_snow":
                return "snow.png"
            
            case "rain","chancerain","nt_chancerain","nt_rain":
                return "rain.png"
            
            case "sleet","chancesleet","nt_chancesleet","nt_sleet":
                return "sleet.png"
            
            case "tstorms","chancetstorms","nt_chancetstorms","nt_tstorms":
                return "storm.png"
            
            case "nt_clear","nt_sunny":
                return "moon.png"
            
            case "clear","sunny":
                return "sun.png"
            
            case "cloudy","nt_cloudy":
                return "cloudy.png"
            
            case "fog","hazy","nt_fog","nt_hazy":
                return "fog.png"
            
            case "nt_mostlycloudy","nt_mostlysunny","nt_partlycloudy","nt_partlysunny":
                return "moonCloudy.png"
            
            case "mostlycloudy","mostlysunny","partlycloudy","partlysunny":
                return "sunCloudy.png"

            
        default:    alert("Icon error", message: "Error occured while setting icon")
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

