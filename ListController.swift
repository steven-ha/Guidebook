//
//  ListViewController.swift
//  ApproachApp
//
//  Created by Steven Ha on 8/7/17.
//  Copyright © 2017 tenshave. All rights reserved.
//

import UIKit
import CoreData

class ListController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    var problems: NSSet?
    var tableView: UITableView?
    var probController: ProbController?
    var ticklist: List?
    
    var fetchRequest: NSFetchRequest<NSFetchRequestResult>?
    var resultsRecord: NSFetchedResultsController<NSFetchRequestResult>?
    var sectIndexTitles: [String] = []
    
    var context: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height))
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(ProblemCell.self, forCellReuseIdentifier: "problems")
        
        self.view.addSubview(tableView!)
        
        
        

        
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        
        getTicklist()
        
        let problems = self.resultsRecord?.fetchedObjects as! [Problem]
        
        for problem in problems{
            print(problem.value(forKey: "id") as! Int)
        }
	}
    
    func getTicklist () {
        /*if let problemArr = problems {
            for problem in problemArr{
                print((problem as! Problem).value(forKey: "name") as! String)
                //print(problem)
            }
        } else{
            print("empty problem array")
        }*/
        
        retrieveProblems(sort: 0)
        updateTable()
    }
}

extension ListController{
    func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = resultsRecord {
            return frc.sections!.count
        }
        
        //print(resultsRecord?.sections!.count)
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.resultsRecord?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "problems") as! ProblemCell
        guard let object = self.resultsRecord?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
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
        
        cell.object = object
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (320 * 0.25 + 16)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let probs = (problems?.allObjects as! [Problem])[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! ProblemCell
        
        //print(probs)
        
        probController?.problem = cell.problem
        probController?.object = cell.object
        
        self.navigationController?.pushViewController(probController!, animated: false)
    }

    
    func updateTable(){
        self.tableView?.reloadData()
    }
    
    func setupFetchRequest(sortDescriptors: [NSSortDescriptor], sectionNameKeyPath: String){
        
        fetchRequest = Problem.fetchRequest()
        
        //print("print ticklist id: \(ticklist?.id)")
        
        fetchRequest?.sortDescriptors = sortDescriptors
        fetchRequest?.predicate = NSPredicate(format: "ANY ticklists.id == %@", "\((ticklist?.id)!)")
        resultsRecord = NSFetchedResultsController(fetchRequest: fetchRequest!, managedObjectContext: context!, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
    }
    
    func retrieveProblems (sort: Int) {
        
        let gradeDesc: NSSortDescriptor = NSSortDescriptor(key: "hueco", ascending: true)
        //let alphaDesc: NSSortDescriptor = NSSortDescriptor(key: "alphabet", ascending: true)
        let nameDesc: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        /*if segmentedControl.selectedSegmentIndex == 0{
            setupFetchRequest(sortDescriptors: [gradeDesc, nameDesc], sectionNameKeyPath: "hueco")
        } else {
            setupFetchRequest(sortDescriptors: [alphaDesc, nameDesc, gradeDesc], sectionNameKeyPath: "alphabet")
        }*/
        
        setupFetchRequest(sortDescriptors: [gradeDesc, nameDesc], sectionNameKeyPath: "hueco")

        
        do {
            try resultsRecord?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
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
        
        /*if segmentedControl.selectedSegmentIndex == 0{
            return sectIndexTitles
        }
        else {
            return resultsRecord?.sectionIndexTitles
        }*/
        
        return resultsRecord?.sectionIndexTitles
    }
    
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sectIndexTitles.index(of: title)!
    }
}
