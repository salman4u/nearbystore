/*-------------------------------------------
 
 - StoresAround -
 
 Created by Salman ©2017
 All Rights reserved.
 
 ------------------------------------------*/

import UIKit
import Parse
import MapKit
import GoogleMobileAds
import AudioToolbox
import MessageUI



// MARK: - CUSTOM REVIEW CELL
class ReviewCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var rTextLabel: UILabel!
    @IBOutlet weak var byDateLabel: UILabel!
    @IBOutlet weak var starsImage: UIImageView!
    @IBOutlet weak var view: UIView!
}









// MARK: - STORE DETAILS CONTROLLER
class StoreDetails: UIViewController,
UITabBarDelegate,
UITableViewDataSource,
MKMapViewDelegate,
GADBannerViewDelegate,
UIAlertViewDelegate,
MFMailComposeViewControllerDelegate
{

    /* Views */
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    @IBOutlet weak var storeImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var descriptionTxt: UITextView!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var phoneOutlet: UIButton!
    @IBOutlet weak var emailOutlet: UIButton!
    @IBOutlet weak var webOutlet: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var theMap: MKMapView!
    @IBOutlet weak var favOutlet: UIButton!
    @IBOutlet weak var shareOutlet: UIButton!
    
    @IBOutlet weak var reviewsTableView: UITableView!
    
    // AdMob Banner View
    let adMobBannerView = GADBannerView()
    
    /* Variables */
    var storeObj = PFObject(className: STORES_CLASS_NAME)
    var reviewsArray = [PFObject]()
    var favArray = [PFObject]()
    var isFromFavorites = Bool()
    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinView:MKPinAnnotationView!
    var region: MKCoordinateRegion!
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    theMap.layer.cornerRadius = 10
    storeImage.layer.cornerRadius = 10
    descriptionTxt.layer.cornerRadius = 10
    // Set logo on NavigationBar
    navigationItem.titleView = UIImageView(image: UIImage(named: "logoNavBar"))
    
    
    // Initialize a ADD REVIEW BarButton Item
    let butt = UIButton(type: .custom)
    butt.adjustsImageWhenHighlighted = false
    butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    butt.setBackgroundImage(UIImage(named: "addReviewButt"), for: .normal)
    butt.addTarget(self, action: #selector(addReviewButt), for: .touchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: butt)

    
    // Initialize a BACK BarButton Item
    let backB = UIButton(type: .custom)
    backB.adjustsImageWhenHighlighted = false
    backB.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    backB.setBackgroundImage(UIImage(named: "backButt"), for: .normal)
    backB.addTarget(self, action: #selector(backButt), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backB)
    

    
    // Show store details
    nameLabel.text = "\(storeObj[STORES_NAME]!)"

    // Get image
    let imageFile = storeObj[STORES_IMAGE] as? PFFile
    imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.storeImage.image = UIImage(data:imageData)
    }}})
    

    // Adjust buttons if you come from Favorites controller
    if isFromFavorites {
        favOutlet.isHidden = true
        shareOutlet.center.x = view.center.x
    }
    
    
    if storeObj[STORES_REVIEWS] != nil { ratingsLabel.text = "\(storeObj[STORES_REVIEWS]!) ratings"
    } else { ratingsLabel.text = "0 ratings" }
    
    descriptionTxt.text = "\(storeObj[STORES_DESCRIPTION]!)"
    descriptionTxt.sizeToFit()
    
    
    if storeObj[STORES_PHONE] != nil {
        phoneOutlet.setTitle("\(storeObj[STORES_PHONE]!)", for: .normal)
    } else {
        phoneOutlet.setTitle("N/A", for: .normal)
        phoneOutlet.isEnabled = false
    }
    
    emailOutlet.setTitle("\(storeObj[STORES_EMAIL]!)", for: .normal)
    
    if storeObj[STORES_WEBSITE] != nil {
        webOutlet.setTitle("\(storeObj[STORES_WEBSITE]!)", for: .normal)
    } else {
        webOutlet.setTitle("N/A", for: .normal)
        webOutlet.isEnabled = false
    }
    
    
    
    // Get address and show pin on Map
    addressLabel.text = "\(storeObj[STORES_ADDRESS]!)"
    let geoPoint = storeObj[STORES_LOCATION] as! PFGeoPoint
    let latitude:CLLocationDegrees = geoPoint.latitude
    let longitude:CLLocationDegrees = geoPoint.longitude
    addPinOnMap(latitude, long: longitude)
    
    
    // Move bottomView below the descr
    bottomView.frame.origin.y = descriptionTxt.frame.size.height + descriptionTxt.frame.origin.y
    
    
    // Lastly, call query for Reviews
    queryReviews()
    
    
    // Init ad banners
    initAdMobBanner()
}


    
    

