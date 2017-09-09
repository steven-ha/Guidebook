//
//  GuideViewController.swift
//  ApproachApp
//
//  Created by Steven Ha on 7/24/17.
//  Copyright © 2017 tenshave. All rights reserved.
//

import UIKit
import CoreData
//import Firebase

class GuideController: UIViewController, UIGestureRecognizerDelegate{
    var fetchRequest: NSFetchRequest<NSFetchRequestResult>?
    var resultsRecord: NSFetchedResultsController<NSFetchRequestResult>?
	var sectIndexTitles: [String] = []
	var probController: ProbController?
    
    let segmentedControl: UISegmentedControl = {
        let titles = ["grade", "name"]
        let sc = UISegmentedControl(items: titles)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(updateTable), for: .valueChanged)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    lazy var tableView: UITableView = {
        let tableview = UITableView()
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.register(ProblemCell.self, forCellReuseIdentifier: "problem")
        tableview.delegate = self
        tableview.dataSource = self
        return tableview
    }()
    
    var context: NSManagedObjectContext?

	override func viewDidLoad() {
		super.viewDidLoad()
        self.view.addSubview(segmentedControl)
        self.view.addSubview(tableView)
		
        NotificationCenter.default.addObserver(self, selector: #selector(switchTabs), name: NSNotification.Name(rawValue: "switchTabsNotification"), object: nil)

		let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
		longPressGesture.minimumPressDuration = 0.6 // 1 second press
		longPressGesture.delegate = self
		self.tableView.addGestureRecognizer(longPressGesture)
        
        setupConstraints()
        

        //print(Auth.auth().currentUser)
        
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTable()
        //setGuidebookID(id: <#T##Int#>)
    }
    
    func setupConstraints(){
        segmentedControl.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 8.0).isActive = true
        segmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16.0).isActive = true
        segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

    }
    
    func switchTabs() {
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.selectedIndex = 0
    }
	
	func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
		
		if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
			
			let touchPoint = longPressGestureRecognizer.location(in: self.tableView)
			if let indexPath = tableView.indexPathForRow(at: touchPoint) {

				let prob = self.resultsRecord?.object(at: indexPath) as! Problem
				print(prob)
			}
		}
	}
    
    func updateTable(){
        retrieveProblems(sort: segmentedControl.selectedSegmentIndex)
        tableView.reloadData()
    }
    
    func setupFetchRequest(sortDescriptors: [NSSortDescriptor], sectionNameKeyPath: String){
        fetchRequest = Problem.fetchRequest()
        
        fetchRequest?.sortDescriptors = sortDescriptors
        //fetchRequest?.predicate = NSPredicate(format: "toGuidebook.id = ", "\(bookID)")
        resultsRecord = NSFetchedResultsController(fetchRequest: fetchRequest!, managedObjectContext: context!, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
    }
    
    func retrieveProblems (sort: Int) {

        let gradeDesc: NSSortDescriptor = NSSortDescriptor(key: "hueco", ascending: true)
        let alphaDesc: NSSortDescriptor = NSSortDescriptor(key: "alphabet", ascending: true)
        let nameDesc: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        if segmentedControl.selectedSegmentIndex == 0{
            setupFetchRequest(sortDescriptors: [gradeDesc, nameDesc], sectionNameKeyPath: "hueco")
        } else {
            setupFetchRequest(sortDescriptors: [alphaDesc, nameDesc, gradeDesc], sectionNameKeyPath: "alphabet")
        }
        
        do {
            try resultsRecord?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }

    }
	
}

extension GuideController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ProblemCell
        print(cell.name.text!)
        tableView.deselectRow(at: (tableView.indexPathForSelectedRow)!, animated: true)
        
        probController?.problem = cell.problem
        probController?.object = cell.object
        
        //self.navigationController?.present(problem, animated: true, completion: nil)
        self.navigationController?.pushViewController(probController!, animated: false)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.resultsRecord?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "problem") as! ProblemCell
        guard let object = self.resultsRecord?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        cell.object = object
        
        let selectProblem = object as! Problem
        
        cell.problem = selectProblem
        
        let myImage = UIImage(named: selectProblem.value(forKey: "image") as! String)
        
        //let values = (myImage?.size.height)! / (myImage?.size.width)!
        cell.problemImage.clipsToBounds = true
        cell.problemImage.contentMode = .scaleAspectFill
        cell.problemImage.image = myImage
        
        
        cell.name.text = selectProblem.value(forKey: "name") as? String
        cell.grade.text = selectProblem.value(forKey: "hueco") as? String
        
        
        
        cell.imageName = selectProblem.value(forKey: "image") as? String
        
        cell.problemID = Int(selectProblem.value(forKey: "id") as! Int32)

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (320 * 0.25 + 16)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = resultsRecord {
            return frc.sections!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = resultsRecord?.sections?[section] else {
            return nil
        }
        
        return sectionInfo.name
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        sectIndexTitles.removeAll()
                
        for section in (resultsRecord?.sections)!{
            sectIndexTitles.append(section.name)
        }
        
        if segmentedControl.selectedSegmentIndex == 0{
            return sectIndexTitles
        }
        else {
            return resultsRecord?.sectionIndexTitles
        }
    }
    
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sectIndexTitles.index(of: title)!
    }
}


