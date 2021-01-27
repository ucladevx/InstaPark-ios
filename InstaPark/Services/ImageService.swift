//
//  ImageService.swift
//  InstaPark
//
//  Created by Yili Liu on 1/26/21.
//

import Foundation
import Firebase
import FirebaseStorage

class ImageService {
    static let storage = Storage.storage().reference()
    
    //Upload image to Firebase Cloud Storage and return images id (to be stored in parking spot)
    static func uploadImage(image: UIImage, completion: @escaping (String?, Error?) -> Void) {
        guard let imageData = image.pngData() else {
             return
        }
        let uuid = UUID().uuidString // create unique id for image since fbstorage doesn't let you generate random keys/ids
        let id = "images/" + uuid
        print(id)
        storage.child(id).putData(imageData, metadata: nil, completion: { _, error in
            guard error == nil else {
                print("FAILED TO UPLOAD")
                completion(nil, error)
                return
            }
            print("upload sucessful")
            completion(id, nil)
        })
    }
    //Gets image from Firebase Storage base on image id string and returns it as a UIImage
    static func downloadImage(id: String, completion: @escaping (UIImage?, Error?) -> Void) {
        //let imagePath = "images/" + id
        storage.child(id).downloadURL { (url, error) in
            guard let url = url, error == nil else {
                print("FAILED TO DOWNLOAD")
                completion(nil, error)
                return
            }
            let urlString = url.absoluteString
            print("download URL: \(urlString)")
            URLSession.shared.dataTask(with: url) { (data, _, error) in
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                let image = UIImage(data: data)
                completion(image, nil)
            }
        }
    }
}