// MARK: - ADD A PIN ON THE theMap
func addPinOnMap(_ lat: CLLocationDegrees, long: CLLocationDegrees) {
        theMap.delegate = self
        
        if theMap.annotations.count != 0 {
            annotation = theMap.annotations[0]
            theMap.removeAnnotation(annotation)
        }
    
            // Add PointAnnonation text and a Pin to the Map
            pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = "\(storeObj[STORES_NAME]!)"
            pointAnnotation.coordinate = CLLocationCoordinate2D(
                latitude: lat,
                longitude: long
            )
            
            pinView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            theMap.centerCoordinate = self.pointAnnotation.coordinate
            theMap.addAnnotation(self.pinView.annotation!)
            
            // Zoom the Map to the location
            region = MKCoordinateRegionMakeWithDistance(self.pointAnnotation.coordinate, 1000, 1000);
            theMap.setRegion(self.region, animated: true)
            theMap.regionThatFits(self.region)
            theMap.reloadInputViews()
    
}
    
// MARK: - CUSTOMIZE PIN ANNOTATION
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Handle custom annotations.
        if annotation.isKind(of: MKPointAnnotation.self) {
            
            // Try to dequeue an existing pin view first.
            let reuseID = "CustomPinAnnotationView"
            var annotView = theMap.dequeueReusableAnnotationView(withIdentifier: reuseID)
            
            if annotView == nil {
                annotView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                annotView!.canShowCallout = true
                
                // Custom Pin image
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                imageView.image =  UIImage(named: "mapPin")
                imageView.center = annotView!.center
                imageView.contentMode = .scaleAspectFill
                annotView!.addSubview(imageView)
                
                // Add a RIGHT CALLOUT Accessory
                let rightButton = UIButton(type: .custom)
                rightButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
                rightButton.layer.cornerRadius = rightButton.bounds.size.width/2
                rightButton.clipsToBounds = true
                rightButton.setImage(UIImage(named: "openInMaps"), for: .normal)
                annotView!.rightCalloutAccessoryView = rightButton
            }
        return annotView
        }
        
return nil
}
 
// MARK: - OPEN THE NATIVE iOS MAPS APP
func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    annotation = view.annotation
    let coordinate = annotation.coordinate
    let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
    let mapitem = MKMapItem(placemark: placemark)
    mapitem.name = annotation.title!
    mapitem.openInMaps(launchOptions: nil)
}
    

   
    
    

    
    
    
// MARK: - QUERY REVIEWS FOR THIS STORE
func queryReviews() {
    reviewsArray.removeAll()
        
    let query = PFQuery(className: REVIEWS_CLASS_NAME)
    query.whereKey(REVIEWS_STORE_POINTER, equalTo: storeObj)
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            self.reviewsArray = objects!
            self.setHeightOfTableView()
            self.reviewsTableView.reloadData()
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
        }}
}
 

