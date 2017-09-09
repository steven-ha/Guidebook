//
//  MapViewController.swift
//  ApproachApp
//
//  Created by Steven Ha on 7/24/17.
//  Copyright © 2017 tenshave. All rights reserved.
//

import UIKit
import Mapbox
import CoreData


class MapController: UIViewController, MGLMapViewDelegate {
    //var mapView: MGLMapView!
	
	
    lazy var mapView: MGLMapView = {
        
        //let map = MGLMapView(frame: self.view.bounds, styleURL: MGLStyle.satelliteStyleURL())
        let map = MGLMapView(frame: self.view.bounds)
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map.tintColor = .gray
        map.delegate = self
        return map
    }()
    
    lazy var segmentedController: UISegmentedControl = {
        let items = ["Terrain", "Satellite"]
        let sc = UISegmentedControl(items: items)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(handleMapChange), for: .valueChanged)
        sc.backgroundColor = UIColor.white
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    //var mapBounds = MGLCoordinateBounds()
    
    let terrainURL: URL = MGLStyle.outdoorsStyleURL()
    let satelliteURL: URL = MGLStyle.satelliteStyleURL()
        
	var zoom = 17.0
    var latitude: Double?
    var longitude: Double?
    
    var delegate: ProbControllerDelegate?
    var probController: ProbController?
    
    var fetchRequest: NSFetchRequest<NSFetchRequestResult>?
    var resultsRecord: NSFetchedResultsController<NSFetchRequestResult>?
    var annotationID: Int?
    var problemDictionary: [Int: Int] = [:]
    
    var context: NSManagedObjectContext?
    
    var bookID: Int?
    var guide: Guidebook?
    
