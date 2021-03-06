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
    static let db = Firestore.firestore()
    static let storage = Storage.storage().reference()
    //upload profile photo to Storage and update User document with photoURL
    static func uploadProfilePhoto(image: UIImage, uid: String) {
        guard let imageData = image.pngData() else {
             return
        }
        let uuid = UUID().uuidString // create unique id for image since fbstorage doesn't let you generate random keys/ids
        let id = "profiles/" + uuid
        print(id)
        storage.child(id).putData(imageData, metadata: nil, completion: { _, error in
            guard error == nil else {
                print("FAILED TO UPLOAD")
                return
            }
            print("upload sucessful")
            print("downloading image URL")
            storage.child(id).downloadURL { (url, error) in
                guard let url = url, error == nil else {
                    print("FAILED TO DOWNLOAD")
                    return
                }
                let urlString = url.absoluteString
                print("download URL: \(urlString)")
                db.collection("User").document(uid).updateData(["photoURL" : urlString])
            }
            
        })
    }
    //Upload image to Firebase Cloud Storage and return images id (to be stored in parking spot)
    static func uploadImage(image: UIImage, completion: @escaping (String?, Error?) -> Void) {
        guard let imageData = image.pngData() else {
             return
        }
        let uuid = UUID().uuidString
        let id = "images/" + uuid
        print(id)
        storage.child(id).putData(imageData, metadata: nil, completion: { _, error in
            guard error == nil else {
                print("FAILED TO UPLOAD")
                completion(nil, error)
                return
            }
            print("upload sucessful")
            print("downloading image URL")
            storage.child(id).downloadURL { (url, error) in
                guard let url = url, error == nil else {
                    print("FAILED TO DOWNLOAD")
                    return
                }
                let urlString = url.absoluteString
                print("download URL: \(urlString)")
                completion(urlString, nil)
            }
            
        })
    }
    //Upload all images for a parking spot and update parking spot document with image id
    static func uploadAllImages(images: [UIImage], spotID: String) {
        for image in images {
            guard let imageData = image.pngData() else {
                 return
            }
            let uuid = UUID().uuidString
            let id = "images/" + uuid
            print(id)
            storage.child(id).putData(imageData, metadata: nil, completion: { _, error in
                guard error == nil else {
                    print("FAILED TO UPLOAD")
                    print(error)
                    return
                }
                print("upload sucessful")
                print("downloading image URL")
                storage.child(id).downloadURL { (url, error) in
                    guard let url = url, error == nil else {
                        print("FAILED TO DOWNLOAD")
                        return
                    }
                    let urlString = url.absoluteString
                    print("download URL: \(urlString)")
                    db.collection(ParkingSpotService.parkingDBName).document(spotID).updateData(["super.images" : FieldValue.arrayUnion([urlString])])
                    print("updated parking spot image field")
                }
            })
        }
    }
    /*
    static func getImage(imageURL: String, completion: @escaping (UIImage?, Error?) -> Void) {
        guard let url = URL(string: imageURL) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            let image = UIImage(data: data)
            completion(image, nil)
        }
        task.resume()
    }
    static func getAllImages(images: [String], completion: @escaping ([UIImage]?, Error?) -> Void) {
        var UIimages = [UIImage]()
        for image in images {
            guard let url = URL(string: image) else {
                return
            }
            let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                guard let UIimage = UIImage(data: data) else {
                    return
                }
                UIimages.append(UIimage)
            }
            task.resume()
        }
        completion(UIimages, nil)
    }*/
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
            let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                let image = UIImage(data: data)
                completion(image, nil)
            }
            task.resume()
        }
    }
}

