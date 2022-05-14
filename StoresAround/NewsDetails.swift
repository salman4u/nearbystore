/*-------------------------------------------
 
 - StoresAround -
 
 Created by Salman ©2017
 All Rights reserved.
 
 ------------------------------------------*/

import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox


class NewsDetails: UIViewController,
GADBannerViewDelegate
{

    /* Views */
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newsTxt: UITextView!
    
    // AdMob Banner View
    let adMobBannerView = GADBannerView()
    
    
    /* Variables */
    var newsObj = PFObject(className: NEWS_CLASS_NAME)
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    
    // Initialize a BACK BarButton Item
    let backB = UIButton(type: .custom)
    backB.adjustsImageWhenHighlighted = false
    backB.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    backB.setBackgroundImage(UIImage(named: "backButt"), for: .normal)
    backB.addTarget(self, action: #selector(backButt), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backB)
    

    
    // Get news details
    let imageFile = newsObj[NEWS_IMAGE] as? PFFile
    imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.newsImage.image = UIImage(data:imageData)
    }}})
    
    titleLabel.text = "\(newsObj[NEWS_TITLE]!)"
    
    newsTxt.text = "\(newsObj[NEWS_TEXT]!)"
    newsTxt.sizeToFit()
    
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width,
                        height: newsTxt.frame.origin.y + newsTxt.frame.size.height + 60)


    
    // Init ad banners
    initAdMobBanner()
}

 
    
    
// MARK: - SHARE STORE BUTTON
@IBAction func shareStoreButt(_ sender: AnyObject) {
    let messageStr  = "Check out this: \(newsObj[NEWS_TITLE]!) on #\(APP_NAME)"
    let img = newsImage.image!
        
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
    

    
    
// BACK BUTTON
@objc func backButt() {
    _ = navigationController?.popViewController(animated: true)
}
    
    
    
    
    
    
// MARK: - ADMOB BANNERS
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
        // Dispose of any resources that can be recreated.
    }
}
