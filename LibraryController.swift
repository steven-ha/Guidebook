//
//  LibraryController.swift
//  ApproachApp
//
//  Created by Steven Ha on 8/17/17.
//  Copyright © 2017 tenshave. All rights reserved.
//

import UIKit
import Mapbox
import CoreData

@objc protocol LibraryControllerDelegate {
    @objc optional func setGuidebookID(id: Int)
}

struct ProblemStruct{
    
    var id: Int
    var name: String
    var index_font: Int
    var index_hueco: Int
    var latitude: Double
    var longitude: Double
    var area: String
    var beta_long: String
    var beta_short: String
    var boulder: String
    var font: String
    var hueco: String
    var image: String
    var panorama: String
    var region: String
    
    init(id: Int, name: String, index_font: Int, index_hueco: Int, latitude: Double, longitude: Double, area: String, beta_long: String, beta_short: String, boulder: String, font: String, hueco: String, image: String, panorama: String, region: String){
        self.id = id
        self.name = name
        self.index_font = index_font
        self.index_hueco = index_hueco
        self.latitude = latitude
        self.longitude = longitude
        self.area = area
        self.beta_long = beta_long
        self.beta_short = beta_short
        self.boulder = boulder
        self.font = font
        self.hueco = hueco
        self.image = image
        self.panorama = panorama
        self.region = region
    }
}

struct MapStruct{
    var id: Int
    var latitude: Double
    var longitude: Double
    var northwest: Double
    var southeast: Double
    var terrain: String
    var satellite: String
    
    init(id: Int, latitude: Double, longitude: Double, northwest: Double, southeast: Double, terrain: String, satellite: String){
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.northwest = northwest
        self.southeast = southeast
        self.terrain = terrain
        self.satellite = satellite
    }
}

class LibraryController: UITableViewController{
    var fetchRequest: NSFetchRequest<NSFetchRequestResult>?
    var resultsRecord: NSFetchedResultsController<NSFetchRequestResult>?
    var sectIndexTitles: [String] = []
    
    var context: NSManagedObjectContext?
    
    var maps: [MapStruct] = []
    var problemArr: [[ProblemStruct]] = []
    
    var tabVC: TabController?
    
    var delegate: LibraryControllerDelegate?
    
    var loadedBookID: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(LibraryCell.self, forCellReuseIdentifier: "books")
        
