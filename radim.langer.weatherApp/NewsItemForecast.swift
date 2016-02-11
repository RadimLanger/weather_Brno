//
//  NewsItemForecast.swift
//  radim.langer.weatherApp
//
//  Created by Radim Langer on 09/02/16.
//  Copyright © 2016 Radim Langer. All rights reserved.
//

import UIKit

// Class which is setting labels and images

class NewsItemForecast: UITableViewCell {
    
    
    @IBOutlet weak var forecastImgLabel: UIImageView!
    @IBOutlet weak var forecastTitleLabel: UILabel!
    @IBOutlet weak var forecastInfoLabel: UILabel!
    
    var newsForecastItem: NewsForecastItem? {
        didSet {
            if let item = newsForecastItem {
                forecastTitleLabel.text = item.title
                forecastImgLabel.image = UIImage(named: item.image)
                forecastInfoLabel.text = item.summary
            }
            else {
                forecastTitleLabel.text = nil
                forecastInfoLabel.text = nil
            }
        }
    }
    
    
    
}
