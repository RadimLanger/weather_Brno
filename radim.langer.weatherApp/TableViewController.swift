//
//  TableView.swift
//  radim.langer.weatherApp
//
//  Created by Radim Langer on 09/02/16.
//  Copyright © 2016 Radim Langer. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore


var headerView: UIView!
private let kTableHeaderHeight: CGFloat = 400.0


class TableViewController: UITableViewController {
    
    
    @IBOutlet weak var speedDirWindLabel: UILabel!
    @IBOutlet weak var currentWeatherLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var imgHeaderView: UIImageView!
    
    // We're not setting these labels, we just need to se the round corners to it
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var feelsLabel: UILabel!
    @IBOutlet weak var humidLabel: UILabel!
    @IBOutlet weak var visibLabel: UILabel!
    @IBOutlet weak var sunLabel: UILabel!
    @IBOutlet weak var setLabel: UILabel!
    

    var forecastArray = [NewsForecastItem]()
    
    // Computed property for knowing if it's night already or not
    var isNight: Int {
        set{
            return
        }
        get {
            return forecastNight()
        }
    }
    

    
    override func prefersStatusBarHidden() -> Bool{
        return true
    }

    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateHeaderView()
    }

    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: tableView.bounds.width, height: kTableHeaderHeight)
        if tableView.contentOffset.y < -kTableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        
        headerView.frame = headerRect
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil

        tableView.addSubview(headerView)

        tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
        updateHeaderView()

        // Creates pullToRefresh function
        createPullRefresh()
        
        //let view1 = UIView(frame: CGRectMake(10, 50, 50, 50))
        //view1.backgroundColor = UIColor.redColor()
        //view.addSubview(view1)

        
        // Notification for getting back from background
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        roundLabels()
        
    }

    
    func roundLabels() {
        roundLabel(windLabel)
        roundLabel(feelsLabel)
        roundLabel(humidLabel)
        roundLabel(visibLabel)
        roundLabel(sunLabel)
        roundLabel(setLabel)
        roundLabel(sunriseLabel)
        roundLabel(sunsetLabel)
        roundLabel(feelsLikeLabel)
        roundLabel(humidityLabel)
        roundLabel(visibilityLabel)
        roundLabel(speedDirWindLabel)
    }

    // Setting color and round corners of text labels
    func roundLabel(label: UILabel) {
        label.layer.backgroundColor  = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.7).CGColor
        label.layer.cornerRadius = 10
    }
    
    
    // Refresh app data after getting back from background
    func appDidBecomeActive(notification: NSNotification){
        getAllData()
    }
    
    // Gets all the data
    func getAllData(){
                                                        //32ca3e99da3f6f09 API KEY
        // For getting current weather
        getWeatherData("https://api.wunderground.com/api/32ca3e99da3f6f09/conditions/q/CA/Brno.json")
        // For sunrise/sunset
        getWeatherData("https://api.wunderground.com/api/32ca3e99da3f6f09/astronomy/q/Brno.json")
        // For 3 day forecast
        getWeatherData("https://api.wunderground.com/api/32ca3e99da3f6f09/forecast/q/Brno.json")
    }
    
    // Creating function for refreshing data while pulling down the scrollView
    func createPullRefresh(){
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.tintColor = UIColor.whiteColor()
        self.refreshControl!.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
    }
    
    // Function for refreshing data after pulling down the
    func refreshData(sender:AnyObject){
        getAllData()
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
                    currentWeatherLabel.text = weatherSituation
                    
                }
                // For current temperature in °C
                if let temp_c = a["temp_c"] as? Int {
                    //print("Temperature now:    \(temp_c) °C")
                    currentTempLabel.text = "\(temp_c)°"
                    
                }
                // For temperatureThatFeelsLike in °C
                if let feelsLike = a["feelslike_c"] as? String {
                    //print("Feels like: \(feelsLike) °C")
                    feelsLikeLabel.text = "\(feelsLike)°"
                    
                }
                // For current humidity in %
                if let humidity = a["relative_humidity"] as? String {
                    //print("Humidity:        \(humidity)")
                    humidityLabel.text = humidity
                    
                }
                // for current Wind direction and wind speed
                if let windDir = a["wind_dir"] as? String {
                    if let windKph = a["wind_kph"] as? Int {
                        //print("Wind speed \(windKph) km/h and direction: \(windDir)")
                        speedDirWindLabel.text = "\(windKph) km/h \(windDir)"
                    }
                }
                if let visibilityKm = a["visibility_km"] as? String {
                    //print("Visibility is: \(visibilityKm) km")
                    visibilityLabel.text = "\(visibilityKm) km"
                }
                // For current weather icon
                if let headerImg = a["icon_url"] as? String {
                    imgHeaderView.image = UIImage(named: setIcon(substringLink(headerImg)).1)
                }
            }
            
            // Parsing information about future weather
            
            if let forecast = json["forecast"] as? NSDictionary {
                if let future_forecast = forecast["txt_forecast"] as? NSDictionary {
                    if let forecast_day = future_forecast["forecastday"] as? NSArray {
                        forecastArray = []
                        for i in isNight...(isNight+4) {
                            if let firstForecast = forecast_day[i] as? NSDictionary{
                                if let icon = firstForecast["icon"] as? String{
                                    if let title = firstForecast["title"] as? String{
                                        if let info = firstForecast["fcttext_metric"] as? String{
                                            forecastArray.append(NewsForecastItem(title: title, image: setIcon(icon).0, summary: info))
                                            // To this point we were downloading/parsing data, we can stop animating the activity indicator
                                            self.refreshControl!.endRefreshing()
                                            tableView.reloadData()
                                        }
                                    }
                                }
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

        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // Getting current hour in europe format and comparing if it's night already
    func forecastNight()->Int{
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour], fromDate: date)
        let hour = components.hour
        
        if (hour>18){
            return 1
        } else {
            return 0
        }
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
    func setIcon(weather: String)->(icon: String, picture: String){
        switch(weather){
        case "flurries","snow","chanceflurries","chancesnow","nt_chanceflurries","nt_chancesnow","nt_flurries","nt_snow":
            return ("snow.png", "imgSnow.png")
            
        case "rain","chancerain","nt_chancerain","nt_rain":
            return ("rain.png","imgRain.png")
            
        case "sleet","chancesleet","nt_chancesleet","nt_sleet":
            return ("sleet.png","imgSleet.png")
            
        case "tstorms","chancetstorms","nt_chancetstorms","nt_tstorms":
            return ("storm.png","imgStorm.png")
            
        case "nt_clear","nt_sunny":
            return ("moon.png","imgMoony.png")
            
        case "clear","sunny":
            return ("sun.png","imgSunny.png")
            
        case "cloudy","nt_cloudy":
            return ("cloudy.png","imgCloudy.png")
            
        case "fog","hazy","nt_fog","nt_hazy":
            return ("fog.png","imgFoggy.png")
            
        case "nt_mostlycloudy","nt_mostlysunny","nt_partlycloudy","nt_partlysunny":
            return ("moonCloudy.png","imgMoonCloudy.png")
            
        case "mostlycloudy","mostlysunny","partlycloudy","partlysunny":
            return ("sunCloudy.png","imgSunCloudy.png")
            
            
        default:    alert("Icon error", message: "Error occured while setting icon")
        return ("error","error")
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

    
    
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let item = forecastArray[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NewsItemForecast
        
        cell.newsForecastItem = item
        
        return cell
    }

}