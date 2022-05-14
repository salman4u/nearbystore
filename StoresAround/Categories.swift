/*-------------------------------------------
 
 - StoresAround -
 
 Created by Salman ©2017
 All Rights reserved.
 
 ------------------------------------------*/

import UIKit
import CoreLocation
import Parse


// MARK: - CUSTOM CATEGORY CELL
class CatCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var catLabel: UILabel!
    @IBOutlet weak var catImage: UIImageView!
}







// MARK: - CATEGORIES CONTROLLER
class Categories: UIViewController,
UITableViewDelegate,
UITableViewDataSource,
CLLocationManagerDelegate
{
    
    /* Views */
    @IBOutlet weak var catTableView: UITableView!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    var home: Home!

    var locationManager: CLLocationManager!

override func viewDidLoad() {
        super.viewDidLoad()
    
    // Default setup
    category = "\(storeCategories[0])"
    distance = 50
    distanceSlider.value = 50
    
    distanceSlider.setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
    distanceSlider.setThumbImage(UIImage(named: "sliderThumb"), for: .highlighted)
    
}

 
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return storeCategories.count
}
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CatCell", for: indexPath) as! CatCell
    
    cell.catLabel.text = "\(storeCategories[indexPath.row])"
    if indexPath.row > 0
    {
       cell.catImage.image = UIImage(named: "cat" + String(indexPath.row))
    }
    // Set selection's background
    let bgColorView = UIView()
    bgColorView.backgroundColor = UIColor(red: 229.0/255.0, green: 238.0/255.0, blue: 92.0/255.0, alpha: 1.0)
    cell.selectedBackgroundView = bgColorView
    
    
return cell
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
}
    
    
// MARK: -  CELL HAS BEEN TAPPED -> SELECT THE CATEGORY
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! CatCell
    
    cell.catLabel.textColor = UIColor.black
    category = "\(cell.catLabel.text!)"
    // Call query for nearby stores
    getCurrentLocation()
}
    
    


// DESELECT CELL
func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)! as! CatCell
   // cell.backgroundColor = UIColor.clear
    cell.catLabel.textColor = UIColor.init(red: 47/255, green: 55/255, blue: 65/255, alpha: 1.0)
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
    if category != "All Stores"
    {
       if category != "" { query.whereKey(STORES_CATEGORY, equalTo: category)  }
    }
    query.limit = 20
    
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
           storesArray = objects!
            self.hideHUD()
            dismissBtnClicked = true
            self.navigationController?.popViewController(animated: true)
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
   
    
    
    
// MARK: - DISTANCE SLIDER CHANGED
@IBAction func distanceChanged(_ sender: UISlider) {
    distanceLabel.text = "Distance: \( Int(sender.value) ) Km"
    distance = Double(sender.value)
}
    
    
    
// MARK: - DISMISS BUTTON
@IBAction func dismissButt(_ sender: AnyObject) {
    dismissBtnClicked = true
    navigationController?.popViewController(animated: true)
}
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
