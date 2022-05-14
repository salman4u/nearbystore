/*-------------------------------------------
 
 - StoresAround -
 
 Created by Salman ©2017
 All Rights reserved.
 
 ------------------------------------------*/

import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox


class Favorites: UIViewController,
UITableViewDelegate,
UITableViewDataSource,
CLLocationManagerDelegate
{

    /* Views */
    @IBOutlet weak var favTableView: UITableView!
    let refreshControl = UIRefreshControl()

    
    
    /* Variables */
    var favArray = [PFObject]()
    var locationManager: CLLocationManager!
    var currentLocation:CLLocation?
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    
    // Init a refresh Control
    refreshControl.tintColor = UIColor.darkGray
    refreshControl.addTarget(self, action: #selector(refreshTB), for: .valueChanged)
    favTableView.addSubview(refreshControl)
    
    
    // Get current Location
    getCurrentLocation()
    
    
    // Call query
    if PFUser.current() != nil {
        queryFavStores()
    } else {
        favArray.removeAll()
        favTableView.reloadData()
    }
}

    
    
// MARK: - REFRESH DATA
@objc func refreshTB () {
    if PFUser.current() != nil {
        queryFavStores()
    }
    
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
}
    
    
    
// MARK: - QUERY NEARBY STORES
func queryFavStores() {
    showHUD()

    let query = PFQuery(className: FAVORITES_CLASS_NAME)
    query.whereKey(FAVORITES_USER_POINTER, equalTo: PFUser.current()!)
    query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.favArray = objects!
                self.favTableView.reloadData()
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
    return favArray.count
}
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "StoreCell", for: indexPath) as! StoreCell
        
    var favClass = PFObject(className: FAVORITES_CLASS_NAME)
    favClass = favArray[indexPath.row]
    
    // Get Stpore Pointer
    let storePointer = favClass[FAVORITES_STORE_POINTER] as! PFObject
    storePointer.fetchIfNeededInBackground(block: { (user, error) in
        if error == nil {
            
            let currentGeoPoint = PFGeoPoint(location: self.currentLocation)
            print("CURRENT GEO POINT: \(currentGeoPoint)")
            
            cell.mainView.layer.cornerRadius = 10
            
            cell.storeImage.layer.cornerRadius = 10
            cell.storeImage.layer.masksToBounds = true
            cell.storeImage.layer.borderColor = UIColor(red: 128.0/255, green: 128.0/255, blue: 128.0/255, alpha: 1.0).cgColor
            cell.storeImage.layer.borderWidth = 2.0
            
            cell.nameLabel.text = "\(storePointer[STORES_NAME]!)"
            cell.addressLabel.text = "\(storePointer[STORES_ADDRESS]!)"
            cell.categoryLabel.text = "\(storePointer[STORES_CATEGORY]!)"
            
            // Get distance from Current Location
            let storeGeoPoint = storePointer[STORES_LOCATION] as! PFGeoPoint
            let storeLoc = CLLocation(latitude: storeGeoPoint.latitude, longitude: storeGeoPoint.longitude)
            let distanceInKM: CLLocationDistance = storeLoc.distance(from: self.currentLocation!) / 1000
            cell.distanceLabel.text = String(format: "%.2f Km", distanceInKM)
            cell.distanceLabel.layer.cornerRadius = 12
            
            let imageFile = storePointer[STORES_IMAGE] as? PFFile
            imageFile?.getDataInBackground { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.storeImage.image = UIImage(data:imageData)
            }}}

            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }})
    
    
        
return cell
}
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 160
}
    
    
// MARK: -  CELL HAS BEEN TAPPED -> SHOW STORE DETAILS
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var favClass = PFObject(className: FAVORITES_CLASS_NAME)
    favClass = favArray[indexPath.row]
    
    // Get Store Pointer
    let storePointer = favClass[FAVORITES_STORE_POINTER] as! PFObject
    storePointer.fetchIfNeededInBackground(block: { (object, error) in
        if error == nil {
            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "StoreDetails") as! StoreDetails
            aVC.storeObj = storePointer
            aVC.isFromFavorites = true
            self.navigationController?.pushViewController(aVC, animated: true)
        
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }})
    
}
    
  
    
// MARK: - DELETE FAVORITE STORE BY SWIPING THE CELL LEFT
func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
}
func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == UITableViewCellEditingStyle.delete {
        
            var favClass = PFObject(className: FAVORITES_CLASS_NAME)
            favClass = favArray[indexPath.row]
            favClass.deleteInBackground(block: { (succ, error) in
                if error == nil {
                    self.favArray.remove(at: (indexPath.row))
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
            }})
    }
}
    

    
    
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
