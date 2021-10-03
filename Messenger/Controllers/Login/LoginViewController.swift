//
//  LoginViewController.swift
//  Messenger
//
//  Created by Muhammad Abullah on 07/09/2021.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import NVActivityIndicatorView
class LoginViewController: UIViewController  {
    // settig UI elements here
    private let loder : NVActivityIndicatorView = {
        let loder = NVActivityIndicatorView(frame: CGRect(x:0 , y: 0, width: 52 , height: 52), type: .ballClipRotatePulse, color: .link, padding: nil)
        return loder
    }()
    private let fbLogInBtn : FBLoginButton = {
        var loginbtn = FBLoginButton()
        loginbtn.permissions = ["public_profile", "email"]
        return loginbtn
    }()
    private let scrollVeiw : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.tintColor  = .systemGreen
        return imageView
    }()
    private let emailTextField : UITextField = {
        let textfield = UITextField()
        textfield.autocorrectionType = .no
        textfield.autocapitalizationType  = .none
        textfield.placeholder = "Email address"
        textfield.returnKeyType = .continue
        textfield.layer.cornerRadius = 12
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.lightGray.cgColor
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textfield.leftViewMode = .always
        textfield.backgroundColor = .white
        return textfield
    }()
    private let passwordTextField : UITextField = {
        let textfield = UITextField()
        textfield.autocorrectionType = .no
        textfield.autocapitalizationType  = .none
        textfield.placeholder = "Password"
        textfield.returnKeyType = .done
        textfield.layer.cornerRadius = 12
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.lightGray.cgColor
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textfield.leftViewMode = .always
        textfield.backgroundColor = .white
        textfield.isSecureTextEntry = true
        return textfield
    }()
    private let logInButton : UIButton = {
        let button = UIButton()
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .link
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Log in"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        logInButton.addTarget(self, action: #selector(logInBtnTapped), for: .touchUpInside)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        fbLogInBtn.delegate = self
        // Add sub views
        view.addSubview(scrollVeiw)
        scrollVeiw.addSubview(imageView)
        scrollVeiw.addSubview(emailTextField)
        scrollVeiw.addSubview(passwordTextField)
        scrollVeiw.addSubview(logInButton)
        scrollVeiw.addSubview(fbLogInBtn)
        scrollVeiw.addSubview(loder)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollVeiw.frame = view.bounds
        loder.center = view.center
        let size = scrollVeiw.width / 3
        imageView.frame = CGRect(x: (scrollVeiw.width - size)/2,
                                 y: 20,
                                 width: size,
                                 height: size
        )
        emailTextField.frame = CGRect(x: 30,
                                      y: imageView.bottom + 10 ,
                                      width: scrollVeiw.width - 60 ,
                                      height: 52
        )
        passwordTextField.frame = CGRect(x: 30,
                                         y: emailTextField.bottom + 10 ,
                                         width: scrollVeiw.width - 60 ,
                                         height: 52
        )
        logInButton.frame = CGRect(x: 30,
                                   y: passwordTextField.bottom + 10 ,
                                   width: scrollVeiw.width - 60 ,
                                   height: 52
        )
        fbLogInBtn.frame = CGRect(x: 30,
                                  y: logInButton.bottom + 10 ,
                                  width: scrollVeiw.width - 60 ,
                                  height: 52
        )
    }
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create account"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc private func logInBtnTapped(){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        let validationError = validateFields()
        if validationError != nil {
            alert(message: validationError!)
            return
        }
        // Firebase log in
        else{
            loder.startAnimating()
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            DatabaseManager.shared.userExist(with: email) { [weak self] exits in
                if exits == false {
                    FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) {[weak self] result, error in
                        if error != nil {
                            self?.loder.stopAnimating()
                            self?.alert(message: "Error in log in")
                        }
                        else{
                            guard let result = result else {
                                return
                            }
                            let user  = result.user
                            UserDefaults.standard.setValue(email, forKey: "email")
                            // save the name of current user in user defalut
                            let userSafeEmail = DatabaseManager.safeEmail(emailAddress: email)
                            DatabaseManager.shared.getDataFor(path: userSafeEmail) {  result in
                                switch result{
                                
                                case .success(let data):
                                    print(" User data \(data)")
                                    guard let userData  = data as? [String : Any],
                                          let firstName = userData["first_name"] as? String,
                                          let lastName  = userData["last_name"] as? String
                                    else {
                                        return
                                    }
                                    UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                                case .failure(let error):
                                    print("Error in getting user data \(error)")
                                }
                            }
                            print("Log in user id \(user)")
                            self?.loder.stopAnimating()
                            // self?.alert(message: "Succesfully log in")
                            self?.navigationController?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                else{
                    self?.loder.stopAnimating()
                    self?.passwordTextField.text = ""
                    self?.emailTextField.text = ""
                    self?.alert(message: "You are not registerd in this app. Please register yourself !")
                }
            }
            
        }
    }
    
    
    private func alert(message : String)  {
        let alert = UIAlertController(title: "Log In ", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    private func validateFields() -> String? {
        
        var check = false
        var error = ""
        // Check that all fields are filled in
        if
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            error = error +  "Please Fill email field.\n"
            check = true
        }
        if
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            error = error + "Please fill in the password Filed."
            check = true
        }
        if check{
            return error
        }
        return nil
    }
    
}

extension LoginViewController  : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            logInBtnTapped()
        }
        return true
    }
}


// extension for the facebook login delegate

extension LoginViewController : LoginButtonDelegate{
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        loder.startAnimating()
        guard  let token = result?.token?.tokenString else {
            loder.stopAnimating()
            alert(message: "User failed to log in wiht facebook")
            return
        }
        print("Token is \(token)")
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters:
                                                            [
                                                                "fields":"email, name,picture.type(large)"
                                                            ],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        facebookRequest.start { [weak self]_, result1, error1 in
            guard let self = self else{
                return
            }
            guard let result1 = result1 as? [String : Any] ,error1 == nil else{
                self.loder.stopAnimating()
                self.alert(message: "User failed to log in wiht facebook")
                return
            }
            print(result1)
            
            guard let userName = result1["name"]as? String ,
                  let email = result1["email"]as? String,
                  let picture = result1["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureUrl = data["url"] as? String
            else{
                self.loder.stopAnimating()
                self.alert(message: "Failed to get the email and user name")
                return
            }
            UserDefaults.standard.setValue(email, forKey: "email")
            UserDefaults.standard.setValue(userName, forKey: "name")
            let nameComponents = userName.components(separatedBy: " ")
            guard  nameComponents.count == 2 else{
                return
            }
            
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            DatabaseManager.shared.userExist(with: email) { exits in
                if exits == true {
                    let chatUser =  ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser) { success in
                        if success{
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            URLSession.shared.dataTask(with: url) { data, _, _ in
                                guard let data = data else{
                                    return
                                }
                                // upload the profile picture
                                let fileName = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, filename: fileName) { result in
                                    switch result {
                                    case  .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey:  "profile_picture_url")
                                        print(downloadUrl)
                                    case  .failure(let error):
                                        print("Faild in uploading to the storage \(error)")
                                    }
                                }
                            }.resume()
                            
                        }
                    }
                }
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            print(credential)
            FirebaseAuth.Auth.auth().signIn(with: credential) {[weak self] result, error in
                guard let self = self , let result = result else{
                    return
                }
                if  error != nil{
                    self.loder.stopAnimating()
                    self.alert(message: "Failed to facebook graph request")
                }
                print(result)
                self.loder.stopAnimating()
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // not yet
    }
    
    
}
