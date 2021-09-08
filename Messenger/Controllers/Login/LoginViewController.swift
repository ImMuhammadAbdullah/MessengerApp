//
//  LoginViewController.swift
//  Messenger
//
//  Created by Muhammad Abullah on 07/09/2021.
//

import UIKit

class LoginViewController: UIViewController  {
    // settig UI elements here
    private let scrollVeiw : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        logInButton.addTarget(self, action: #selector(logInBtnTapped), for: .touchUpInside)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        // Add sub views
        view.addSubview(scrollVeiw)
        scrollVeiw.addSubview(imageView)
        scrollVeiw.addSubview(emailTextField)
        scrollVeiw.addSubview(passwordTextField)
        scrollVeiw.addSubview(logInButton)
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
    }
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create account"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc private func logInBtnTapped(){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        let error = validateFields()
        if error != nil {
            alert(message: error!)
            return
        }
        // Firebase log in
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


 
