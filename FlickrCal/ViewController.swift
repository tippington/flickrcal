//
//  ViewController.swift
//  FlickrCal
//
//  Created by Clinton VanSciver on 3/27/17.
//  Copyright © 2017 Clinton VanSciver. All rights reserved.
//

import UIKit
import CVCalendar
import PermissionScope
import SABlurImageView

class ViewController: UIViewController {

	let pscope = PermissionScope()
	let flickr = Flickr()
	
	@IBOutlet weak var menuView: CVCalendarMenuView!
	@IBOutlet weak var calendarView: CVCalendarView!
	@IBOutlet weak var flickrView: SABlurImageView!
	@IBOutlet weak var lblQuote: UILabel!
	@IBOutlet weak var lblAuthor: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		getPermission()
		getQuoteOfDay()
		setupCalendar()
		searchFlickr()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.menuView.commitMenuViewUpdate()
		self.calendarView.commitCalendarViewUpdate()
	}
	
	func getPermission() {
		pscope.addPermission(EventsPermission(),
			message: "If you say no, the consequences will be dire")
		pscope.show({ finished, results in
			print("got results \(results)")
		}, cancelled: { (results) -> Void in
			print("thing was cancelled")
		})
	}
	
	func getQuoteOfDay() {
		//get qod
		let config = URLSessionConfiguration.default // Session Configuration
		let session = URLSession(configuration: config) // Load configuration into Session
		let url = URL(string: Constant.quoteUrl)!
		
		let task = session.dataTask(with: url, completionHandler: {
			(data, response, error) in
			if error != nil {
				print(error!.localizedDescription)
			} else {
				do {
					if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
						
						//Implement your logic
						let contents = json["contents"] as! [String: AnyObject]
						let quotes = contents["quotes"] as! [[String: AnyObject]]
						let qod = quotes[0]
						
						if let author = qod["author"] as? String {
							self.lblAuthor.text = author
						}
						if let quote = qod["quote"] as? String {
							self.lblQuote.text = quote
						}
					}
				} catch {
					print("error in JSON")
				}
			}
		})
		task.resume()
	}
	
	func setupCalendar() {
		menuView.menuViewDelegate = self
		calendarView.calendarDelegate = self
		
		self.view.addSubview(menuView)
		getCalendarEvents()
	}
	
	func getCalendarEvents() {
		//get events from native ios calendar
		
	}
	
	func searchFlickr() {
		flickr.searchFlickrForTerm(Constant.searchTerm) {
			results, error in
			
			if let error = error {
				print("Error searching : \(error)")
				return
			}
			
			if let results = results {
				print("Found \(results.searchResults.count) matching \(results.searchTerm)")
				let dice = arc4random_uniform(20)
				self.flickrView.image = results.searchResults[Int(dice)].thumbnail
				self.flickrView.addBlurEffect(5, times: 1)
			}
		}
	}

}

extension ViewController: CVCalendarMenuViewDelegate {
	
}

extension ViewController: CVCalendarViewDelegate {
	func presentationMode() -> CalendarMode {
		return CalendarMode(rawValue: 0)!
	}
	
	func firstWeekday() -> Weekday {
		return Weekday.sunday
	}
}


