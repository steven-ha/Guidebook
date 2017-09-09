//
//  ProblemViewController.swift
//  ApproachApp
//
//  Created by Steven Ha on 7/26/17.
//  Copyright © 2017 tenshave. All rights reserved.
//

import UIKit
import CoreData

class ProblemController: UIViewController, UIScrollViewDelegate{
    var name: String?
    var grade: String?
    var image_name: String?
    let margin: CGFloat = 8.0
	var scroll: UIScrollView?
	var problemImage: UIImageView?
	var pimage: UIImage?
    var ticklistButtom: UIButton?
    var problemID: Int?
    var problemMC: NSManagedObject?
    var context: NSManagedObjectContext?
    var problem: Problem!
    
    var fetchRequest: NSFetchRequest<NSFetchRequestResult>?
    var resultsRecord: NSFetchedResultsController<NSFetchRequestResult>?
    
    var screen: UIView?
    
    var ticklists: [List] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getLists()
    }
    
    
    
    func getProblem() -> NSManagedObject{
        //let idDesc: NSSortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        
        fetchRequest = Problem.fetchRequest()
        fetchRequest?.predicate = NSPredicate(format: "id == %@", "\(problem.value(forKey: "id") as! Int)")
        fetchRequest?.sortDescriptors = []
        resultsRecord = NSFetchedResultsController(fetchRequest: fetchRequest!, managedObjectContext: context!, sectionNameKeyPath: "id", cacheName: nil)
        
        do {
            try resultsRecord?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        return resultsRecord!.fetchedObjects?[0] as! NSManagedObject
    }
    
    func addTicklist(ticklist: String){
        //let gradeDesc: NSSortDescriptor = NSSortDescriptor(key: "hueco", ascending: true)
        //let alphaDesc: NSSortDescriptor = NSSortDescriptor(key: "alphabet", ascending: true)
        //let nameDesc: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest = List.fetchRequest()
        fetchRequest?.sortDescriptors = []
        fetchRequest?.predicate = NSPredicate(format: "name == %@", ticklist)
        resultsRecord = NSFetchedResultsController(fetchRequest: fetchRequest!, managedObjectContext: context!, sectionNameKeyPath: "name", cacheName: nil)
        
        do {
            try resultsRecord?.performFetch()
            let ticklistMO = resultsRecord?.fetchedObjects?[0] as! NSManagedObject
            
            // Add Address to Person
            let addProblem = ticklistMO.mutableSetValue(forKey: "problems")
            addProblem.add(problemMC!)
            
            try! context!.save()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        print("update done")
    }
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func getLists () {
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        
        do {
            //go get the results
            let searchResults = try getContext().fetch(fetchRequest)
            
            ticklists.removeAll()
            
            for results in searchResults{
                ticklists.append(results)
                
                //print(results.value(forKey: "problems"))
            }
            
            //I like to check the size of the returned results!
            print ("num of results = \(searchResults.count)")
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func dismissTickView(){
        if let window = UIApplication.shared.keyWindow{
            self.screen?.frame = CGRect(x: 0.0, y: window.frame.height, width: (self.screen?.frame.width)!, height: window.frame.height)
        }
    }
	
	func setZoomScale(){
		let imageViewSize = problemImage?.bounds.size
		let scrollViewSize = scroll?.bounds.size
		let widthScale = (scrollViewSize?.width)! / (imageViewSize?.width)!
		let heightScale = (scrollViewSize?.height)! / (imageViewSize?.height)!
		
		scroll?.minimumZoomScale = min(widthScale, heightScale)
		scroll?.zoomScale = min(widthScale, heightScale)
		//scroll?.zoomScale = 1.0
		//scroll?.clipsToBounds = true
		scroll?.contentOffset = CGPoint(x: (scroll?.contentSize.height)!/2 , y: 0.0)
	}
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return problemImage!
	}
	
    var ticklistView: UITableView?
    var imageHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        imageHeight = (self.view.bounds.size.height - UIApplication.shared.statusBarFrame.height - (self.navigationController?.navigationBar.bounds.size.height)!) / 2
        
        let problemImageFrame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.size.width, height: imageHeight!)
        
        pimage = UIImage(named: problem.value(forKey: "image") as! String)

        
        
        problemImage = UIImageView(frame: problemImageFrame)
        problemImage?.contentMode = .scaleAspectFit

        problemImage?.image = pimage

        self.view.addSubview(problemImage!)


        
        /*
        scroll = UIScrollView(frame: problemImageFrame)
        scroll?.delegate = self
        scroll?.backgroundColor = UIColor.black
        

        
        scroll?.contentSize = CGSize(width: (problemImage?.image?.size.width)!, height: (problemImage?.image?.size.height)!)
        scroll?.contentMode = .scaleAspectFill
        
        scroll?.alwaysBounceVertical = false
        scroll?.alwaysBounceHorizontal = false
        
        scroll?.isScrollEnabled = true
        scroll?.minimumZoomScale = 1.0
        scroll?.maximumZoomScale = 2.5
        
        self.view.addSubview(scroll!)
        
        setZoomScale()
        
        //scroll?.contentSize.width
        
        
        let nameFrame = CGRect(x: margin, y: (margin + problemImageFrame.maxY), width: self.view.bounds.size.width, height: 30.0)
        let nameLabel = UILabel(frame: nameFrame)
        nameLabel.text = name!
        self.view.addSubview(nameLabel)
        
        let gradeFrame = CGRect(x: margin, y: (margin + problemImageFrame.minY + nameFrame.maxY), width: self.view.bounds.size.width, height: 30.0)
        
        let gradeLabel = UILabel(frame: gradeFrame)
        gradeLabel.text = grade!
        self.view.addSubview(gradeLabel)
        
        let buttonFrame = CGRect(x: margin, y: gradeFrame.maxY, width: 100.0, height: 25.0)
        ticklistButtom = UIButton(frame: buttonFrame)
        ticklistButtom?.backgroundColor = UIColor.green
        ticklistButtom?.setTitle("buttons", for: .normal)
        ticklistButtom?.addTarget(self, action: #selector(showTicklists), for: UIControlEvents.touchUpInside)
        self.view.addSubview(ticklistButtom!)
        context = getContext()
        getProblem()
        */
        context = getContext()
        problemMC = getProblem()
        setupButtons()
        print(problem)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let tabBarVC = UIApplication.shared.delegate?.window??.rootViewController as! TabController
        tabBarVC.tabBar.isHidden = false
        
        try! context?.save()
    }
    
    func setupButtons(){
        mapButton()
        listButton()
    }
    
    func mapButton(){
        let mapButton = UIButton(type: .roundedRect)
        let buttonFrame = CGRect(x: 0.0, y: imageHeight!, width: 50.0, height: 50.0)
        
        mapButton.frame = buttonFrame
        mapButton.setTitle("MAP", for: .normal)
        mapButton.setTitleColor(UIColor.black, for: .normal)
        mapButton.backgroundColor = UIColor.green
        mapButton.showsTouchWhenHighlighted = true
        mapButton.addTarget(self, action: #selector(showMap), for: .touchUpInside)

        self.view.addSubview(mapButton)
    }
    
    func listButton(){
        let listButton = UIButton(type: .roundedRect)
        let buttonFrame = CGRect(x: 50.0, y: imageHeight!, width: 50.0, height: 50.0)
        
        listButton.frame = buttonFrame
        listButton.setTitle("LIST", for: .normal)
        listButton.setTitleColor(UIColor.black, for: .normal)
        listButton.backgroundColor = UIColor.blue
        listButton.showsTouchWhenHighlighted = true
        listButton.addTarget(self, action: #selector(showTicklists), for: .touchUpInside)
        
        self.view.addSubview(listButton)
    }
    
    func showMap(){
        /*CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "switchTabsNotification"), object: nil)
        }
        self.navigationController?.popToRootViewController(animated: true)
        CATransaction.commit()*/
		
		let tabVC = UIApplication.shared.delegate?.window??.rootViewController as! TabController
		let navVC = tabVC.viewControllers?[0] as! UINavigationController
		let mapVC = navVC.topViewController as! MapController
		
		mapVC.longitude = problem.longitude
		mapVC.latitude = problem.latitude
		
		
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "switchTabsNotification"), object: nil)
        self.navigationController?.popViewController(animated: true)
        //self.tabBarController?.selectedIndex = 0

        print("MAP")
    }
    
    func showTicklists(){
        
        screen = UIView(frame: self.view.bounds)
        
        screen?.backgroundColor = UIColor.init(white: 0.0, alpha: 0.8)
        self.view.addSubview(screen!)
        
        let labelFrame =  CGRect(x: 25.0, y: 25.0, width: (self.view.bounds.size.width * 0.9), height: 32.0)
        let label = UILabel(frame: labelFrame)
        label.backgroundColor = UIColor.gray
        label.clipsToBounds = true
        label.numberOfLines = 2
        label.font = UIFont(name: "Arial", size: 24.0)
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.text = "Select Ticklist"
        screen?.addSubview(label)
        
        let ticklistFrame = CGRect(x: 25.0, y: (labelFrame.maxY), width: (self.view.bounds.size.width * 0.9), height: (self.view.bounds.size.height * 0.6))
        ticklistView = UITableView(frame: ticklistFrame, style: .plain)
        ticklistView?.delegate = self
        ticklistView?.dataSource = self
        ticklistView?.register(UITableViewCell.self, forCellReuseIdentifier: "ticklist")
        screen?.addSubview(ticklistView!)
        
        let buttonFrame = CGRect(x: 25.0, y: (ticklistFrame.maxY), width: (self.view.bounds.size.width * 0.9), height: 32.0)
        let button = UIButton(frame: buttonFrame)
        button.backgroundColor = UIColor.lightGray
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleShadowColor(UIColor.gray, for: .highlighted)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(dismissTickView), for: .touchUpInside)
        
        screen?.addSubview(button)
        
        ticklistView?.reloadData()
    }
}

extension ProblemController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticklists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .default, reuseIdentifier: "ticklist")
        cell = tableView.dequeueReusableCell(withIdentifier: "ticklist", for: indexPath)
        
        print("names are are \(ticklists[indexPath.row].value(forKey: "name") as! String)")
        cell.textLabel?.text = ticklists[indexPath.row].value(forKey: "name") as? String
        //cell.textLabel?.text = "steven dong ha"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let ticklistName = cell?.textLabel?.text!
        
        addTicklist(ticklist: ticklistName!)
        dismissTickView()
    }
}
