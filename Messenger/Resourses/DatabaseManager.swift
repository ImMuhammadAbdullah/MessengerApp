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
   
}
// Mark - Account Management
extension DatabaseManager{
    /// It checks whether the account with this email is already present or not ..
    public func userExist(with email: String,completion : @escaping ((Bool)->Void)){
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value) { snapShot in
            guard  snapShot.value as? String != nil else{
                completion(false)
                return
            }
            completion(true)
        }
    }
    /// Insert the user data into the realtime database
    public func insertUser(with user : ChatAppUser){
        database.child(user.safeEmail).setValue(
            [
                "first_name":user.firstName,
                "last_name":user.lastName,
                
            ]
        )
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
}
