//
//  SettingController.swift
//  ApproachApp
//
//  Created by Steven Ha on 8/17/17.
//  Copyright © 2017 tenshave. All rights reserved.
//

import UIKit
import CoreData

class SettingController: UIViewController, LibraryControllerDelegate {
    var mainController: MainNavigationController?
    var context: NSManagedObjectContext?
    
    
    var tabController: TabController?
    
    lazy var libraryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("LIBRARY", for: .normal)
        button.addTarget(self, action: #selector(handleLibrary), for: .touchUpInside)
        button.backgroundColor = UIColor.lightGray
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    
    lazy var storeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("STORE", for: .normal)
        button.addTarget(self, action: #selector(handleStore), for: .touchUpInside)
        button.backgroundColor = UIColor.lightGray
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Log Out", for: .normal)
        button.addTarget(self, action: #selector(handleLogouts), for: .touchUpInside)
        button.backgroundColor = UIColor.lightGray
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    
    lazy var dismissButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissSetting))
        return button
    }()
    
    var library: LibraryController = LibraryController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(libraryButton)
        self.view.addSubview(storeButton)
        self.view.addSubview(logoutButton)
        self.navigationItem.leftBarButtonItem = dismissButton
        
        library.delegate = tabController
        library.context = context
        
        setupConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let bookID = tabController?.guideID{
            library.loadedBookID = bookID
            print("library set")
        }
    }
    
    func setupConstraint(){
        libraryButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16.0).isActive = true
        libraryButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 8.0).isActive = true
        libraryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        storeButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16.0).isActive = true
        storeButton.topAnchor.constraint(equalTo: libraryButton.bottomAnchor, constant: 8.0).isActive = true
        storeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        logoutButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16.0).isActive = true
        logoutButton.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -8.0).isActive = true
        logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func handleLibrary(){
        //print("library")
        /*let library = LibraryController()
        library.context = self.context
        
        if let controller = tabController {
            library.delegate = controller as! LibraryControllerDelegate
        }*/
        
        self.navigationController?.pushViewController(library, animated: true)
    }
    
    func handleStore(){
        let store = StoreController()
        store.context = self.context
        
        self.navigationController?.pushViewController(store, animated: true)
    }
    
    func handleLogouts(){
        //print("logged out")
        mainController?.loggedin = false
        dismiss(animated: false, completion: nil)
    }
    
    func dismissSetting(){
        //dismiss(animated: false, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    

}
