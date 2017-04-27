//
//  LaunchViewController.swift
//  foodieApp
//
//  Created by Mr. Lopez on 4/26/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//
import AVKit
import AVFoundation
import FirebaseAuth

class LaunchViewController: UIViewController {

    //MARK: - Class Vars
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var authUser: FIRUser!
    
    //MARK: - AVPlayer Singleton
    //singleton of splash player
    //loaded once - always init'd
    var splashPlayer: AVPlayer = {
        
        var player: AVPlayer!
        
        //get the launch screen video URL
        if let launchVideoURL = Bundle.main.url(forResource: "launchScreen", withExtension: ".mp4") {
            
            //splash player controls the playback of specific media
            player = AVPlayer.init(url: launchVideoURL)
            player.actionAtItemEnd = .none
            player.isMuted = true
        }
        
        
        return player
    }()
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Layer can be used as the backing layer for a UIView
        let layer = AVPlayerLayer(player: splashPlayer)
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer.zPosition = -1
        
        //set the video frame to the entire view
        layer.frame = view.frame
        view.layer.addSublayer(layer)
        
        //PLAY THAT SHIZZ!!!
        splashPlayer.play()
        
        //get Notification for when video ends
        let notifCenter = NotificationCenter.default
            
        notifCenter.addObserver(self, selector: #selector(LaunchViewController.loopVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime , object: nil)

    }
    
    //MARK: - Firebase User AUTH
    @IBAction func loginButtonClicked(_ sender: Any) {
        
        if (validateTextFields()){
            //grab data in text field, send to firebase
            
            if let emailText = emailField.text, let passwordText = passwordField.text,
                let authCont = FIRAuth.auth() {
                
                authCont.signIn(withEmail: emailText, password: passwordText) {
                    (user, error) in
                    
                    if let error = error {
                        self.alertUserUpdate(withTitle: "Login", error: error)
                        return
                    }
                    
                    if let user = user, let uEmail = user.email {
                        print("\n\n\(uEmail) Signed In!\n")
                        self.authUser = user
                        self.performSegue(withIdentifier: "validAuth", sender: self)
                    }
                }
            }
        }else{
            alertUserUpdate(withTitle: "Login Error!", error: NSError.init(domain: "Invalid login input.", code: 404, userInfo: nil))
        }

    }
    
    @IBAction func registerButtonClicked(_ sender: Any) {
    
        if (validateTextFields()){
            //grab data in text field, send to firebase
            
            if let emailText = emailField.text, let passwordText = passwordField.text,
                let authCont = FIRAuth.auth() {
                
                authCont.createUser(withEmail: emailText, password: passwordText) {
                    (user, error) in
                    
                    if let error = error {
                        self.alertUserUpdate(withTitle: "Register", error: error)
                        return
                    }
                    
                    if let user = user, let uEmail = user.email {
                        print("\(uEmail) created")
                        self.authUser = user
                        self.performSegue(withIdentifier: "validAuth", sender: self)
                    }
                }
            }
        }else{
            alertUserUpdate(withTitle: "Registration Error!", error: NSError.init(domain: "Invalid registration input.", code: 404, userInfo: nil))
        }
    }
    
    @IBAction func guestButtonClicked(_ sender: Any) {
    }
    
    //MARK: - Helper Functions
    @objc private func loopVideo() {
        
        //i <3 sngltns
        
        //loop THAT Launch Video!!
        //reset the seek time to 0
        //replay
        self.splashPlayer.seek(to: kCMTimeZero)
        
        //CCCAAAANN D00000!!!
        self.splashPlayer.play()
    }
    
    //error checks the two user credential fields: email/pword
    private func validateTextFields() -> Bool {
        
        if let emailText = emailField.text, let passwordText = passwordField.text {
            if (emailText.contains(" ") || passwordText.contains(" ")){
                return false
            }else if (passwordText.characters.count > 0 && emailText.contains(".com") && emailText.contains("@") && emailText.characters.count > 6) {
                return true
            }else{
                return false
            }
        }else {
            return false
        }
    }
    
    
    //reused alert system for error messages from firebase
    private func alertUserUpdate(withTitle resultsTitle: String, error: Error?) {
        if let error = error {
            let message = "\(error.localizedDescription)"
            let okAction = UIAlertAction.init(title: "Ok", style: .default) {
                action in print("\n\nhit Ok to error \(error.localizedDescription) in \(resultsTitle)\n\n")
            }
            let alertController  = UIAlertController.init(title: resultsTitle,
                                                          message: message, preferredStyle: .alert)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "validAuth" ){
            if let dest = segue.destination as? TabBarController{
                dest.title = "Foodie Lovers"
                dest.currUser = authUser
            }
        }
    }
    

}
