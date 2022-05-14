/*-------------------------------------------
 
 - StoresAround -
 
 Created by Salman ©2017
 All Rights reserved.
 
 ------------------------------------------*/

import UIKit
import Parse


class SignUp: UIViewController,
    UITextFieldDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet var signUpBtn: UIButton!
    @IBOutlet weak var termsBtn: UIButton!
    
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
//    signUpBtn.layer.cornerRadius = 10
//    termsBtn.layer.cornerRadius = 10
    // Setup layout views
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 600)
    
    
    // SET COLOR OF PLACEHOLDERS
    let color = UIColor.lightGray
    usernameTxt.attributedPlaceholder = NSAttributedString(string: "type your email address", attributes: [NSAttributedStringKey.foregroundColor: color])
    passwordTxt.attributedPlaceholder = NSAttributedString(string: "type a password", attributes: [NSAttributedStringKey.foregroundColor: color])
    fullnameTxt.attributedPlaceholder = NSAttributedString(string: "type your full name", attributes: [NSAttributedStringKey.foregroundColor: color])
}
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
    dismissKeyboard()
}
    
func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
    fullnameTxt.resignFirstResponder()
}
    
    
// MARK - SIGNUP BUTTON
@IBAction func signupButt(_ sender: AnyObject) {
    showHUD()
        
    let userForSignUp = PFUser()
    userForSignUp.username = usernameTxt.text!.lowercased()
    userForSignUp.email = usernameTxt.text!.lowercased()
    userForSignUp.password = passwordTxt.text
    userForSignUp[USER_FULLNAME] = fullnameTxt.text
   
    userForSignUp.signUpInBackground { (succeeded, error) -> Void in
        if error == nil { // Successful Signup
            self.dismiss(animated: true, completion: nil)
            self.hideHUD()
                
        } else { // No signup, something went wrong
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
    

    
    
    
// MARK: -  TEXTFIELD DELEGATE
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTxt {  passwordTxt.becomeFirstResponder()  }
    if textField == passwordTxt {  fullnameTxt.becomeFirstResponder()  }
    if textField == fullnameTxt {  fullnameTxt.resignFirstResponder()  }
return true
}
    
    
    
// MARK: - BACK BUTTON
@IBAction func backButt(_ sender: AnyObject) {
    dismiss(animated: true, completion: nil)
}
    
    
    
// MARK: - TERMS OF USE BUTTON
@IBAction func touButt(_ sender: AnyObject) {
    let touVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfUse") as! TermsOfUse
    present(touVC, animated: true, completion: nil)
}
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



