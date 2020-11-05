//
//  ViewController.swift
//  FB_Login
//
//  Created by 葉上輔 on 2020/11/4.
//  Copyright © 2020 YehSF. All rights reserved.
//
// Swift //
// Add this to the header of your file, e.g. in ViewController.swift

import UIKit
import FBSDKLoginKit

class ViewController: UIViewController {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var logout: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        
    }
        

}


extension ViewController: LoginButtonDelegate {
    
    func setupSubviews() {
        

        
        if let token = AccessToken.current, !token.isExpired {
            // User is logged in, do work such as go to next view controller.
            let token = token.tokenString
            
            let request = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                     parameters: ["fields":"email, name, picture.type(large)"],
                                                     tokenString: token,
                                                     version: nil,
                                                     httpMethod: .get)
            request.start(completionHandler: { connection, result, error in
                guard error == nil else { return }
                let dict = result as! [String: AnyObject] as NSDictionary
                let id = dict.value(forKey: "id") as! String
                let name = dict.object(forKey: "name") as! String
                let email = dict.object(forKey: "email") as! String
                
                self.name?.text = "Name: \(name)"
                self.id?.text = "Id: \(id)"
                self.email?.text = "Email: \(email)"
                
                if let profilePicture = dict.object(forKey: "picture") as? [String : Any] {
                    
                    print("\(profilePicture)")
                    
                    if let profilePicData = profilePicture["data"] as? [String : Any] {
                        
                        print("\(profilePicData)....")
                        
                        if let picUrl = profilePicData["url"] as? String {
                            
                            print("\(picUrl)...url")
                            
                            let data = try? Data(contentsOf: URL(string: picUrl)!)
                                
                            if let imageData = data {
                                DispatchQueue.main.async {
                                    
                                    self.picture.image = UIImage(data: imageData)
                                    
                                }
                                
                            }
                                
                        }
                        
                    }
                    
                } else {
                    print(error?.localizedDescription as Any)
                }
                self.showData()
                
                self.logout.isHidden = true
                let logoutButton = FBLoginButton()
                logoutButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 150)
                logoutButton.delegate = self
                logoutButton.permissions = ["public_profile", "email"]
                self.view.addSubview(logoutButton)
                print("id:  \(id)")
                print("name:  \(name)")
                print("email:  \(email)")

            })
            
        } else {
            
            hideData()
            
            let loginButton = FBLoginButton()
            loginButton.center = view.center
            loginButton.delegate = self
            loginButton.permissions = ["public_profile", "email"]
            view.addSubview(loginButton)
            
        }



    }
    
    @IBAction func logoutHandler(_ sender: UIButton) {
        
        FBSDKLoginKit.LoginManager().logOut()
        hideData()
        
        let loginButton = FBLoginButton()
        loginButton.center = CGPoint(x: view.center.x, y: view.center.y + 150)
        loginButton.delegate = self
        loginButton.permissions = ["public_profile", "email"]
        view.addSubview(loginButton)
        
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard error == nil else {
            print(error!)
            return
        }
        
        let token = result?.token?.tokenString
        
        let request = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                 parameters: ["fields":"email, name, picture.type(large)"],
                                                 tokenString: token,
                                                 version: nil,
                                                 httpMethod: .get)
        request.start(completionHandler: { connection, result, error in
            guard error == nil else { return }
            let dict = result as! [String: AnyObject] as NSDictionary
            let id = dict.object(forKey: "id") as! String
            let name = dict.object(forKey: "name") as! String
            let email = dict.object(forKey: "email") as! String
            
            self.name?.text = "Name: \(name)"
            self.id?.text = "Id: \(id)"
            self.email?.text = "Email: \(email)"
            
            if let profilePicture = dict.object(forKey: "picture") as? [String : Any] {
                
                print("\(profilePicture)")
                
                if let profilePicData = profilePicture["data"] as? [String : Any] {
                    
                    print("\(profilePicData)....")
                    
                    if let picUrl = profilePicData["url"] as? String {
                        
                        print("\(picUrl)...url")
                        
                        let data = try? Data(contentsOf: URL(string: picUrl)!)
                            
                        if let imageData = data {
                           
                            DispatchQueue.main.async {
                                
                                self.picture.image = UIImage(data: imageData)
                                
                            }
                                
                        }
                            
                    }
                    
                }
            } else {
                print("\(error?.localizedDescription as Any)...err")
            }
            self.showData()
            loginButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 150)
            loginButton.isHidden = false
            self.logout.isHidden = true
            print("id:  \(id)")
            print("name:  \(name)")
            print("email:  \(email)")
        })
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        loginButton.center = view.center
        hideData()
        
    }
    
    func showData() {
        id?.isHidden = false
        email?.isHidden = false
        name?.isHidden = false
        picture?.isHidden = false
        logout?.isHidden = false
    }
    
    func hideData() {
        id?.isHidden = true
        email?.isHidden = true
        name?.isHidden = true
        picture?.isHidden = true
        logout?.isHidden = true
    }

    
}
