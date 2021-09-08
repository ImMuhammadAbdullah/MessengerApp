//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Muhammad Abullah on 07/09/2021.
//

import UIKit

class RegisterViewController: UIViewController {
    // settig UI elements here
    private let scrollVeiw : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName:  "person.circle")
        imageView.tintColor = .systemGreen
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private let firstNameField : UITextField = {
        let textfield = UITextField()
        textfield.autocorrectionType = .no
        textfield.autocapitalizationType  = .none
        textfield.placeholder = "First name"
        textfield.returnKeyType = .continue
        textfield.layer.cornerRadius = 12
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.lightGray.cgColor
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textfield.leftViewMode = .always
        textfield.backgroundColor = .white
        return textfield
    }()
    private let lastNameField : UITextField = {
        let textfield = UITextField()
        textfield.autocorrectionType = .no
        textfield.autocapitalizationType  = .none
        textfield.placeholder = "Last name"
        textfield.returnKeyType = .continue
        textfield.layer.cornerRadius = 12
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.lightGray.cgColor
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textfield.leftViewMode = .always
        textfield.backgroundColor = .white
        return textfield
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
    private let registerButton : UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log in"
        view.backgroundColor = .white
        registerButton.addTarget(self, action: #selector(logInBtnTapped), for: .touchUpInside)
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        // Add sub views
        view.addSubview(scrollVeiw)
        scrollVeiw.addSubview(imageView)
        scrollVeiw.addSubview(firstNameField)
        scrollVeiw.addSubview(lastNameField)
        scrollVeiw.addSubview(emailTextField)
        scrollVeiw.addSubview(passwordTextField)
        scrollVeiw.addSubview(registerButton)
        
        scrollVeiw.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTappChangeProfilePic))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(gesture)
    }
    @objc private func didTappChangeProfilePic(){
        presentActionSheet()
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
        imageView.layer.cornerRadius = imageView.width/2
        firstNameField.frame = CGRect(x: 30,
                                      y: imageView.bottom + 10 ,
                                      width: scrollVeiw.width - 60 ,
                                      height: 52
        )
        lastNameField.frame = CGRect(x: 30,
                                      y: firstNameField.bottom + 10 ,
                                      width: scrollVeiw.width - 60 ,
                                      height: 52
        )

        emailTextField.frame = CGRect(x: 30,
                                      y: lastNameField.bottom + 10 ,
                                      width: scrollVeiw.width - 60 ,
                                      height: 52
        )
        passwordTextField.frame = CGRect(x: 30,
                                         y: emailTextField.bottom + 10 ,
                                         width: scrollVeiw.width - 60 ,
                                         height: 52
        )
        registerButton.frame = CGRect(x: 30,
                                   y: passwordTextField.bottom + 10 ,
                                   width: scrollVeiw.width - 60 ,
                                   height: 52
        )
    }
    
   
    
    @objc private func logInBtnTapped(){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        let filedError = validateFields()
        let passwordError = securePassword()
        let emailError = emailFormat()

        if filedError != nil {
            // There's something wrong with the fields, show error message
            alert(message: filedError!)
        }
        else if passwordError != nil && emailError != nil{
            alert(message: passwordError! + "\n" + emailError!)
        }
        else if passwordError != nil && emailError == nil{
            alert(message: passwordError! )
        }
        else if passwordError == nil && emailError != nil{
            alert(message: emailError! )
        }
        // Firebase log in
        else{
            
        }
    }
    
    
    private func alert(message : String)  {
        let alert = UIAlertController(title: "Registration ", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    private func validateFields() -> String? {
        
        var check = false
        var error = ""
        // Check that all fields are filled in
        if
            firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            error = error +  "Fill first name field.\n"
            check = true
        }
        if
            lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            error = error +  "Fill last name field.\n"
            check = true
        }
        if
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            error = error +  "Fill email field.\n"
            check = true
        }
         if
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            error = error + "Fill in the password Filed."
            check = true
        }
    
        if check{
            return error
        }
        return nil
    }
    
    private func securePassword() -> String? {
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false {
            // Password isn't secure enough
            return " Please make sure your password is at least 8 characters, contains a special character and a number. \n "
            
        }
        
        return nil
    }
    // check correct email format
   private func emailFormat() -> String? {
        let cleanedEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isValidEmail(email: cleanedEmail) == false {
          return " Incorrect email format . \n"
        }
        return nil
    }
    
}

extension RegisterViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameField{
            lastNameField.becomeFirstResponder()
        }
       else if textField == lastNameField{
            emailTextField.becomeFirstResponder()
        }
        else if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            logInBtnTapped()
        }
        return true
    }
}

extension RegisterViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    private func presentActionSheet (){
        let actionSheet = UIAlertController(
            title: "Choose the profile",
            message: nil,
            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(
                                title: "Choose from library",
                                style: .default,
                                handler: { [weak self]action in
                                    self?.presentPhotoLibrary()
                                    
                                }))
        actionSheet.addAction(UIAlertAction(
                                title: "Take from camera",
                                style: .default,
                                handler: {[weak self] action in
                                    self?.presentCamera()
                                    
                                }))
        actionSheet.addAction(UIAlertAction(
                                title: "Cancel",
                                style: .cancel,
                                handler: { action in
                                    
                                }))
        present(actionSheet, animated: true, completion: nil)
    }
    private func presentCamera(){
       let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = .camera
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
    private func presentPhotoLibrary(){
       let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
    // some delegate function from imagepicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedPhoto = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        imageView.image = selectedPhoto
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
