//
//  ProblemTableViewCell.swift
//  ApproachApp
//
//  Created by Steven Ha on 7/27/17.
//  Copyright © 2017 tenshave. All rights reserved.
//

import UIKit
import CoreData

class ProblemCell: UITableViewCell{
    var problemImage: UIImageView!
    var name: UILabel!
    var grade: UILabel!
    var rating: Double!
    let margin: CGFloat = 8.0
    var imageName: String?
    var problemID: Int?
    var problem: Problem!
    var object: NSFetchRequestResult?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let imageDimension = contentView.bounds.size.width * 0.25

        let problemImageFrame = CGRect(x: margin, y: margin, width: imageDimension, height: imageDimension)
        problemImage = UIImageView.init(frame: problemImageFrame)
        

        
        contentView.addSubview(problemImage)
        
        let nameFrame = CGRect(x: (margin + imageDimension + 8), y: margin, width: 180.0, height: 24.0)
        name = UILabel(frame: nameFrame)
        name.numberOfLines = 1
        name.minimumScaleFactor = 0.25
        name.adjustsFontSizeToFitWidth = true
        name.font = UIFont(name: "Arial", size: 20.0)
        contentView.addSubview(name)
        
        let gradeFrame = CGRect(x: (margin + imageDimension + 8), y: (24.0 + margin), width: contentView.bounds.size.width, height: 20.0)
        grade = UILabel(frame: gradeFrame)
        grade.font = UIFont(name: "Arial", size: 16.0)
        contentView.addSubview(grade)
    }
}
