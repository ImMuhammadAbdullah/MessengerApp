//
//  ViewController.swift
//  Messenger
//
//  Created by Muhammad Abullah on 07/09/2021.
//

import UIKit
import FirebaseAuth

// Model for the conversations

struct Conversation {
    let id : String
    let name : String
    let otherUserEmail: String
    let latestMessage : LatestMessage
}

struct LatestMessage {
    let date : String
    let text : String
    let isRead: Bool
}

class ConversationsViewController: UIViewController {
    
    
    private var conversations = [Conversation]()
    // setting up the ui elements of conversations view controller programaticaly
    private let tableView : UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self,
                       forCellReuseIdentifier: ConversationTableViewCell.identifire)
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
        startListeningForConversation()
    }
    
    private func startListeningForConversation(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getAllConversations(for: safeEmail) { [weak self]result in
            guard self != nil else{
                return
            }
            switch result{
            
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    return
                }
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error in getting conversations \(error)")
            }
        }
        
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
        vc.completion = { [weak self] result in
            self?.startNewConversation(result: result)
        }
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true, completion: nil)
    }
    
    private func startNewConversation(result : [String:String]){
        guard let name = result["name"],
              let email = result["email"] else {
            return
        }
        let vc = ChatViewController(wiht: email , id: nil)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
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
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifire ,
                                                 for: indexPath) as! ConversationTableViewCell
        let model = conversations[indexPath.row]
        cell.configure(with: model)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        let vc = ChatViewController(wiht: model.otherUserEmail , id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
