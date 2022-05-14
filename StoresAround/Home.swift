/*-------------------------------------------
 
 - StoresAround -
 
 Created by Salman ©2017
 All Rights reserved.
 
 ------------------------------------------*/

import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox



// MARK: - CUSTOM STORE CELL
class StoreCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var storeImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    
}


// MARK: - HOME CONTROLLER
class Home: UIViewController,
UITableViewDelegate,
UITableViewDataSource,
CLLocationManagerDelegate,
GADBannerViewDelegate
{

    /* Views */
    @IBOutlet weak var storesTableView: UITableView!
    let refreshControl = UIRefreshControl()
    let adMobBannerView = GADBannerView()
    
    
    
    
    var locationManager: CLLocationManager!
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    /* IMPORTANT: After you've setup your app on back4app, run the app only once and wait for an Alert.
        Then stop the app and comment (or remove) the line of code below.
        Enter your own Parse Dashboard and refresh the page, you'll see the News class with a demo news row, you can edit it and add your news as new rows.
    */
    createNewsClass()
    
    
    
    // Init a Refresh Control
    refreshControl.tintColor = UIColor.darkGray
    refreshControl.addTarget(self, action: #selector(refreshTB), for: .valueChanged)
    storesTableView.addSubview(refreshControl)
    
    
    // Set logo on NavigationBar
    navigationItem.titleView = UIImageView(image: UIImage(named: "logoNavBar"))
    
    
    // Init ad banners
    initAdMobBanner()
}

    
    override func viewWillAppear(_ animated: Bool) {
        
       if !dismissBtnClicked
       {
        if category == "\(storeCategories[0])" {
            category = ""
        }

        // Call query for nearby stores
       // queryStores(currentLocation!)
        
        print("CATEGORY: \(category)\nDISTANCE: \(distance)")
       }
       else
       {
           self.storesTableView.reloadData()
       }

    }
        


// MARK: - REFRESH DATA
@objc func refreshTB () {
    getCurrentLocation()
        
    if refreshControl.isRefreshing {
        let formatter = DateFormatter()
        let date = Date()
        formatter.dateFormat = "MMM d, h:mm a"
        let title = "Last update: \(formatter.string(from: date))"
        let attrsDictionary = NSDictionary(object: UIColor.darkGray, forKey: NSAttributedStringKey.foregroundColor as NSCopying)
        let attributedTitle = NSAttributedString(string: title, attributes: attrsDictionary as? [NSAttributedStringKey : Any]);
        refreshControl.attributedTitle = attributedTitle
        refreshControl.endRefreshing()
    }
}
    
    
    
    
// MARK: - GET CURRENT LOCATION
func getCurrentLocation() {
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
        locationManager.requestAlwaysAuthorization()
    }
        
    locationManager.startUpdatingLocation()
}
  
// MARK: - CORE LOCATION DELEGATES
func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    simpleAlert("Failed to Get Your Location")
}
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    locationManager.stopUpdatingLocation()
    
    currentLocation = locations.last
    
    // Call query for nearby stores
    queryStores(currentLocation!)
}

    
    
    
    
// MARK: - QUERY NEARBY STORES
func queryStores(_ location:CLLocation) {
    showHUD()
    let currentGeoPoint = PFGeoPoint(location: location)
    print("CURRENT GEO POINT: \(currentGeoPoint)")
    
    let query = PFQuery(className: STORES_CLASS_NAME)
    query.whereKey(STORES_LOCATION, nearGeoPoint: currentGeoPoint, withinKilometers: distance)
    query.whereKey(STORES_IS_PENDING, equalTo: false)
    print(category)
     if category != "All Stores"
     {
        if category != "" { query.whereKey(STORES_CATEGORY, equalTo: category)  }
     }
    query.limit = 20
    
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            storesArray = objects!
            self.storesTableView.reloadData()
            self.hideHUD()
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
    
    
    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print(storesArray.count)
    return storesArray.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreCell", for: indexPath) as! StoreCell
    
    var storeClass = PFObject(className: STORES_CLASS_NAME)
    storeClass = storesArray[indexPath.row]
    
    cell.nameLabel.text = "\(storeClass[STORES_NAME]!)"
    
    cell.addressLabel.text = "\(storeClass[STORES_ADDRESS]!)"
    
    cell.categoryLabel.text = "\(storeClass[STORES_CATEGORY]!)"
    
    cell.mainView.layer.cornerRadius = 10
    cell.storeImage.layer.cornerRadius = 10
    cell.storeImage.layer.masksToBounds = true
    cell.storeImage.layer.borderColor = UIColor(red: 128.0/255, green: 128.0/255, blue: 128.0/255, alpha: 1.0).cgColor
    cell.storeImage.layer.borderWidth = 2.0

    
    // Get distance from Current Location
    let storeGeoPoint = storeClass[STORES_LOCATION] as! PFGeoPoint
    let storeLoc = CLLocation(latitude: storeGeoPoint.latitude, longitude: storeGeoPoint.longitude)
    let distanceInKM: CLLocationDistance = storeLoc.distance(from: currentLocation!) / 1000
    // let kmIntoMiles = distanceInKM * 0.6214
    cell.distanceLabel.text = String(format: "%.2f Km", distanceInKM)
    cell.distanceLabel.layer.cornerRadius = 12
    
    
    let imageFile = storeClass[STORES_IMAGE] as? PFFile
    imageFile?.getDataInBackground { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                cell.storeImage.image = UIImage(data:imageData)
    }}}

    
    
