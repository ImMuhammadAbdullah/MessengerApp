//
//  LoginViewController.swift
//  Messenger
//
//  Created by Muhammad Abullah on 07/09/2021.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
class LoginViewController: UIViewController  {
    // settig UI elements here
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollVeiw.frame = view.bounds
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
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) {[weak self] result, error in
                if result != nil && error != nil{
                    self?.alert(message: "Error in log in")
                }
                else{
                    // self?.alert(message: "Succesfully log in")
                    self?.navigationController?.dismiss(animated: true, completion: nil)
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
        guard  let token = result?.token?.tokenString else {
            return
                alert(message: "User failed to log in wiht facebook")
        }
        print("Token is \(token)")
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields":"email, name"], tokenString: token, version: nil, httpMethod: .get)
        facebookRequest.start { [weak self]_, result1, error1 in
            guard let self = self else{
                return
            }
            guard let result1 = result1 as? [String : Any] ,error1 == nil else{
                self.alert(message: "User failed to log in wiht facebook")
                return
            }
            print(result1)
            
            guard let userName = result1["name"]as? String ,let email = result1["email"]as? String else{
                self.alert(message: "Failed to get the email and user name")
                return
            }
            
            let nameComponents = userName.components(separatedBy: " ")
            guard  nameComponents.count == 2 else{
                return
            }
            
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            DatabaseManager.shared.userExist(with: email) { exits in
                if !exits {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
                }
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            print(credential)
            FirebaseAuth.Auth.auth().signIn(with: credential) {[weak self] result, error in
                guard let self = self , let result = result else{
                    return
                }
                if  error != nil{
                    self.alert(message: "Failed to facebook graph request")
                }
                print(result)
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // not yet
    }
    
    
}
