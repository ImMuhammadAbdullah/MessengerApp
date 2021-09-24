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
            if  snapShot.value as? String != nil {
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
            completion(true)
        }
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