return cell
}
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 160
}
    
    
// MARK: -  CELL HAS BEEN TAPPED -> SHOW STORE DETAILS
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var storeClass = PFObject(className: STORES_CLASS_NAME)
    storeClass = storesArray[indexPath.row]
    
    let aVC = storyboard?.instantiateViewController(withIdentifier: "StoreDetails") as! StoreDetails
    aVC.storeObj = storeClass
    navigationController?.pushViewController(aVC, animated: true)
}

    

    
    
    
    
// MARK: - ACCOUNT BUTTON
@IBAction func accountButt(_ sender: AnyObject) {
    if PFUser.current() != nil {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "Account") as! Account
        navigationController?.pushViewController(aVC, animated: true)
        
    } else {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
        present(aVC, animated: true, completion: nil)
    }
}
    
    
    // MARK: - ACCOUNT BUTTON
    @IBAction func categoriesBtn(_ sender: AnyObject) {
//        if PFUser.current() != nil {
            let aVC = storyboard?.instantiateViewController(withIdentifier: "Categories") as! Categories
            navigationController?.pushViewController(aVC, animated: true)
            
//        } else {
//            let aVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
//            present(aVC, animated: true, completion: nil)
//        }
    }
    
    
    
    

    
    
    
// MARK: - AdMob BANNERS
func initAdMobBanner() {
    adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
    adMobBannerView.frame = CGRect(x: 0, y: view.frame.size.height, width: 320, height: 50)
    adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
    adMobBannerView.rootViewController = self
    adMobBannerView.delegate = self
    view.addSubview(adMobBannerView)
        
    let request = GADRequest()
    adMobBannerView.load(request)
}
    
    // Hide the banner
    func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        var h: CGFloat = 0
        // iPhone X
        if UIScreen.main.bounds.size.height == 812 { h = 84
        } else { h = 48 }
        
        UIView.beginAnimations("showBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2,
                              y: view.frame.size.height - banner.frame.size.height - h,
                              width: banner.frame.size.width, height: banner.frame.size.height);
        UIView.commitAnimations()
        banner.isHidden = false
    }

    
 
// AdMob banner available
func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    showBanner(adMobBannerView)
}
    
// NO AdMob banner available
func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
    hideBanner(adMobBannerView)
}
    
    
    
    
    
// THIS METHOD WILL HAVE TO BE CALLED ONLY ONCE, AT FIRST STARTUP
func createNewsClass() {
    showHUD()
    let nObj = PFObject(className: NEWS_CLASS_NAME)
    nObj[NEWS_TEXT] = "PUT HERE YOUR NEWS TEXT!"
    nObj[NEWS_TITLE] = "PUT HERE YOUR NEWS TITLE!"
    let imageData = UIImageJPEGRepresentation(UIImage(named:"logo")!, 0.5)
    let imageFile = PFFile(name:"image.jpg", data:imageData!)
    nObj[NEWS_IMAGE] = imageFile
   
    nObj.saveInBackground(block: { (succ, error) in
        if error == nil {
            self.hideHUD()
            self.simpleAlert("'News' class and its columns have been created! Now stop the app, enter your Parse Dashboard, edit the demo News and add your own ones.")
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }})
}
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
