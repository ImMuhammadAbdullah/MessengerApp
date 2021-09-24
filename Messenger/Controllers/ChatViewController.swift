//
//  ChatViewController.swift
//  Messenger
//
//  Created by Muhammad Abullah on 22/09/2021.
//

import UIKit
import MessageKit
struct Message : MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
struct Sender : SenderType {
    var photo: String
    var senderId: String
    var displayName: String
}


class ChatViewController: MessagesViewController {

    private var messages = [Message]()
    private let selfSender = Sender(photo: "",
                                    senderId: "1",
                                    displayName: "Ayub Ahmad")
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Oee kidr ha")))
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Oee kidr ha . idr mr oeeee.")))
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello world")))
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello world Hello world Hello world Hello world")))
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    

}

extension ChatViewController : MessagesLayoutDelegate , MessagesDisplayDelegate , MessagesDataSource {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
