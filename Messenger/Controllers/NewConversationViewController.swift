//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Muhammad Abullah on 07/09/2021.
//

import UIKit

class NewConversationViewController: UIViewController {

    // setting up the ui
    private let searchBar : UISearchBar = {
       let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users...."
        return searchBar
    }()
    private let tableView : UITableView = {
       let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    private let noResultLbl : UILabel = {
       let lbl = UILabel()
        lbl.text = "No Result..."
        lbl.isHidden = true
        lbl.textAlignment = .center
        lbl.textColor = .gray
        lbl.font = .systemFont(ofSize: 21, weight: .medium)
        return lbl
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        view.backgroundColor = .white
        searchBar.becomeFirstResponder()
        view.addSubview(tableView)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    @objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension NewConversationViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
