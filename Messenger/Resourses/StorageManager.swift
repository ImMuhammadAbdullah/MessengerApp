//
//  StorageManager.swift
//  Messenger
//
//  Created by Muhammad Abullah on 23/09/2021.
//

import Foundation
import FirebaseStorage


final class StorageManager{
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    // typealis
    public typealias uploadPictureCompletion = (Result<String,Error>) ->Void
    /*
     /images/abdullah-gmail-com_profile_picture.png
     */
    /// upload the profile picture to the firebase storage
    public func uploadProfilePicture(with data : Data ,filename : String , completion : @escaping uploadPictureCompletion ){
        storage.child("images/\(filename)").putData(data, metadata: nil) { [weak self] metaData, error in
            
            guard let self = self else{
                return
            }
            
            guard error == nil else{
                print("Falid to upload the picture on storage")
                completion(.failure(StorageErrors.faildToUpload))
                return
            }
            self.storage.child("images/\(filename)").downloadURL {  url, urlError in
                
                if  url == nil {
                    print("Falid to download the picture ulr from the storage")
                    completion(.failure(StorageErrors.faildToDownloadUrl))
                    return
                }
                let urlString = url?.absoluteString
                guard let urlString = urlString else{
                    return
                }
                print("dowload url return : \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    public enum StorageErrors: Error{
        case faildToUpload
        case faildToDownloadUrl
    }
    /// download the photo from the firebase storage
    public func downloadURL(for path : String , completion : @escaping ( Result<String,Error> )-> Void){
        let reference = storage.child(path)
        reference.downloadURL { url, error in
            guard let url = url,error == nil else{
                completion(.failure(StorageErrors.faildToDownloadUrl))
                return
            }
            let urlString = url.absoluteString
            completion(.success(urlString))
        }
    }
    
    
}
