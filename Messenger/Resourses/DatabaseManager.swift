//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Muhammad Abullah on 10/09/2021.
//

import Foundation
import FirebaseDatabase
final class DatabaseManager{
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    static func safeEmail(emailAddress : String)->String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}
// Mark - Account Management
extension DatabaseManager{
    /// It checks whether the account with this email is already present or not ..
    public func userExist(with email: String,completion : @escaping ((Bool)->Void)){
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value) { snapShot in
            if  snapShot.value as? [String : String]  != nil {
                completion(false)
                return
            }
            completion(true)
        }
    }
    /// Insert the user data into the realtime database
    public func insertUser(with user : ChatAppUser, completion : @escaping (Bool)->Void){
        database.child(user.safeEmail).setValue(
            [
                "first_name":user.firstName,
                "last_name":user.lastName,
                
            ]) { error, _ in
            guard error == nil else{
                print("Falid to write on database")
                completion(false)
                return
            }
            self.database.child("users").observeSingleEvent(of: .value) { snapShot in
                if var usersCollection = snapShot.value as? [ [ String : String ]]{
                    let newElement  =
                        [
                            "name" : user.firstName + " " + user.lastName ,
                            "email" : user.emailAddress
                        ]
                    
                    usersCollection.append(newElement)
                    self.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                    
                }
                else{
                    // create the array
                    let newCollection : [[ String : String ]] =
                        [
                            [
                                "name" : user.firstName + " " + user.lastName ,
                                "email" : user.emailAddress
                            ]
                        ]
                    self.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        }
    }
    /// used to search the users form the database
    public func getAllUsers(completion : @escaping (Result< [ [ String:String ] ] , Error >)->Void){
       
        database.child("users").observeSingleEvent(of: .value) {   snapShot in
            guard let value = snapShot.value as? [[String:String]] else{
                completion(.failure(DataBaseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        }
      }
    public enum DataBaseErrors: Error{
        case failedToFetch
    }
    /*
     users => [
        [
            "name":
            "safe_email"
        ],
        [
         "name":
         "safe_email"
        ]
     ]
     
     */
 }
 

// MARK - sending and recieving the convo from the databsase

extension DatabaseManager{
    
    // Schema of databse for the conversation
    /*
     "dsdsfdfdsfdsdsf":{
         "messages" : [
             "id": String
             "type": text,photo,video
             "content": String
             "date": Date()
             "sender_email": String
             "isRead": true/false
         ]
    }
     
     conversation => [
        [
            "conversation_id": "dsdsfdfdsfdsdsf"
            "other_user_email": String
            "lastest_message": =>{
                "date":Date()
                "latest_message" : "message"
                "is_read" : true/false
            }
        ]
     ]
     
     */
    /// create a new conversation with the target user email and first message sent
    public func  createNewconversation(with otherEmailUser : String,
                               firstMessage : Message ,
                               name : String ,
                               completion : @escaping (Bool) -> Void)  {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let currentUserSafeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        let refer = database.child(currentUserSafeEmail)
        refer.observeSingleEvent(of: .value) { [weak self ]snapshot in
            guard var userNode = snapshot.value as? [String:Any] else{
                completion(false)
                print("User not found ")
                return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            //in this switch we are going to handle all kind of messages text, video , audio , photo
            switch firstMessage.kind{
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            //
            let newConversationData : [String : Any]  = [
                "id" : conversationID,
                "other_user_email" : otherEmailUser,
                "name" : name,
                "latest_message": [
                    "date": dateString ,
                    "message" : message ,
                    "isRead":false,
                ]
            ]
            
            let recipient_newConversationData : [String : Any]  = [
                "id" : conversationID,
                "other_user_email" : currentUserSafeEmail,
                "name" : "self",
                "latest_message": [
                    "date": dateString ,
                    "message" : message ,
                    "isRead":false,
                ]
            ]
            // update for reciptient user conversation entry
            let otherUserSafeEmail = DatabaseManager.safeEmail(emailAddress: otherEmailUser)
            self?.database.child("\(otherUserSafeEmail)/conversations").observeSingleEvent(of :.value) { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String:Any]]
                    {
                    // append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserSafeEmail)/conversations").setValue(conversations)
                }
                else{
                    // create new convo
                    self?.database.child("\(otherUserSafeEmail)/conversations").setValue([recipient_newConversationData])
                    
                }
            }
            
            // update current user conversation entery
            if var conversation = userNode["conversations"] as? [[String:Any]]{
                // conversation exits for current user
                // you should append in it
                conversation.append(newConversationData)
                userNode["conversations"] = conversation
                refer.setValue(userNode) { [weak self ]error, _ in
                    if  error != nil {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationID,
                                                    firstMessage: firstMessage,
                                                    name: name,
                                                    completion: completion)
                }
            }
            else{
               // conversation array does not exit
               //   create it
                userNode["conversations"] = [
                    newConversationData
                ]
                refer.setValue(userNode) { [weak self] error, _ in
                    if  error != nil {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationID,
                                                    firstMessage: firstMessage,
                                                    name: name,
                                                    completion: completion)
                    
                }
            }
        }
    }
    //
    private func finishCreatingConversation(conversationID : String,
                                            firstMessage : Message ,
                                            name : String,
                                            completion : @escaping (Bool)-> Void){
        
/*
         [
            "id": String
            "type": text,photo,video
            "content": String
            "date": Date()
            "sender_email": String
            "isRead": true/false
       ]
*/
        
        
        var message = ""
        
        //in this switch we are going to handle all kind of messages text, video , audio , photo
        switch firstMessage.kind{
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        
        let currentUserSafeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let collectionMessage : [String : Any] =
            [
                "id" : firstMessage.messageId,
                "type": firstMessage.kind.messageKindString,
                "name": name,
                "content": message,
                "date": dateString,
                "sender_email": currentUserSafeEmail,
                "isRead": false
            ]
        
        let value : [String : Any] = [
            "messages":
            [
                collectionMessage
            ]
        ]
        print("Adding convo\(conversationID)")
        database.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else{
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Fetches and return all conversations for the user with passed in email
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation],Error>) ->Void){
        database.child("\(email)/conversations").observe(.value) { snapShot in
            // this completion is called every time the new message is arrived in conversation
            guard let value = snapShot.value as? [[String:Any]] else{
                completion(.failure(DataBaseErrors.failedToFetch))
                return
            }
//            "id" : conversationID,
//            "other_user_email" : otherEmailUser,
//            "name" : name,
//            "latest_message": [
//                "date": dateString ,
//                "message" : message ,
//                "isRead":false,
            let conversation : [Conversation] = value.compactMap { dictionery in
                guard let conversationId = dictionery["id"] as? String,
                      let otherUserEmail = dictionery["other_user_email"] as? String,
                      let name = dictionery["name"] as? String,
                      let latestMessage = dictionery["latest_message"] as? [String:Any] ,
                      let date = latestMessage["date"] as? String ,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["isRead"] as? Bool
                else{
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
            }
            completion(.success(conversation))
        }
    }
    ///get all the method for the given conversation
    public func getAllMessageForConversation(wiht id : String , completion : @escaping (Result<[Message],Error>)->Void){
        database.child("\(id)/messages").observe(.value) { snapShot in
            // this completion is called every time the new message is arrived in conversation
            guard let value = snapShot.value as? [[String:Any]] else{
                completion(.failure(DataBaseErrors.failedToFetch))
                return
            }
        /*
             "dsdsfdfdsfdsdsf":{
                 "messages" : [
                     "id": String
                     "type": text,photo,video
                     "content": String
                     "date": Date()
                     "sender_email": String
                     "name":String
                     "isRead": true/false
                 ]
            }
        */
            let messages : [Message] = value.compactMap { dictionery in
                
                guard let name = dictionery["name"] as? String,
                      let messageId = dictionery["id"] as? String,
                      let type = dictionery["type"] as? String,
                      let content = dictionery["content"] as? String,
                      let dateString = dictionery["date"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString),
                      let senderEmail = dictionery["sender_email"] as? String,
                      let isRead = dictionery["isRead"] as? Bool
                else{
                    return nil
                }
                
                let senderType = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                
                return Message(sender: senderType,
                               messageId: messageId,
                               sentDate: date,
                               kind: .text(content) )
                
            }
            completion(.success(messages))
        }
    }
    ///Sent a messag with target conversation and message
    public func sendMessage(to conversation : String , message: Message , completion: @escaping (Bool)->Void){
        
    }
}

 struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    var safeEmail:String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName : String {
        return "\(safeEmail)_profile_picture.png"
    }
}
