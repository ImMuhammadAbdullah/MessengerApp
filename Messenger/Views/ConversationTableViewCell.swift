//
//  ConversationTableViewCell.swift
//  Messenger
//
//  Created by Muhammad Abullah on 26/09/2021.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifire = "ConversationTableViewCell"
    // setting up UI elements
    private let userImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 50
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private let userNameLable : UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 21, weight: .semibold)
        
        return lable
    }()
    private let userMessageLable : UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 21, weight: .semibold)
        lable.numberOfLines = 0
        return lable
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLable)
        contentView.addSubview(userMessageLable)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 100,
                                     height: 100)
        userNameLable.frame = CGRect(x: userImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.height - 20) / 2)
        userMessageLable.frame = CGRect(x: userImageView.right + 10,
                                        y: userNameLable.bottom + 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.height - 20) / 2)
    }
    
    public func configure(with model : Conversation){
        self.userNameLable.text = model.name
        self.userMessageLable.text = model.latestMessage.text
        /*
         So , I have to download the profile picture throught the download url ,
         for this puporse we have imported the sdwebimage to download and cache what we need
        */
        
        let otherUserSafeEmail = DatabaseManager.safeEmail(emailAddress: model.otherUserEmail)
        let path  = "images/\(otherUserSafeEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path) { [weak self] result in
            
            switch result{
            
            case .success(let url):
                print("downlaod ulr is \(url)")
                let downlaodURL = URL(string: url)
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: downlaodURL, completed: nil)
                }
            case .failure(let error):
                print("Error in downloding the ulr \(error)")
            }
        }
    }


}
