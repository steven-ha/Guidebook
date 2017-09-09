//
//  StoreController.swift
//  ApproachApp
//
//  Created by Steven Ha on 8/17/17.
//  Copyright © 2017 tenshave. All rights reserved.
//

import UIKit
import CoreData

struct guidebook {
    var id: Int
    var name: String
    var image: String
    var state: String
    var type: String
    var downloaded: Bool
    
    init(id: Int, name: String, image: String, state: String, type: String, downloaded: Bool){
        self.id = id
        self.name = name
        self.image = image
        self.state = state
        self.type = type
        self.downloaded = downloaded
    }
    
}

class StoreController: UITableViewController {
    
    var books: [guidebook] = []
    var context: NSManagedObjectContext?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.darkGray
        
        let book1 = guidebook(id: 1, name: "lincoln_lake", image: "cover_lincoln_lake", state: "Colorado", type: "boulder", downloaded: false)
        let book2 = guidebook(id: 2, name: "eldorado_canyon", image: "cover_eldorado_canyon", state: "Colorado", type: "boulder", downloaded: false)

        books.append(book1)
        
        books.append(book2)
        
        tableView.register(StoreCell.self, forCellReuseIdentifier: "book")

        

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "book", for: indexPath) as! StoreCell
        let book = books[indexPath.row] as! guidebook
        cell.nameLabel?.text = book.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! StoreCell
        
        print((cell.nameLabel?.text)!)
        
        cell.isSelected = false
        
        confirmPurchase(book: books[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    
    
    func confirmPurchase(book: guidebook){
        let alert = UIAlertController(title: "Purchase", message: "Purchase this book?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in self.purchaseBook(book: book)})
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: {(alert: UIAlertAction!) in print("Cancel")})
        
        
        alert.addAction(ok)
        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
    }
    
    func purchaseBook(book: guidebook){
        
        if let bookContext = context {
            let entity = NSEntityDescription.entity(forEntityName: "Guidebook",in: bookContext)!
            let purchaseBook = Guidebook(entity: entity, insertInto: bookContext)
            
            purchaseBook.id = Int32(book.id)
            purchaseBook.image = book.image
            purchaseBook.name = book.name
            purchaseBook.state = book.state
            purchaseBook.type = book.type
            purchaseBook.downloaded = book.downloaded
            
            try! bookContext.save()
            
            print("'\(book.name)' purchased.")
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
