//
//  ChatViewController.swift
//  Messenger
//
//  Created by Muhammad Abullah on 22/09/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message : MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind{
    var messageKindString : String{
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender : SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {

    public static let dateFormatter : DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = .current
        formatter.timeStyle = .long
        return formatter
    }()
    
    public var isNewConversation = false
    public let otherUserEmail : String
    private let conversationId : String?
    private var messages = [Message]()
    private var selfSender : Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let sender = Sender(photoURL: "",
               senderId: safeEmail,
               displayName: "Me")
        return sender
    }
    
    
    init(wiht email : String , id : String?) {
        self.otherUserEmail = email
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
        if let conversationId =  self.conversationId{
            listenForMessages(id: conversationId, shouldScrollToBottom : true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
       
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    private func listenForMessages(id : String , shouldScrollToBottom : Bool){
        DatabaseManager.shared.getAllMessageForConversation(wiht: id) {[weak self] result in
            switch result{
            
            case .success(let messages):
                print("success in getting messages\(messages)")
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
            case .failure(let error):
                print("Error in getting all messages for this conversation\(error)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}
// implementaion of InputBarAccessoryViewDelegate

extension ChatViewController : InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty ,
              let selfSender = self.selfSender,
              let messageId  = createMessageId() else {
            return
        }
        print("Sending text\(text)")
        messageInputBar.inputTextView.text = " "
        // sent message
        if isNewConversation{
            // create a convo in database
            
            // first create the message user going to send
            let message = Message(sender: selfSender,
                                  /*
                                  message id must be unique for every messag.
                                  So, it is otherUserEmail , senderEmail , date and randomInt
                                  */
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .text(text))
            DatabaseManager.shared.createNewconversation(with: otherUserEmail, firstMessage: message ,name: self.title ?? "User") { success in
                if success{
                    print("Message sent")
                }
                else{
                    print("Falied to send")
                }
            }
        }
        else{
            // append to existing convo
        }
    }
    
    private func createMessageId() ->String? {
        // date , senderEmail, otherUserEmail , random int
        
        let dateString  = Self.dateFormatter.string(from: Date())
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String  else {
            return nil
        }
        let currentUserSafeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        let otherUserSafeEmail = DatabaseManager.safeEmail(emailAddress: otherUserEmail)
        let newIdentifire = "\(otherUserSafeEmail)_\(currentUserSafeEmail)_\(dateString)"
        
        print("Created messag id \(newIdentifire)")
        
        return newIdentifire
    }
}

// implementation of message layout ,display, datasource
extension ChatViewController : MessagesLayoutDelegate , MessagesDisplayDelegate , MessagesDataSource {
    func currentSender() -> SenderType {
        if let sender = selfSender{
            return sender
        }
        fatalError("Self sender is nil , email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