        createLincoln()
        createEldoCanyon()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        retrieveGuidebooks()
    }
    
    func createLincoln(){
        let map = MapStruct(id: 1, latitude: 111.0, longitude: 111.0, northwest: 111.0, southeast: 111.0, terrain: "terrain", satellite: "terrain")
        maps.append(map)
        
        var problems: [ProblemStruct] = []
        problems.append(ProblemStruct(id: 7, name: "Red Herring", index_font: 11, index_hueco: 7, latitude: 39.6186119, longitude: -105.60301, area: "Lincoln Lake", beta_long: "Start low, climb up and left", beta_short: "Sit start matched, left heel hook", boulder: "Red Herring", font: "7A+", hueco: "V7", image: "red_herring_7", panorama: "p_red_herring_7", region: "Lincoln Lake"))
        problemArr.append(problems)
    }
    
    func createEldoCanyon(){
        let map = MapStruct(id: 2, latitude: 111.0, longitude: 111.0, northwest: 111.0, southeast: 111.0, terrain: "terrain", satellite: "terrain")
        maps.append(map)
        
        var problems: [ProblemStruct] = []
        problems.append(ProblemStruct(id: 1, name: "Resonated", index_font: 12, index_hueco: 8, latitude: 39.931066, longitude: -105.291034, area: "Eldorado Canyon", beta_long: "Start low, climb up and right", beta_short: "Stand start on crimps.", boulder: "Resonated", font: "7B+", hueco: "V8", image: "resonated_1", panorama: "resonated_1", region: "Eldorado Canyon"))
        problemArr.append(problems)
    }
    

    
    func handleGuideBook(indexPath: IndexPath){
        print("id was: \(indexPath.row)")
    }
    
    func setupFetchRequest(sortDescriptors: [NSSortDescriptor], sectionNameKeyPath: String){
        if let libraryContext = context {
            fetchRequest = Guidebook.fetchRequest()
            fetchRequest?.sortDescriptors = sortDescriptors
            resultsRecord = NSFetchedResultsController(fetchRequest: fetchRequest!, managedObjectContext: libraryContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        }
    }
    
    func retrieveGuidebooks () {
        let stateDesc: NSSortDescriptor = NSSortDescriptor(key: "state", ascending: true)
        let nameDesc: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        setupFetchRequest(sortDescriptors: [stateDesc, nameDesc], sectionNameKeyPath: "state")
        
        do {
            try resultsRecord?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
    }
    
    func downloadGuidebook(id: Int){
        downloadMap(id: id)
        downloadProblems(id: id)
        updateData(id: (id + 1))
    }
    
    func getGuidebook(id: Int) -> NSManagedObject?{
        fetchRequest = Guidebook.fetchRequest()
        fetchRequest?.sortDescriptors = []
        fetchRequest?.predicate = NSPredicate(format: "id == %@", "\(id + 1)")
        
        resultsRecord = NSFetchedResultsController(fetchRequest: fetchRequest!, managedObjectContext: context!, sectionNameKeyPath: "name", cacheName: nil)
        
        do {
            try resultsRecord?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        if resultsRecord?.fetchedObjects?.count != 0 {
            let guide = resultsRecord?.fetchedObjects?[0] as! NSManagedObject
            resultsRecord = nil
            return guide
        } else {
            resultsRecord = nil
            print("something wrong")
            return nil
        }
    }
    
    func downloadMap(id: Int){
        let guide = getGuidebook(id: id)
        if let mapContext = context {
            let entity = NSEntityDescription.entity(forEntityName: "Map",in: mapContext)!
            let map = Map(entity: entity, insertInto: mapContext)
            
            let mapData = maps[id]
            
            map.id = Int32(mapData.id)
            map.latitude = mapData.latitude
            map.longitude = mapData.longitude
            map.northwest = mapData.northwest
            map.southeast = mapData.southeast
            map.terrain = mapData.terrain
            map.satellite = mapData.satellite
            
            // create the relationship between the guidbook and problem
            if let guidebook = guide {
                let setMap = guidebook.mutableSetValue(forKey: "toMap")
                setMap.add(map)
            }
            
            try! mapContext.save()
        }
    }
    
    func updateData(id: Int){
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Guidebook")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(id)")

        var results: [NSManagedObject] = []
        
        if let libraryContext = context {
            do {
                results = try libraryContext.fetch(fetchRequest)
            } catch {
                fatalError("Failed to fetch entities: \(error)")
            }
            
            results[0].setValue(true, forKey: "downloaded")
            print(results)
        }
    }
    
    func downloadProblems(id: Int){
        if let problemContext = context {
            let entity = NSEntityDescription.entity(forEntityName: "Problem",in: problemContext)!
            
            print("id is \(id)")
            let problems = problemArr[id]
            
            let guide = getGuidebook(id: id)
            
            print("guidebook is:")
            
            for prob in problems {
                let problem = Problem(entity: entity, insertInto: problemContext)
                problem.id = Int32(prob.id)
                problem.name = prob.name
                problem.index_font = Int32(prob.index_font)
                problem.index_hueco = Int32(prob.index_hueco)
                problem.latitude = prob.latitude
                problem.longitude = prob.longitude
                problem.area = prob.area
                problem.beta_long = prob.beta_long
                problem.beta_short = prob.beta_short
                problem.boulder = prob.boulder
                problem.font = prob.font
                problem.hueco = prob.hueco
                problem.image = prob.image
                problem.panorama = prob.panorama
                problem.region = prob.region
                
                // create the relationship between the guidbook and problem
                if let guidebook = guide {
                    let setProblem = guidebook.mutableSetValue(forKey: "toProblem")
                    setProblem.add(problem)
                }
                
                try! problemContext.save()
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let cell = tableView.cellForRow(at: indexPath) as! LibraryCell
        
        let id = cell.bookID
        
        let checkout = UITableViewRowAction(style: .normal, title: "CHECKOUT", handler: {(rowAction, indexPath) in
            print("Book checked out.")
            self.delegate?.setGuidebookID!(id: id!)
            self.loadedBookID = id
            self.handleGuideBook(indexPath: indexPath)
        })
        
        checkout.backgroundColor = UIColor.init(red: 0.0, green: 0.6, blue: 0.2, alpha: 1.0)
        
        let checkin = UITableViewRowAction(style: .normal, title: "CHECKIN", handler: {(rowAction, indexPath) in
            self.loadedBookID = nil
        })
        
        checkin.backgroundColor = UIColor.init(red: 0.0, green: 0.6, blue: 0.8, alpha: 1.0)

        let download = UITableViewRowAction(style: .normal, title: "DOWNLOAD", handler: {(rowAction, indexPath) in
            print("Book downloaded.")
            self.handleGuideBook(indexPath: indexPath)
        })

        let remove = UITableViewRowAction(style: .normal, title: "REMOVE", handler: {(rowAction, indexPath) in
            print("Book removed.")
           self.handleGuideBook(indexPath: indexPath)
        })
        
        remove.backgroundColor = UIColor.init(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)

        print("check status \(loadedBookID)")
        
        //print("loaded book id is \(loadedBookID!)")
        
        if loadedBookID == id {
            return [remove, checkin]
        } else {
            return [remove, checkout]
        }
        
        //return [remove, checkout]
    }
    
    
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print(indexPath.row)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "books", for: indexPath) as! LibraryCell
        
        guard let object = self.resultsRecord?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        let book = object as! Guidebook
        
        cell.nameLabel?.text = book.name
        
        cell.bookID = Int(book.id)
        if book.downloaded {
            cell.downloadLabel?.text = "Downloaded: YES"
        } else {
            cell.downloadLabel?.text = "Downloaded: NO"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = resultsRecord?.sections?[section] else {
            return nil
        }
        
        return sectionInfo.name
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        /*sectIndexTitles.removeAll()
        
        for section in (resultsRecord?.sections)!{
            sectIndexTitles.append(section.name)
        }
        
        if segmentedControl.selectedSegmentIndex == 0{
            return sectIndexTitles
        }
        else {
            return resultsRecord?.sectionIndexTitles
        }*/
        
        return resultsRecord?.sectionIndexTitles

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sectIndexTitles.index(of: title)!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        downloadGuidebook(id: indexPath.row)
        
        cell?.isSelected = false
        
        tableView.reloadData()
    }
    


    
}
