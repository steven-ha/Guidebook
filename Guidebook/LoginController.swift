//
//  LoginController.swift
//  ApproachApp
//
//  Created by Steven Ha on 8/15/17.
//  Copyright © 2017 tenshave. All rights reserved.
//

import UIKit
//import Firebase

class LoginController: UIViewController {
    
    let inputsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let email: LeftPadTextField = {
        let textfield = LeftPadTextField()
        textfield.backgroundColor = UIColor.white
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "Email"
        return textfield
    }()
	
	let firstSpace: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.gray
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
    
    let password: LeftPadTextField = {
        let textfield = LeftPadTextField()
        textfield.backgroundColor = UIColor.white
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "Password"
        textfield.isSecureTextEntry = true
        return textfield
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    var mainController: MainNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: 100/255, green: 160/255, blue: 180/255, alpha: 1.0)
        self.view.addSubview(inputsContainer)
        self.view.addSubview(button)
        
        inputsContainer.addSubview(email)
		inputsContainer.addSubview(firstSpace)
        inputsContainer.addSubview(password)
        
        setupConstraints()
    }
    
    func handleLogin(){
        /*Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
            // ...
            print("user: \(user?.uid)")
        }*/
        
        
        
        
        mainController?.finishLoggingIn()
		dismiss(animated: true, completion: nil)
    }

    func setupConstraints(){
        inputsContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16.0).isActive = true
        inputsContainer.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: (view.frame.height * 0.33)).isActive = true
        inputsContainer.layoutMarginsGuide.bottomAnchor.constraint(equalTo: password.bottomAnchor).isActive = true
        inputsContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        email.topAnchor.constraint(equalTo: inputsContainer.layoutMarginsGuide.topAnchor).isActive = true
        email.leadingAnchor.constraint(equalTo: inputsContainer.layoutMarginsGuide.leadingAnchor).isActive = true
		email.trailingAnchor.constraint(equalTo: inputsContainer.layoutMarginsGuide.trailingAnchor).isActive = true
		email.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
		firstSpace.topAnchor.constraint(equalTo: email.bottomAnchor).isActive = true
		firstSpace.leadingAnchor.constraint(equalTo: inputsContainer.layoutMarginsGuide.leadingAnchor).isActive = true
		firstSpace.trailingAnchor.constraint(equalTo: inputsContainer.layoutMarginsGuide.trailingAnchor).isActive = true
		firstSpace.heightAnchor.constraint(equalToConstant: 1.25).isActive = true
        
        password.topAnchor.constraint(equalTo: firstSpace.bottomAnchor).isActive = true
        password.leadingAnchor.constraint(equalTo: inputsContainer.layoutMarginsGuide.leadingAnchor).isActive = true
        password.trailingAnchor.constraint(equalTo: inputsContainer.layoutMarginsGuide.trailingAnchor).isActive = true
        password.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        button.topAnchor.constraint(equalTo: inputsContainer.bottomAnchor, constant: 8.0).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

}

class LeftPadTextField: UITextField{
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height);
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds: bounds);
    }
}
