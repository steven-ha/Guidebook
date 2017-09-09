//
//  TabController.swift
//  ApproachApp
//
//  Created by Steven Ha on 7/23/17.
//  Copyright © 2017 tenshave. All rights reserved.
//

import UIKit
import CoreData

class TabController: UITabBarController, UITabBarControllerDelegate{
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    var context: NSManagedObjectContext?
    
    let map = MapController()
    let guide = GuideController()
    let listManager = ListManagerController()
    
    var tabViewControllers: [UIViewController]?
    
    let titles = ["MAP", "GUIDE", "LISTS"]
    
    lazy var setting: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(showSetting))
        return button
    }()
    
    lazy var displayGuide: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(showGuide))
        return button
    }()
    
    lazy var displayListManager: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(showListManager))
        return button
    }()

    lazy var problemContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.purple
        return view
    }()
    
    let testView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.orange
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var mainController: MainNavigationController?
	var probController: ProbController = ProbController()
    var listController: ListController = ListController()
    var showMap: Bool = false
    var selectedProblem: Problem?
    var guideID: Int?
        
    override func viewDidLoad() {
        
		super.viewDidLoad()
		context = getContext()
        //problemdb.populateDatabase(fileName: "lincoln_lake")
        
        tabViewControllers = [map, guide, listManager]
		
		for (index,viewController) in (tabViewControllers?.enumerated())!{
            viewController.edgesForExtendedLayout = []
            viewController.tabBarItem.title = titles[index]
		}
        
        setupTabBarButtons()
        

        self.viewControllers = tabViewControllers
		
		map.probController = probController
        map.context = context
        
        guide.probController = probController
        guide.context = context
        
        listManager.probController = probController
        listManager.context = context
        listManager.listVC = listController
        
        listController.context = context
        
        
        probController.delegate = self
        self.delegate = self
		
        
	}
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        map.bookID = guideID
        
        print("tab bar back")
        
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController){
        print("SELECTED ANOTHER TAB")
    }
    
    
    
    func setupTabBarButtons(){
        self.navigationItem.leftBarButtonItem = setting
    }
    
    func showSetting(){
        let setting = SettingController()
        setting.mainController = mainController
        setting.tabController = self
        setting.context = self.context
        
        
        
        //let nav = UINavigationController(rootViewController: setting)
        //present(nav, animated: true, completion: nil)
        self.navigationController?.pushViewController(setting, animated: true)
    }
    
    func showGuide(){
        setupTabBarButtons()
        self.tabBar.isHidden = false
        self.selectedIndex = 1
        self.navigationController?.pushViewController(probController, animated: true)
    }
    
    func showListManager(){
        setupTabBarButtons()
        self.tabBar.isHidden = false
        self.selectedIndex = 2
        self.navigationController?.pushViewController(listController, animated: false)
        //self.navigationController?.pushViewController(probController, animated: true)
    }
    
    
}

extension TabController: ProbControllerDelegate{
    func displayMap(change: Bool) {
        //self.tabBar.isHidden = true
        self.selectedIndex = 0
    }
    
    func updateCenter(latitude: Double, longitude: Double) {
        self.map.latitude = latitude
        self.map.longitude = longitude
    }
    
    func storeGuideProblem(store: Bool) {
        //self.navigationItem.leftBarButtonItem = displayGuide
        print("from guide")
    }
    
    func storeList(store: Bool){
        //self.navigationItem.leftBarButtonItem = displayListManager
        print("from list")
    }
    
    func animatedMarker(object: NSFetchRequestResult) {
        //let index = self.map.resultsRecord?.indexPath(forObject: object)
        
        let id = (object as! Problem).value(forKey: "id") as! Int
        
        
        if let index = self.map.problemDictionary[id] {
            //self.map.mapView.selectAnnotation(self.map.annotationManager[index], animated: true)
            self.map.annotationID = index

        } else {
            print("dictionary messed up")
        }

    }
}

extension TabController: LibraryControllerDelegate{
    
    
    func setGuidebookID(id: Int) {
        print("in the tab. the id was set my man")
        print("guide id was \(guideID)")
        
        self.guideID = id
        
        print("guide id is \(guideID)")
    }
}