    func getGuidebook(){
        if let book = bookID {
            fetchRequest = Guidebook.fetchRequest()
            
            fetchRequest?.sortDescriptors = []
            
            fetchRequest?.predicate = NSPredicate(format: "id == %@", "\(bookID)")
            
            resultsRecord = NSFetchedResultsController(fetchRequest: fetchRequest!, managedObjectContext: context!, sectionNameKeyPath: "name", cacheName: nil)
            
            do {
                try resultsRecord?.performFetch()
            } catch {
                fatalError("Failed to fetch entities: \(error)")
            }
            
        }
        
        
        if resultsRecord?.fetchedObjects?.count == 1 {
            guide = resultsRecord?.fetchedObjects?[0] as! Guidebook
            resultsRecord = nil
        } else {
            print("something wrong")
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.addSubview(mapView)
        self.view.addSubview(segmentedController)

        
        self.latitude = 39.617230
        self.longitude = -105.599142
        
        //bookID = 1
       
        mapView.setZoomLevel(zoom, animated: false)
 
        mapView.styleURL = terrainURL
 


        setupConstraint()
        

        addAnnotation()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        

        
        
        if let book = bookID {
                    getGuidebook()
            setMapCenter(zoom: mapView.zoomLevel)
            
            print("view appeared")
            
            if let indexexist = annotationID{
                print("index \(indexexist)")
            }
            
            perform(#selector(selectedAnnotation), with: nil, afterDelay: 0.5)
            
            
            retrieveProblems(sort: 0)
            createAnnotations()
            print(annotationManager)
            selectedAnnotation()
        }
        

    }
    
    func selectedAnnotation(){
        if let index = annotationID {
            
            mapView.selectAnnotation(self.annotationManager[index], animated: true)
        }
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                //selectedAnnotation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let book = bookID {
            self.latitude = self.mapView.centerCoordinate.latitude
            self.longitude = self.mapView.centerCoordinate.longitude
            print("map dissappeared")
        }

    }
    
    
    
    
    
    func handleMapChange(){
        if segmentedController.selectedSegmentIndex == 0 {
            mapView.styleURL = terrainURL
        } else {
            mapView.styleURL = satelliteURL
        }
    }
    
    func setupConstraint(){
        
        segmentedController.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 8.0).isActive = true
        segmentedController.widthAnchor.constraint(equalTo: mapView.widthAnchor, constant: -16.0).isActive = true
        segmentedController.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
	

    
    func setMapCenter(zoom: Double){
        let centerCoordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        mapView.setCenter(centerCoordinate, zoomLevel: mapView.zoomLevel, animated: true)
    }
    
    func saveCenter(){
        
    }
    

    
    var annotationManager: [MGLAnnotation] = []

    
    func setupFetchRequest(sortDescriptors: [NSSortDescriptor], sectionNameKeyPath: String){
        
        fetchRequest = Problem.fetchRequest()
        
        fetchRequest?.sortDescriptors = sortDescriptors
        
        fetchRequest?.predicate = NSPredicate(format: "ANY toGuidebook.id == %@", "\(bookID!)")
        
        resultsRecord = NSFetchedResultsController(fetchRequest: fetchRequest!, managedObjectContext: context!, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
    }
    
    func retrieveProblems (sort: Int) {
        resultsRecord = nil
        let gradeDesc: NSSortDescriptor = NSSortDescriptor(key: "hueco", ascending: true)
        //let alphaDesc: NSSortDescriptor = NSSortDescriptor(key: "alphabet", ascending: true)
        let nameDesc: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        
        setupFetchRequest(sortDescriptors: [gradeDesc, nameDesc], sectionNameKeyPath: "hueco")
        
        do {
            try resultsRecord?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        print(resultsRecord?.fetchedObjects)
    }
    
}

// MGLAnnotation protocol reimplementation
class MapAnnotation: NSObject, MGLAnnotation {
	
	// As a reimplementation of the MGLAnnotation protocol, we have to add mutable coordinate and (sub)title properties ourselves.
	var coordinate: CLLocationCoordinate2D
	var title: String?
	var subtitle: String?
	
	// Custom properties that we will use to customize the annotation.
	var id: Int?

	
	init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
		self.coordinate = coordinate
		self.title = title
		self.subtitle = subtitle
	}
}

extension MapController{
    func addAnnotation() {
        let annotation = MGLPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        annotation.title = "Kinkaku-ji"
        annotation.subtitle = "\(annotation.coordinate.latitude), \(annotation.coordinate.longitude)"
        
        mapView.addAnnotation(annotation)
        
        // Center the map on the annotation.
        mapView.setCenter(annotation.coordinate, zoomLevel: 17, animated: false)
        
        // Pop-up the callout view.
        mapView.selectAnnotation(annotation, animated: true)
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        if (annotation.title! == "Kinkaku-ji") {
            // Callout height is fixed; width expands to fit its content.
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
            label.textAlignment = .right
            label.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
            label.text = "金閣寺"
            
            return label
        }
        
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .detailDisclosure)
    }
    
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {

		if let sanno = annotation as? MapAnnotation {
		

			let problem = self.resultsRecord?.fetchedObjects?[sanno.id!] as! Problem
            
			probController?.problem = problem
            
            self.latitude = self.mapView.centerCoordinate.latitude
            self.longitude = self.mapView.centerCoordinate.longitude
            
			self.navigationController?.pushViewController(probController!, animated: true)
		} else {
			print("something else")
		}
        
    }
    
    
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        if let sanno = annotation as? MapAnnotation {
            // Assign a reuse identifier to be used by both of the annotation views, taking advantage of their similarities.
            let reuseIdentifier = "reusableDotView"
            
            // For better performance, always try to reuse existing annotations.
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            
            // If there’s no reusable annotation view available, initialize a new one.
            if annotationView == nil {
                                annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
                annotationView?.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
                annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
                annotationView?.layer.borderWidth = 2.0
                annotationView?.layer.borderColor = UIColor.white.cgColor
                
                
                let grade = sanno.subtitle!
                
                switch grade {
                case "V0", "V1", "V2", "V3", "V4":
                    annotationView?.layer.backgroundColor = UIColor.green.cgColor
                case "V5", "V6", "V7", "V8", "V9":
                    annotationView?.layer.backgroundColor = UIColor.yellow.cgColor
                case "V10", "V11", "V12", "V13", "V14", "V15":
                    annotationView?.layer.backgroundColor = UIColor.red.cgColor
                default:
                    annotationView?.layer.backgroundColor = UIColor.white.cgColor
                }
                
            }
            
            return annotationView
        }
        
        return nil
        

    }
    
    func createAnnotations(){

        let problems = self.resultsRecord?.fetchedObjects
        
        for (index,problem) in problems!.enumerated() {
            let select = problem as! Problem
            

            
            let coordinate = CLLocationCoordinate2D(latitude: select.value(forKey: "latitude") as! Double, longitude: select.value(forKey: "longitude") as! Double)
            let title = select.value(forKey: "name") as! String
            
            let detail = select.value(forKey: "hueco") as! String
            
            
            
            
            let annotation = MapAnnotation(coordinate: coordinate, title: title, subtitle: detail)

            
            annotation.id = index
            
            let id = select.value(forKey: "id") as! Int

            

            mapView.addAnnotation(annotation)
            annotationManager.append(annotation)
            problemDictionary[id] = index
            
            // Pop-up the callout view.
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
	

}
