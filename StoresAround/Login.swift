/*-------------------------------------------
 
 - StoresAround -
 
 Created by Salman ©2017
 All Rights reserved.
 
 ------------------------------------------*/


import UIKit
import Parse
import ParseFacebookUtilsV4
import AuthenticationServices


class Login: UIViewController,
UITextFieldDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var fbBtn: UIButton!
    @IBOutlet var appleBtn: UIButton!

    
    
    
    
override func viewWillAppear(_ animated: Bool) {
    if PFUser.current() != nil {
        dismiss(animated: true, completion: nil)
    }
}
override func viewDidLoad() {
        super.viewDidLoad()
    
//    loginBtn.layer.cornerRadius = 10
//    fbBtn.layer.cornerRadius = 10
        // Setup layouts
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 550)
        logo.layer.cornerRadius = 20
        
         // SET COLOR OF PLACEHOLDERS
         let color = UIColor.lightGray
         usernameTxt.attributedPlaceholder = NSAttributedString(string: "your email address", attributes: [NSAttributedStringKey.foregroundColor: color])
         passwordTxt.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedStringKey.foregroundColor: color])
}
    
    
    
    
// MARK: - LOGIN BUTTON
@IBAction func loginButt(_ sender: AnyObject) {
    dismissKeyboard()
    showHUD()
    
    PFUser.logInWithUsername(inBackground: usernameTxt.text!, password:passwordTxt.text!) { (user, error) -> Void in
        // Login successfull
        if user != nil {
            self.dismiss(animated: true, completion: nil)
            self.hideHUD()
            
        // Login failed
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}


    
    
    
// MARK: - FACEBOOK LOGIN BUTTON
@IBAction func facebookButt(_ sender: Any) {
    // Set permissions required from the Facebook user account
    let permissions = ["public_profile", "email"];
    showHUD()
    
    // Login PFUser using Facebook
    PFFacebookUtils.logInInBackground(withReadPermissions: permissions) { (user, error) in
        if user == nil {
            self.simpleAlert("Facebook login cancelled")
            self.hideHUD()
            
        } else if (user!.isNew) {
            print("NEW USER signed up and logged in through Facebook!");
            self.getFBUserData()
            
        } else {
            print("User logged in through Facebook!");
            
            self.dismiss(animated: true, completion: nil)
            self.hideHUD()
        }
        
        if error != nil {
            self.simpleAlert("\(error!.localizedDescription)")
    }}
}
    
    
func getFBUserData() {
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])
        let connection = FBSDKGraphRequestConnection()
        connection.add(graphRequest) { (connection, result, error) in
            if error == nil {
                let userData:[String:AnyObject] = result as! [String : AnyObject]
                
                // Get data
                let name = userData["name"] as! String
                var email = ""
                if userData["email"] != nil { email = userData["email"] as! String
                } else { email = "noemail@facebook.com" }
                
                
                // Get avatar
                let currUser = PFUser.current()!
                
                // Update user data
                currUser.username = email
                currUser.email = email
                currUser[USER_FULLNAME] = name
                currUser.saveInBackground(block: { (succ, error) in
                    if error == nil {
                        self.hideHUD()
                        print("USER'S DATA UPDATED!")
                        self.dismiss(animated: true, completion: nil)
                }})
                
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }}
        connection.start()
}

    
    
    
    
    
    
    
    
// MARK: - SIGNUP BUTTON
@IBAction func signupButt(_ sender: AnyObject) {
    let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUp") as! SignUp
    signupVC.modalTransitionStyle = .crossDissolve
    present(signupVC, animated: true, completion: nil)
}
    
    
    
// MARK: - TEXTFIELD DELEGATES
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTxt  {  passwordTxt.becomeFirstResponder() }
    if textField == passwordTxt  {  passwordTxt.resignFirstResponder() }
    
return true
}
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
    dismissKeyboard()
}
func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
}
    
    
      // MARK: - Apple SIGNIN BUTTON
          @IBAction func signinAppleButt(_ sender: Any) {
                      // Set permissions required from the facebook user account
                      
                      showHUD()
                      
                      if #available(iOS 13.0, *) {
              //            let appleIDProvider = ASAuthorizationAppleIDProvider()
              //            let request = appleIDProvider.createRequest()
              //
              //                          request.requestedScopes = [.fullName, .email]
              //
              //                          let authorizationController = ASAuthorizationController(authorizationRequests: [request])
              //
              //                          authorizationController.delegate = self
              //
              //            authorizationController.presentationContextProvider = self as! ASAuthorizationControllerPresentationContextProviding
              //
              //                          authorizationController.performRequests()
                          
                          let appleIDProvider = ASAuthorizationAppleIDProvider()
                          let request = appleIDProvider.createRequest()
                          request.requestedScopes = [.fullName, .email]
                          let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                          authorizationController.delegate = self
                          authorizationController.performRequests()
                      } else {
                          // Fallback on earlier versions
                      }

              //               let request = appleIDProvider.createRequest()
              //
              //               request.requestedScopes = [.fullName, .email]
              //
              //               let authorizationController = ASAuthorizationController(authorizationRequests: [request])
              //
              //               authorizationController.delegate = self
              //
              //               authorizationController.presentationContextProvider = self
              //
              //               authorizationController.performRequests()
                     
              
              }
    