func setHeightOfTableView() {
    let tbHeight:CGFloat = 118 * CGFloat(reviewsArray.count)
    reviewsTableView.frame = CGRect(x: reviewsTableView.frame.origin.x, y: reviewsTableView.frame.origin.y, width: reviewsTableView.frame.size.width, height: tbHeight)
 
    bottomView.frame.size.height = tbHeight + reviewsTableView.frame.origin.y + 80
    
    // Resize the contentSize of the containerScrollView
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width,
                                             height: descriptionTxt.frame.size.height + descriptionTxt.frame.origin.y + bottomView.frame.size.height)
}
    
    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
   
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return reviewsArray.count
}
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
    
    cell.view.layer.cornerRadius = 10
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    
    cell.layer.cornerRadius = 10
    var revClass = PFObject(className: REVIEWS_CLASS_NAME)
    revClass = reviewsArray[indexPath.row]
    
    // Get User Pointer
    let userPointer = revClass[REVIEWS_USER_POINTER] as! PFUser
    userPointer.fetchIfNeededInBackground(block: { (user, error) in
        if error == nil {
            cell.rTextLabel.text = "\(revClass[REVIEWS_TEXT]!)"
            cell.rTextLabel.frame.size.width = cell.frame.size.width - 30
            
            // Get Date & Author
            let date = revClass.createdAt
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM dd yyyy"
            let dateStr = dateFormat.string(from: date!)
            
            cell.byDateLabel.text = "by \(userPointer[USER_FULLNAME]!) • \(dateStr)"
            cell.byDateLabel.frame.size.width = cell.frame.size.width - cell.starsImage.frame.size.width
            
            
            // Get ratings image
            cell.starsImage.image = UIImage(named: "\(revClass[REVIEWS_STARS]!)star")
            if revClass[REVIEWS_STARS] == nil {
                cell.starsImage.image = UIImage(named: "0star")
            }
            cell.starsImage.frame.origin.x = cell.byDateLabel.frame.size.width + 10
            
            
        // error
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }})
    
    
return cell
}

    
private func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
    return 118
}
    

    
    
    
    
    
    
// MARK: - PHONE CALL BUTTON
@IBAction func phoneCallButt(_ sender: AnyObject) {
    let aURL = URL(string: "telprompt://\(storeObj[STORES_PHONE]!)")!
    if UIApplication.shared.canOpenURL(aURL) {
        UIApplication.shared.openURL(aURL)
    }
}
    
    
    
    
// MARK: - EMAIL BUTTON
@IBAction func emailButton(_ sender: AnyObject) {
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setToRecipients(["\(storeObj[STORES_EMAIL]!)"])
    mailComposer.setSubject("Contact request from \(APP_NAME)")
    mailComposer.setMessageBody("Hello,<br>", isHTML: true)
    
    if MFMailComposeViewController.canSendMail() {
        present(mailComposer, animated: true, completion: nil)
    } else {
        simpleAlert("Your device cannot send emails. Please configure an email address into Settings -> Mail, Contacts, Calendars.")
    }
}
    
