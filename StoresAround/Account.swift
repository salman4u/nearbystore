/*-------------------------------------------
 
 - StoresAround -
 
 Created by Salman ©2017
 All Rights reserved.
 
 ------------------------------------------*/

import UIKit
import Parse
import MapKit


class Account: UIViewController,
UIPickerViewDataSource,
UIPickerViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
MKMapViewDelegate
{
    
    /* Views */
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var addressTxt: UITextField!
    @IBOutlet weak var catPickerView: UIPickerView!
    @IBOutlet weak var descriptionTxt: UITextView!
    @IBOutlet weak var phonetxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var websiteTxt: UITextField!
    @IBOutlet weak var storeImage: UIImageView!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    
    
    /* Variables */
    let CurrentUser = PFUser.current()!
    var categoryStr = storeCategories[0]
    var latitudeStr = ""
    var longitudeStr = ""
    
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    catPickerView.layer.cornerRadius = 10
    storeImage.layer.cornerRadius = 10
    imageBtn.layer.cornerRadius = 10
    submitBtn.layer.cornerRadius = 10
    
    // Initialize a BACK BarButton Item
    let backB = UIButton(type: .custom)
    backB.adjustsImageWhenHighlighted = false
    backB.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    backB.setBackgroundImage(UIImage(named: "backButt"), for: .normal)
    backB.addTarget(self, action: #selector(backButt), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backB)

    // Initialize a LOGOUT BarButton Item
    let butt = UIButton(type: .custom)
    butt.adjustsImageWhenHighlighted = false
    butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    butt.setBackgroundImage(UIImage(named: "logoutButt"), for: .normal)
    butt.addTarget(self, action: #selector(logoutButt), for: .touchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: butt)

    
    self.title = "\(CurrentUser[USER_FULLNAME]!)"
    
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 1000)
    
}

   
    


// MARK: - PICKERVIEW DELEGATES
func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
}
func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return storeCategories.count
}

func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return storeCategories[row]
}

func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    categoryStr = "\(storeCategories[row])"
    print("SELECTED CATEGORY: \(categoryStr)")
}

// CUSTOMIZE FONT AND COLOR OF PICKERVIEW (*optional*)
func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    var label = view as! UILabel?
    if view == nil { label = UILabel() }

    label?.textAlignment = .center
    let rowText = storeCategories[row]

    let attributedRowText = NSMutableAttributedString(string: rowText)
    let attributedRowTextLength = attributedRowText.length
    attributedRowText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: attributedRowTextLength))
    attributedRowText.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Titillium-Regular", size: 16)!, range: NSRange(location: 0 ,length:attributedRowTextLength))

    label!.attributedText = attributedRowText

return label!
}


// MARK: - CHOOSE IMAGE BUTTON
@IBAction func chooseImageButt(_ sender: AnyObject) {
    dismissKeyboard()
    
    let alert = UIAlertController(title: APP_NAME,
        message: "Select source",
        preferredStyle: .alert)
    
    let camera = UIAlertAction(title: "Take a Picture", style: UIAlertActionStyle.default, handler: { (action) -> Void in
       if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    })
   
    
    let library = UIAlertAction(title: "Pick from Library", style: UIAlertActionStyle.default, handler: { (action) -> Void in
     if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    })
    
    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in })
    
    alert.addAction(camera)
    alert.addAction(library)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}
    
// ImagePicker delegate
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        storeImage.image = scaleImageToMaxWidth(image: image, newWidth: 600)
    }
    dismiss(animated: true, completion: nil)
}

    
    
    
    
// MARK: - SUBMIT YOUR STORE FOR REVIEW
@IBAction func submitButt(_ sender: AnyObject) {
    if storeImage.image == nil || nameTxt.text == "" || addressTxt.text == "" ||
    descriptionTxt.text == "" || emailTxt.text == "" {
        simpleAlert("You must provide at least Name, Address, Email, Description and an Image of your Store before submitting it for review!")
    
        
    } else {
        showHUD()
        let storeRecord = PFObject(className: STORES_CLASS_NAME)

        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = addressTxt.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        
        localSearch.start { (localSearchResponse, error) -> Void in
            let coords = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:localSearchResponse!.boundingRegion.center.longitude)
        
            storeRecord[STORES_NAME] = self.nameTxt.text
            storeRecord[STORES_CATEGORY] = self.categoryStr
            storeRecord[STORES_ADDRESS] = self.addressTxt.text
        
            let geoLocation = PFGeoPoint(latitude: coords.latitude, longitude: coords.longitude)
            storeRecord[STORES_LOCATION] = geoLocation
        
            storeRecord[STORES_DESCRIPTION] = self.descriptionTxt.text
            storeRecord[STORES_EMAIL] = self.emailTxt.text
            
            if self.phonetxt.text != "" { storeRecord[STORES_PHONE] = self.phonetxt.text }
            if self.websiteTxt.text != "" { storeRecord[STORES_WEBSITE] = self.websiteTxt.text }
            
            storeRecord[STORES_IS_PENDING] = true
            
            
            if self.storeImage.image != nil {
                let imageData = UIImageJPEGRepresentation(self.storeImage.image!, 0.8)
                let imageFile = PFFile(name:"image.jpg", data:imageData!)
                storeRecord[STORES_IMAGE] = imageFile
            }

            // Saving block
            storeRecord.saveInBackground(block: { (succ, error) in
                if error == nil {
                    self.simpleAlert("Thanks for submitting your Store!\nWe'll review your submmission and get back to you asap.")
                    _ = self.navigationController?.popViewController(animated: true)
                    self.hideHUD()
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
                }
            })
            
        
        }
    }
}
    
    

    
    
    
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
    dismissKeyboard()
}
func dismissKeyboard() {
    nameTxt.resignFirstResponder()
    addressTxt.resignFirstResponder()
    descriptionTxt.resignFirstResponder()
    phonetxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
    websiteTxt.resignFirstResponder()
}
    
    
    
    
// MARK: - BACK BUTTON
@objc func backButt() {
    _ = navigationController?.popViewController(animated: true)
}

    
    
    
// MARK: - LOGOUT BUTTON
@objc func logoutButt() {
    
    let alert = UIAlertController(title: APP_NAME,
        message: "Are you sure you want to logout?",
        preferredStyle: .alert)
    let ok = UIAlertAction(title: "Logout", style: UIAlertActionStyle.default, handler: { (action) -> Void in
        self.showHUD()
        
        PFUser.logOutInBackground { (error) -> Void in
            if error == nil {
                _ = self.navigationController?.popViewController(animated: true)
                
                // Show the Login screen
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
                self.present(loginVC, animated: true, completion: nil)
            }
            self.hideHUD()
        }
    })
    
    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in })
    
    alert.addAction(ok); alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}
    

    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
