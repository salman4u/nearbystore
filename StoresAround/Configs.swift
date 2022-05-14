/*-------------------------------------------
 
 - StoresAround -
 
 Created by Salman ©2017
 All Rights reserved.
 
 ------------------------------------------*/

import Foundation
import UIKit
import CoreLocation
import Parse

// IMPORTANT: REPLACE THE RED STRING BELOW WITH THE NEW NAME YOU'LL GIVE TO THIS APP
let APP_NAME = "StoresAround"

let userSaved = UserDefaults.standard
var LOGGED_IN_APPLE = false


// REPLACE THE 2 RED STRINGS BELOW WITH YOUR OWN APP ID & CLIENT KEYS FROM YOUR APPS DASHBOARD ON http://back4app.com
let PARSE_APP_KEY = "Am1nkOj9agjShEv4HnIe5loGkbj8WWU2V32Bv9re"
let PARSE_CLIENT_KEY = "4TMdyWgn3ltAhlvfa27ci7KcgMndcdbNTQdtbc0U"
// ------------------------------------------------------------------------------



// IMPORTANT: REPLACE THE RED STRING BELOW WITH YOUR OWN BANNER UNIT ID YOU'LL GET FROM  http://apps.admob.com
let ADMOB_BANNER_UNIT_ID = "ca-app-pub-3940256099942544/6300978111"



let storeCategories = [
    "All Stores",

    // Edit your stores here
    "Restaurants & Coffees",
    "Education",
    "Bars",
    "Car Rental",
    "Disco",
    "Grocery",
    "Jewelery",
    "Food Store",
    "Fashion",
    "Flowers",
    "Baby care",
    "Healthcare",
    
    
]


/* Variables */
var storesArray = [PFObject]()


var dismissBtnClicked = false


// HUD View
let hudView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
let indicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
extension UIViewController {
    func showHUD() {
        hudView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        hudView.backgroundColor = UIColor.darkGray
        hudView.alpha = 0.9
        hudView.layer.cornerRadius = hudView.bounds.size.width/2

        indicatorView.center = CGPoint(x: hudView.frame.size.width/2, y: hudView.frame.size.height/2)
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        indicatorView.color = UIColor.white
        hudView.addSubview(indicatorView)
        indicatorView.startAnimating()
        view.addSubview(hudView)
    }
    func hideHUD() {
        hudView.removeFromSuperview()
    }

    func simpleAlert(_ mess:String) {
        let alert = UIAlertController(title: APP_NAME, message: mess, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}






/******* DO NOT EDIT THE CODE BELOW! ***********/
var distance = 50.0
var category = ""
var currentLocation:CLLocation?


let USER_CLASS_NAME = "_User"
let USER_USERNAME = "username"
let USER_PASSWORD = "password"
let USER_EMAIL = "email"
let USER_FULLNAME = "fullname"


let STORES_CLASS_NAME = "Stores"
let STORES_IS_PENDING = "isPending"
let STORES_NAME = "name"
let STORES_CATEGORY = "category"
let STORES_ADDRESS = "address"
let STORES_LOCATION = "location"
let STORES_DESCRIPTION = "description"
let STORES_IMAGE = "image"
let STORES_PHONE = "phone"
let STORES_EMAIL = "email"
let STORES_WEBSITE = "website"
let STORES_REVIEWS = "reviews" // Number


let REVIEWS_CLASS_NAME = "Reviews"
let REVIEWS_TEXT = "text"
let REVIEWS_USER_POINTER = "userPointer"
let REVIEWS_STORE_POINTER = "storePointer"
let REVIEWS_STARS = "stars" // Number


let FAVORITES_CLASS_NAME = "Favorites"
let FAVORITES_USER_POINTER = "userPointer"
let FAVORITES_STORE_POINTER = "storePointer"


let NEWS_CLASS_NAME = "News"
let NEWS_TITLE = "title"
let NEWS_TEXT = "text"
let NEWS_IMAGE = "image"




// MARK: - EXTENSION TO RESIZE A UIIMAGE
extension UIViewController {
    func scaleImageToMaxWidth(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}