// MARK: - FORGOT PASSWORD BUTTON
@IBAction func forgotPasswButt(_ sender: AnyObject) {
        let alert = UIAlertController(title: APP_NAME,
          message: "Type the email address you've used to sign up.",
          preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Reset Password", style: .default, handler: { (action) -> Void in
            // TextField
            let textField = alert.textFields!.first!
            let txtStr = textField.text!
            
            PFUser.requestPasswordResetForEmail(inBackground: txtStr, block: { (succ, error) in
                if error == nil {
                    self.simpleAlert("You will receive an email shortly with a link to reset your password")
                }})
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        // Add textField
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
        }
        
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
}


    
    
    
// MARK: - CLOSE BUTTON
@IBAction func closeButt(_ sender: AnyObject) {
    dismiss(animated: true, completion: nil)
}
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}




extension Login: ASAuthorizationControllerDelegate {

     // ASAuthorizationControllerDelegate function for authorization failed

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        hideHUD()
        print(error.localizedDescription)

    }

       // ASAuthorizationControllerDelegate function for successful authorization

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        if #available(iOS 13.0, *) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                
                var appleId: String!
                var appleUserFirstName: String!
                var appleUserLastName: String!
                var appleUserEmail: String!
                var fullName: String!
                
                if userSaved.bool(forKey:"isLoggedinApple") == true
                {
                    appleId = userSaved.string(forKey: "appIDStr") //String
                    appleUserEmail = userSaved.string(forKey: "emailAddress") //String
                    fullName = userSaved.string(forKey: "fullNamestr") //String
                }
                else
                {
                  // Create an account as per your requirement
                   appleId = appleIDCredential.user
                   //     let tokenstr = appleIDCredential.identityToken
                    appleUserFirstName = appleIDCredential.fullName?.givenName
                    appleUserLastName = appleIDCredential.fullName?.familyName
                    appleUserEmail = appleIDCredential.email
                    
                    fullName = (appleUserFirstName)! + " " + appleUserLastName!
                    LOGGED_IN_APPLE = true
                    userSaved.set(LOGGED_IN_APPLE, forKey: "isLoggedinApple") //Bool
                    userSaved.set(appleId, forKey: "appIDStr") //String
                    userSaved.set(appleUserEmail, forKey: "emailAddress") //String
                    userSaved.set(fullName, forKey: "fullNamestr") //String

                }
                
                
                let tokenStr = String(data: appleIDCredential.identityToken!, encoding: .utf8)!
                let userID = String(describing: appleId)
                let emailAddress = String(describing: appleUserEmail)
                let password = "1234567"
                
                print(tokenStr)
                print(userID)
                
       //         PFUser.register(AuthDelegate(), forAuthType: "apple")
                
                
                PFUser.logInWithUsername(inBackground: emailAddress, password: password){ (user, error) -> Void in
                    if error == nil {
                
                        self.dismiss(animated: true, completion: nil)
                        self.hideHUD()
                            
                    // Login failed. Try again or SignUp
                    } else {
                      //  self.simpleAlert("\(error!.localizedDescription)")
                        
                        let name = fullName
                        // Update user data

                        let nameArr = name!.components(separatedBy: " ")
                        var username = String()
                        for word in nameArr {
                            username.append(word.lowercased())
                        }
                        
                        let userForSignUp = PFUser()
                            userForSignUp.username = username
                            userForSignUp.password = "1234567"
                            userForSignUp.email = emailAddress
                            userForSignUp[USER_FULLNAME] = name
                          //  userForSignUp[USER_IS_REPORTED] = false
                           // userForSignUp[USER_EMAIL_VERIFIED] = true
                          //  userForSignUp.saveInBackground()
                          
                        // Save default image
                               let imageData = UIImageJPEGRepresentation(UIImage(named:"logo")!, 0.8)
                               let imageFile = PFFile(name:"avatar.jpg", data:imageData!)
                          //     userForSignUp[USER_AVATAR] = imageFile
                               
                               userForSignUp.signUpInBackground { (succeeded, error) -> Void in
                                   if error == nil {
                               PFUser.logInWithUsername(inBackground: emailAddress, password: password){ (user, error) -> Void in
                                 if error == nil {
                                                                    
                                    self.dismiss(animated: true, completion: nil)
                                    self.hideHUD()
                                                                        
                                                                // Login failed. Try again or SignUp
                                } else {
                                    self.simpleAlert("\(error!.localizedDescription)")
                                    self.hideHUD()
                                  }
                                }
                               
                                   // ERROR
                                   } else {
                                    self.simpleAlert("\(error!.localizedDescription)")
                                       self.hideHUD()
                               }}
                    }}
                }
                
            else if let passwordCredential = authorization.credential as? ASPasswordCredential {
                
                hideHUD()

                let appleUsername = passwordCredential.user
                
                let applePassword = passwordCredential.password
                
                //Write your code
                
            }
        } else {
            // Fallback on earlier versions
        }

    }

}

extension Login: ASAuthorizationControllerPresentationContextProviding {

    //For present window

    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {

        return self.view.window!

    }

}


class AuthDelegate:NSObject, PFUserAuthenticationDelegate {
    func restoreAuthentication(withAuthData authData: [String : String]?) -> Bool {
        print(authData!)
        return true
    }
    
    func restoreAuthenticationWithAuthData(authData: [String : String]?) -> Bool {
         print(authData!)
        return true
    }
}
