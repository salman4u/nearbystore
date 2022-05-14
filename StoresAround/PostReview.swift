/*-------------------------------------------
 
 - StoresAround -
 
 Created by Salman ©2017
 All Rights reserved.
 
 ------------------------------------------*/

import UIKit
import Parse


class PostReview: UIViewController,
UITextViewDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var revTxt: UITextView!
    @IBOutlet var starsView: UIView!
    @IBOutlet var starButtons: [UIButton]!
    
    
    
    /* Variables */
    var starNr = 0
    var storeToReview = PFObject(className: STORES_CLASS_NAME)
    
    
    
    

override func viewDidLoad() {
        super.viewDidLoad()
    
    
    self.title = "POST A REVIEW"
    
    
    // Initialize a SEND BarButton Item
    let butt = UIButton(type: .custom)
    butt.adjustsImageWhenHighlighted = false
    butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    butt.setBackgroundImage(UIImage(named: "sendButt"), for: .normal)
    butt.addTarget(self, action: #selector(sendReviewButt), for: .touchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: butt)
    

    // Initialize a LEFT BarButton Item
    let cancelButt = UIButton(type: .custom)
    cancelButt.adjustsImageWhenHighlighted = false
    cancelButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    cancelButt.setBackgroundImage(UIImage(named: "backButt"), for: .normal)
    cancelButt.addTarget(self, action: #selector(cancelButton), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButt)

    
    // Layout
    revTxt.layer.cornerRadius = 8
    starsView.layer.cornerRadius = 8
    starNr = 0
    
    
    // Initialize Star buttons
    for butt in starButtons {
        butt.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        butt.addTarget(self, action: #selector(starButtTapped(_:)), for: UIControlEvents.touchUpInside)
    }
    
    
    // Detect device
    if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
        containerScrollView.isScrollEnabled = false
    } else {
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 600)
    }
}

    
    
// MARK: - STAR BUTTON
@objc func starButtTapped (_ sender: UIButton) {
    let button = sender as UIButton
    
    for i in 0..<starButtons.count {
        starButtons[i].setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
    }
    
    starNr = button.tag + 1
    print("STARS: \(starNr)")
    for star in 0..<starNr {
        starButtons[star].setBackgroundImage(UIImage(named: "fullStar"), for: .normal)
    }
}
    
    
    
// SEND FEEDBACK BUTTON
@objc func sendReviewButt() {
    showHUD()
    revTxt.resignFirstResponder()
    
    if revTxt.text == "" {
        self.simpleAlert("The Review field must not be empty")
        hideHUD()
        
        
    } else {
        let reviewClass = PFObject(className: REVIEWS_CLASS_NAME)
    
        reviewClass[REVIEWS_STARS] = starNr as Int
        reviewClass[REVIEWS_TEXT] = revTxt.text!
        reviewClass[REVIEWS_USER_POINTER] = PFUser.current()!
        reviewClass[REVIEWS_STORE_POINTER] = storeToReview
        
        reviewClass.saveInBackground(block: { (succ, error) in
            if error == nil {
                self.simpleAlert("Great, your review has been sent!")
                self.hideHUD()
                
                // Update store reviews amount
                self.storeToReview.incrementKey(STORES_REVIEWS, byAmount: 1)
                self.storeToReview.saveInBackground()
                
                _ = self.navigationController?.popViewController(animated: true)
            
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }})
    }
}
    
    
    
    
// CANCEL BUTTON
@objc func cancelButton() {
    _ = navigationController?.popViewController(animated: true)
}

    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
