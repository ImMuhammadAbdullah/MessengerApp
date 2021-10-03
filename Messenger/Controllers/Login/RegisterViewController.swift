//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Muhammad Abullah on 07/09/2021.
//

import UIKit
import FirebaseAuth
import NVActivityIndicatorView
class RegisterViewController: UIViewController {
    // settig UI elements here
    private let loder : NVActivityIndicatorView = {
        let loder = NVActivityIndicatorView(frame: CGRect(x:0 , y: 0, width: 52 , height: 52), type: .ballClipRotatePulse, color: .link, padding: nil)
        return loder
    }()
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
        title = "Registration"
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
        scrollVeiw.addSubview(loder)
        
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
        loder.center = view.center
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
        loder.startAnimating()
        if filedError != nil {
            // There's something wrong with the fields, show error message
            loder.stopAnimating()
            alert(message: filedError!)
        }
        else if passwordError != nil && emailError != nil{
            loder.stopAnimating()
            alert(message: passwordError! + "\n" + emailError!)
        }
        else if passwordError != nil && emailError == nil{
            loder.stopAnimating()
            alert(message: passwordError! )
        }
        else if passwordError == nil && emailError != nil{
            loder.stopAnimating()
            alert(message: emailError! )
        }
        // Firebase log in
        else{
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let firstName = firstNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName  = lastNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            DatabaseManager.shared.userExist(with: email) { [weak self] exits in
                guard let self =  self else{
                    return
                }
                if exits == false{
                    self.loder.stopAnimating()
                    self.alert(message: "User with this email alreay exists")
                    return
                }
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self]result, error in
                    guard let self =  self else{
                        return
                    }
                    if error != nil{
                        self.loder.stopAnimating()
                        self.alert(message: "Error in creating account")
                    }
                    else{
                        let chatUser = ChatAppUser(
                            firstName: firstName,
                            lastName: lastName,
                            emailAddress: email)
                        DatabaseManager.shared.insertUser(with: chatUser) { success in
                            if success{
                                UserDefaults.standard.setValue(email, forKey: "email")
                                UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                                // upload the profile picture
                                guard let image = self.imageView.image, let data = image.pngData() else {
                                    return
                                }
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
                            }
                        }
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                }
            }
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
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.sourceType = .camera
            vc.allowsEditing = true
            present(vc, animated: true, completion: nil)
        }
        else{
            alert(message: "You are simulater .")
        }
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


