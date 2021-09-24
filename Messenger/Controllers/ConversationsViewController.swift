//
//  ViewController.swift
//  Messenger
//
//  Created by Muhammad Abullah on 07/09/2021.
//

import UIKit
import FirebaseAuth
class ConversationsViewController: UIViewController {
    
    // setting up the ui elements of conversations view controller programaticaly
    private let tableView : UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noConversationLbl : UILabel = {
        let label = UILabel()
        label.text = "No Conversation"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTappedComposedBtn))
        view.addSubview(tableView)
        view.addSubview(noConversationLbl)
        setUpTableView()
        fetchConversation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }

    private func setUpTableView(){
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func fetchConversation(){
        tableView.isHidden = false
        // not going to implement it yet
    }
    
    @objc private func didTappedComposedBtn(){
       let vc = NewConversationViewController()
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true, completion: nil)
    }
    
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil{
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false, completion: nil)
        }
    }

}

// for table view delgates and datasource

extension ConversationsViewController : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.text = "Hello world"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatViewController()
        vc.title = "Ayub ahmad"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
