//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Muhammad Abullah on 07/09/2021.
//

import UIKit
import NVActivityIndicatorView
class NewConversationViewController: UIViewController {

    private var users = [[ String : String ]]()
    private var results = [[ String : String ]]()
    private var hasFeched = false
    // setting up the ui
    private let loder : NVActivityIndicatorView = {
        let loder = NVActivityIndicatorView(frame: CGRect(x:0 , y: 0, width: 52 , height: 52), type: .ballClipRotatePulse, color: .link, padding: nil)
        return loder
    }()
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
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        view.backgroundColor = .white
        searchBar.becomeFirstResponder()
        view.addSubview(tableView)
        view.addSubview(noResultLbl)
        view.addSubview(loder)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLbl.frame = CGRect(x: view.width/4,
                                   y: (view.height - 200)/2,
                                   width: view.width/2,
                                   height: 200)
        loder.center = view.center
    }
    @objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }
    
    
}
extension NewConversationViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
// implementation of searchbar delegate
extension NewConversationViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text , !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        loder.startAnimating()
        results.removeAll()
        searchUsers(query: text)
    }
    
    func searchUsers(query : String)  {
        // check if array has firebase ressults
        if hasFeched {
            // if it does then filter
            filterUser(with: query)
        }
        else{
            // if not then fecth and filter
            DatabaseManager.shared.getAllUsers { [weak self] result in
                switch result{
                case .success(let userCollection):
                    self?.hasFeched = true
                    self?.users = userCollection
                    self?.filterUser(with: query)
                case .failure(let error):
                    print("Failed to get users\(error)")
                }
            }
        }
        
    }
    func filterUser(with term : String)  {
        guard hasFeched else {
            return
        }
        loder.stopAnimating()
        // update the UI eihter show the result or show users
        let results : [[ String : String ]] = users.filter {
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        }
        self.results = results
        updateUI()
    }
    func updateUI()  {
        if results.isEmpty {
            noResultLbl.isHidden = false
            tableView.isHidden = true
        }
        else{
            tableView.isHidden = false
            noResultLbl.isHidden = true
            tableView.reloadData()
        }
    }
}
