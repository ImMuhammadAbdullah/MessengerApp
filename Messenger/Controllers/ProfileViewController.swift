//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Muhammad Abullah on 07/09/2021.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
class ProfileViewController: UIViewController {

    
    let data = ["Log out"]
    @IBOutlet var tableView : UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }
    
     func createTableHeader() ->UIView?{
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/"+fileName
        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 300))
        headerView.backgroundColor = .white
        
        let imageView = UIImageView(frame: CGRect(x: (view.width-150)/2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.link.cgColor
        imageView.backgroundColor = .white
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width / 2
        headerView.addSubview(imageView)
        
        
        StorageManager.shared.downloadURL(for: path) {[weak self] result in
            switch result{
            case .success(let url):
                print(url)
                self?.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("Error in downloding url \(error)")
            }
        }
        return headerView
    }
    
    private func downloadImage(imageView : UIImageView , url : String){
       let referenceURL = URL(string: url)
        guard let referenceURL = referenceURL else {
            return
        }
        URLSession.shared.dataTask(with: referenceURL) {  data, _, error in
            guard let data = data , error == nil else{
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }.resume()
    }
    
    private func alert(message : String)  {
        let alert = UIAlertController(title: "Log In ", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension ProfileViewController : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let actionSheet = UIAlertController(title: "", message: "You want to log out?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log out ", style: .destructive, handler: {[weak self] _ in
            guard let self = self else{
                return
            }
            // Facebook log out
            FBSDKLoginKit.LoginManager().logOut()
            // Google logout goes here
            do{
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginViewController()
                let nav  = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
            catch{
                self.alert(message: "Falid to log in")
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            
        }))
        present(actionSheet, animated: true, completion: nil)
    }
    
}
