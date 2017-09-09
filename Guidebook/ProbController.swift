//
//  ProbController.swift
//  ApproachApp
//
//  Created by Steven Ha on 8/18/17.
//  Copyright © 2017 tenshave. All rights reserved.
//

import UIKit
import CoreData

@objc protocol ProbControllerDelegate {
	@objc optional func updateCenter(latitude: Double, longitude: Double)
	@objc optional func displayMap(change: Bool)
    @objc optional func storeGuideProblem(store: Bool)
    @objc optional func storeList(store:Bool)
    @objc optional func animatedMarker(object: NSFetchRequestResult)
}

class ProbController: UIViewController {
    
    var fetchRequest: NSFetchRequest<NSFetchRequestResult>?
    var resultsRecord: NSFetchedResultsController<NSFetchRequestResult>?
    
	
    let imageview: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
	
	let listButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("List", for: .normal)
		button.setTitleColor(UIColor.black, for: .normal)
		button.backgroundColor = UIColor.lightGray
		button.addTarget(self, action: #selector(showLists), for: .touchUpInside)
		return button
	}()
    
    let mapButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Map", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: #selector(showMap), for: .touchUpInside)
        return button
    }()
    
    let panoramaButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Panorama", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: #selector(displayPanaroma), for: .touchUpInside)
        return button
    }()
	
	let sp = StoreProblem()
	
	var problem: Problem?
    var name: UILabel?
    var grade: UILabel?
    var delegate: ProbControllerDelegate?
    var object: NSFetchRequestResult?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.edgesForExtendedLayout = []
        
        name = createLabel()
        grade = createLabel()
        
        setupView()

        self.view.addSubview(imageview)
        self.view.addSubview(name!)
        self.view.addSubview(grade!)
		self.view.addSubview(listButton)
        self.view.addSubview(mapButton)
        self.view.addSubview(panoramaButton)

        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        setupView()

    }
    
    func setupView(){
        imageview.image = UIImage(named: problem?.value(forKey: "image") as! String)
        imageview.contentMode = .scaleAspectFit
        
        name?.text = problem?.value(forKey: "name") as? String
        grade?.text = problem?.value(forKey: "hueco") as? String
    }

    func setupConstraints(){
        imageview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageview.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        imageview.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        
        name?.topAnchor.constraint(equalTo: imageview.bottomAnchor, constant: 8.0).isActive = true
        name?.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16.0).isActive = true
        name?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        grade?.topAnchor.constraint(equalTo: (name?.bottomAnchor)!, constant: 8.0).isActive = true
        grade?.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16.0).isActive = true
        grade?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		
		listButton.topAnchor.constraint(equalTo: (grade?.bottomAnchor)!, constant: 8.0).isActive = true
		listButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16.0).isActive = true
		listButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        mapButton.topAnchor.constraint(equalTo: listButton.bottomAnchor, constant: 8.0).isActive = true
        mapButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16.0).isActive = true
        mapButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        panoramaButton.topAnchor.constraint(equalTo: mapButton.bottomAnchor, constant: 8.0).isActive = true
        panoramaButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16.0).isActive = true
        panoramaButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func createLabel() -> UILabel{
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

	func showLists(){
		sp.addProblem()
        retrieveLists()
		
		let ticklistView = UIView(frame: (self.navigationController?.view.frame)!)
		ticklistView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.25)
		ticklistView.tag = 1000
		
		self.navigationController?.view.addSubview(ticklistView)
		
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = UIColor.green
		button.setTitle("CANCEL", for: .normal)
		button.setTitleColor(UIColor.black, for: .normal)
		button.addTarget(self, action: #selector(dismissLists), for: .touchUpInside)
		
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.backgroundColor = UIColor.blue
		
		tableView.delegate = self
		tableView.dataSource = self

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "listReuse")

		ticklistView.addSubview(button)
		ticklistView.addSubview(tableView)
		
		tableView.heightAnchor.constraint(equalTo: ticklistView.heightAnchor, multiplier: 0.5).isActive = true
		tableView.widthAnchor.constraint(equalTo: ticklistView.widthAnchor, constant: -16.0).isActive = true
		tableView.centerXAnchor.constraint(equalTo: ticklistView.centerXAnchor).isActive = true
		tableView.centerYAnchor.constraint(equalTo: ticklistView.centerYAnchor).isActive = true
		
		button.centerXAnchor.constraint(equalTo: ticklistView.centerXAnchor).isActive = true
		button.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8.0).isActive = true
		
	}
    
    func showMap(){
        delegate?.updateCenter?(latitude: problem?.value(forKey: "latitude") as! Double , longitude: problem?.value(forKey: "longitude") as! Double)
		delegate?.displayMap?(change: true)
        
        let viewCount = self.navigationController?.viewControllers.count
        
        if viewCount == 2 {
            delegate?.storeGuideProblem?(store: true)
            print("2 views in stack")

        } else if viewCount == 3 {
            delegate?.storeList?(store: true)
        }

        delegate?.animatedMarker!(object: object!)

        
        self.navigationController?.popToRootViewController(animated: false)
        
    }
    
    func centerMap(){
        print("prob centered")
    }

    func showMarker(){
        
    }
}

extension ProbController: UITableViewDataSource, UITableViewDelegate{
    

	
	func dismissLists(){
		let listView = self.navigationController?.view.viewWithTag(1000)
		listView?.removeFromSuperview()
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.resultsRecord?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        //let sectionInfo = sections[section]
        print(sections.count)
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listReuse")
        
        guard let object = self.resultsRecord?.sections else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        let selectTicklist = object[indexPath.row]
        
        cell?.textLabel?.text = (selectTicklist.objects?[0] as! List).name
        
        return cell!
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let ticklistID = cell?.textLabel?.text
        addTicklist(ticklist: ticklistID!)
        dismissLists()
	}
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func setupFetchRequest(sortDescriptors: [NSSortDescriptor], sectionNameKeyPath: String){
        
        let context = getContext()
        fetchRequest = List.fetchRequest()
        fetchRequest?.sortDescriptors = sortDescriptors
        fetchRequest?.predicate = NSPredicate(format: "location == %@", "1")
        resultsRecord = NSFetchedResultsController(fetchRequest: fetchRequest!, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
    }
    
    func retrieveLists () {
        
        let id: NSSortDescriptor = NSSortDescriptor(key: "id", ascending: true)

        setupFetchRequest(sortDescriptors: [id], sectionNameKeyPath: "id")

        do {
            try resultsRecord?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
    }
    
    func addTicklist(ticklist: String){
        let context = getContext()
        
        fetchRequest = List.fetchRequest()
        fetchRequest?.sortDescriptors = []
        fetchRequest?.predicate = NSPredicate(format: "name == %@", ticklist)
        resultsRecord = NSFetchedResultsController(fetchRequest: fetchRequest!, managedObjectContext: context, sectionNameKeyPath: "name", cacheName: nil)
        
        do {
            try resultsRecord?.performFetch()
            let ticklistMO = resultsRecord?.fetchedObjects?[0] as! NSManagedObject
            
            // Add Address to Person
            let addProblem = ticklistMO.mutableSetValue(forKey: "problems")
            addProblem.add(problem!)
            
            try! context.save()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        print("update done")
    }
    
    func displayPanaroma() {
        let panoramaView = PanoramaController()
        
        panoramaView.panoramaTitle = (problem?.panorama)!
        
        print((problem?.panorama)!)
        
        self.navigationController?.pushViewController(panoramaView, animated: true)
    }
}

