//
//  MainNavigationControllerViewController.swift
//  ApproachApp
//
//  Created by Steven Ha on 8/17/17.
//  Copyright © 2017 tenshave. All rights reserved.
//

import UIKit



class MainNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isLoggedIn() {
            let tabController = TabController()
            tabController.edgesForExtendedLayout = []
            tabController.mainController = self
            
            viewControllers = [tabController]

        } else {
            perform(#selector(showLoginController), with: nil, afterDelay: 0.01)
        }
    }
    
    fileprivate func isLoggedIn() -> Bool {
        return loggedin
    }
    
    var loggedin: Bool = false
    
    func finishLoggingIn(){
        if loggedin {
            loggedin = false
        } else {
            loggedin = true
        }
    }
    
    func showLoginController(){
        let loginController = LoginController()
        loginController.mainController = self
        present(loginController, animated: false, completion: nil)
        
        
        /*
        let panoramaView = PanoramaController()
        
        panoramaView.panoramaTitle = "testImage"
        present(panoramaView, animated: false, completion: nil)*/
    }
    
    func handleLogout(){
        print("handled login from main")
    }
}
