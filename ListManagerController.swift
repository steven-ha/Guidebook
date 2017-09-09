//
//  ListManagerViewController.swift
//  ApproachApp
//
//  Created by Steven Ha on 7/24/17.
//  Copyright © 2017 tenshave. All rights reserved.
//

import UIKit
import CoreData

struct TicklistStruct{
    var id: Int
    var name: String
    var location: Int
    
    init(id: Int,name: String, location: Int){
        self.id = id
        self.name = name
        self.location = location
    }
}

class ListManagerController: UITableViewController{
    var loadedArea: Int?
    var listContainer: [NSManagedObject] = []
    var resulter: [List]?
    var fetchRequest: NSFetchRequest<NSFetchRequestResult>?
    var resultsRecord: NSFetchedResultsController<NSFetchRequestResult>?
    var probController: ProbController?
    
    lazy var ticklistButton: UIBarButtonItem = {
        UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(createTicklist))
    }()
    
    var context: NSManagedObjectContext?

	override func viewDidLoad() {
		super.viewDidLoad()
        loadedArea = 1

		self.view.backgroundColor = UIColor.white
        
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "listManagerReuse")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getLists()
        tableView.reloadData()
        
        handleBarItemLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        handleBarItemRemove()
    }
    
    func handleBarItemLoad(){
        tabBarController?.navigationItem.setRightBarButton(ticklistButton, animated: false)
    }
    
    func handleBarItemRemove(){
        tabBarController?.navigationItem.setRightBarButton(nil, animated: false)
    }
    
    func getLists () {
        //create a fetch request, telling it about the entity

        fetchRequest = List.fetchRequest()

        let idDesc: NSSortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        
        fetchRequest?.sortDescriptors = [idDesc]
        resultsRecord = NSFetchedResultsController(fetchRequest: fetchRequest!, managedObjectContext: context!, sectionNameKeyPath: "id", cacheName: nil)
        
        do {
            try resultsRecord?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
    }
    
    func createTicklist(){
        let alertVC = UIAlertController(title: "Enter Ticklist Name", message: nil, preferredStyle: .alert)
        
        alertVC.addTextField(configurationHandler: {(textField: UITextField) -> Void in
            textField.placeholder = "TICKLIST"
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControlEvents.editingChanged)
        })
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction) -> Void in
            let name = alertVC.textFields?[0].text
            
            let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
            let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "id", ascending: false)
            fetchRequest.sortDescriptors = [idDescriptor] // Note this is a array, you can put multiple sort conditions if you want
            
            do {
                //go get the results
                let searchResults = try self.context?.fetch(fetchRequest)

                
                
                //print(searchResults)
                
                var newID : Int?
                
                if (searchResults?.count)! >= 1 {
                    newID = (searchResults?[0].value(forKey: "id") as! Int) + 1
                } else {
                    newID = 1
                }
 
            
            
                //I like to check the size of the returned results!
                print ("num of results = \(searchResults?.count)")
                print("id: \(newID!)")
                
                let entity = NSEntityDescription.entity(forEntityName: "Ticklist",in: self.context!)!
                let ticklist = List(entity: entity, insertInto: self.context)
                ticklist.id = Int32(newID!)
                ticklist.name = name
                //ticklist.location = 1
            
                try! self.context?.save()
                self.getLists()
                self.tableView.reloadData()
                
            } catch {
                print("Error with request: \(error)")
            }


        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {(action: UIAlertAction) -> Void in
            // do nothing
        })
        
        okAction.isEnabled = false
        
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func alertTextFieldDidChange(field: UITextField){
        let alertController:UIAlertController = self.presentedViewController as! UIAlertController;
        let textField :UITextField  = alertController.textFields![0];
        let addAction: UIAlertAction = alertController.actions[0];
        addAction.isEnabled = (textField.text?.characters.count)! >= 1;
    }
    
    var listVC: ListController?
    


}

extension ListManagerController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let ticklist = resulter?[indexPath.row]
        guard let object = self.resultsRecord?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        let selectTicklist = object as! List
        
        print(selectTicklist)
        
        
        //let listVC = ListController()
        listVC?.problems = selectTicklist.toProblem
        listVC?.probController = probController
        listVC?.ticklist = selectTicklist
        self.navigationController?.pushViewController(listVC!, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = resultsRecord {
            return frc.sections!.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.resultsRecord?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let object = self.resultsRecord?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        let cellIdentifier = "listManagerReuse"
        let selectTicklist = object as! List
		
		print(selectTicklist)
        
        
        //var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as UITableViewCell
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: cellIdentifier)
        
        
        /*if cell == nil {
         cell = UITableViewCell(style: UITableViewCellStyle.value2, reuseIdentifier: cellIdentifier)
         }*/
        

        
        cell.textLabel?.text = selectTicklist.value(forKey: "name") as? String
        //cell.detailTextLabel?.text = String(describing: selectTicklist.value(forKey: "id") as? Int)
        cell.detailTextLabel?.text = "count: \((selectTicklist.toProblem?.count)!)"
        return cell
        
    }
}