// Email delegate
func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        var outputMessage = ""
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            outputMessage = "Mail cancelled"
        case MFMailComposeResult.saved.rawValue:
            outputMessage = "Mail saved"
        case MFMailComposeResult.sent.rawValue:
            outputMessage = "Mail sent"
        case MFMailComposeResult.failed.rawValue:
            outputMessage = "Something went wrong with sending Mail, try again later."
        default: break }
       
        simpleAlert(outputMessage)
        dismiss(animated: false, completion: nil)
}
    
    
    
    
//MARK: - WEBSITE BUTTON
@IBAction func webButt(_ sender: AnyObject) {
    let aURL = URL(string: "\(storeObj[STORES_WEBSITE]!)")
    UIApplication.shared.openURL(aURL!)
}
    

  
   
    
    
    
// MARK: - ADD REVIEW BUTTON
@objc func addReviewButt() {
    
    // YOU'RE LOGGED IN
    if PFUser.current() != nil {
        
        // Check if you've already reviewed this Store
        let query = PFQuery(className: REVIEWS_CLASS_NAME)
        query.whereKey(REVIEWS_USER_POINTER, equalTo: PFUser.current()!)
        query.whereKey(REVIEWS_STORE_POINTER, equalTo: storeObj)
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                // Rate this Store & write a review
                if objects!.count == 0 {
                    let prVC = self.storyboard?.instantiateViewController(withIdentifier: "PostReview") as! PostReview
                    prVC.storeToReview = self.storeObj
                    self.navigationController?.pushViewController(prVC, animated: true)
                
                // You've already rated this Store!
                } else { self.simpleAlert("You've already rated this Store!") }
                
                
            // Error
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
        }}


        
    // YOU'RE NOT LOGGED IN
    } else {
         let alert = UIAlertController(title: APP_NAME,
         message: "You must be logged in to post a review!",
         preferredStyle: .alert)
         
         let ok = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
            
            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
            self.present(aVC, animated: true, completion: nil)
        
         })
         
         // Cancel button
         let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        
         alert.addAction(ok)
         alert.addAction(cancel)
         present(alert, animated: true, completion: nil)
    }
    
}
 

    
    
// MARK: - FAVORITE STORE BUTTON
@IBAction func favButt(_ sender: AnyObject) {
    favArray.removeAll()
    
    // USER IS NOT LOGGED IN
    if PFUser.current() == nil {
        let alert = UIAlertView(title: APP_NAME,
            message: "You must be logged in to favorite this store!",
            delegate: self,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: "Login")
        alert.show()
    
    
    // USER IS LOGGED IN
    } else {
        
        let query = PFQuery(className: FAVORITES_CLASS_NAME)
        query.whereKey(FAVORITES_USER_POINTER, equalTo: PFUser.current()!)
        query.whereKey(FAVORITES_STORE_POINTER, equalTo: storeObj)
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.favArray = objects!
    
            
            // UN-FAVORITE THIS STORE
            if self.favArray.count != 0 {
                var favClass = PFObject(className: FAVORITES_CLASS_NAME)
                favClass = self.favArray[0]
                favClass.deleteInBackground(block: { (succ, error) in
                    if error == nil {
                        self.simpleAlert("You've removed this store from your Favorites!")
                    } else { self.simpleAlert("\(error!.localizedDescription)")
                }})
                
                
                
            // FAVORITE THIS STORE
            } else {
                let favClass = PFObject(className: FAVORITES_CLASS_NAME)
                favClass[FAVORITES_USER_POINTER] = PFUser.current()!
                favClass[FAVORITES_STORE_POINTER] = self.storeObj
                
                favClass.saveInBackground(block: { (succ, error) in
                    if error == nil {
                        self.simpleAlert("You've added this store to your Favorites!")
                    } else { self.simpleAlert("\(error!.localizedDescription)")
                }})
            }
            
        
        // error in query
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
        }}
    
    }
}
    
    
    
    
// MARK: - SHARE STORE BUTTON
@IBAction func shareStoreButt(_ sender: AnyObject) {
    let messageStr  = "Check out this: \(storeObj[STORES_NAME]!) on #\(APP_NAME)"
    let img = storeImage.image!
    
    let shareItems = [messageStr, img] as [Any]
    
    let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
    activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
    
    if UIDevice.current.userInterfaceIdiom == .pad {
        // iPad
        let popOver = UIPopoverController(contentViewController: activityViewController)
        popOver.present(from: CGRect.zero, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
    } else {
        // iPhone
        present(activityViewController, animated: true, completion: nil)
    }
}
    

    
    
    
// MARK: - BACK BUTTON
@objc func backButt() {
    _ = navigationController?.popViewController(animated: true)
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
    func adViewDidReceiveAd(_ view: GADBannerView) {
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        hideBanner(adMobBannerView)
    }
    

    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
