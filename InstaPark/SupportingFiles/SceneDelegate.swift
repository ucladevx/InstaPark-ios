//
//  SceneDelegate.swift
//  InstaPark
//
//  Created by Tony Jiang on 10/27/20.
//

import UIKit
import GoogleSignIn
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate, GIDSignInDelegate {

    var window: UIWindow?

    //Launch
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("Scene launched")
        let storyboard =  UIStoryboard(name: "Main", bundle: nil)
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            if Auth.auth().currentUser != nil {
                // direct to map
                let MapViewVC = storyboard.instantiateViewController(withIdentifier: "MapViewVC")
                let navigationController = UINavigationController.init(rootViewController: MapViewVC)
                self.window?.rootViewController = navigationController
                self.window!.makeKeyAndVisible()
            } else {
                // direct to login
                self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
//                self.window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "MapViewVC")
                self.window!.makeKeyAndVisible()
            }
        }
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
    }

    // handle the sign in to direct to the home controller
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        print("Handle Google login")

        if error != nil {
            print("Google sign in failed. Error: \(error.debugDescription)")
            return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                AuthService.createUserDocument(authResult: authResult!)
                print("Login success")
                let storyboard =  UIStoryboard(name: "Main", bundle: nil)
                self.window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "MapViewVC")
                self.window!.makeKeyAndVisible()
            }
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

