//
//  LibraryCell.swift
//  Guidebook
//
//  Created by Steven Ha on 9/2/17.
//  Copyright © 2017 Steven Ha. All rights reserved.
//

import UIKit

class LibraryCell: UITableViewCell {



    var nameLabel: UILabel?
    var downloadLabel: UILabel?
    
    var bookID: Int?
    
    let margin: CGFloat = 10.0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let titleFrame = CGRect(x: margin, y: margin, width: (contentView.frame.width - (2.0 * margin)), height: 20.0)
        
        nameLabel = UILabel(frame: titleFrame)
        
        let downloadFrame = CGRect(x: margin, y: (4.0 * margin), width: (contentView.frame.width - (2.0 * margin)), height: 20.0)
        
        downloadLabel = UILabel(frame: downloadFrame)
        
        contentView.addSubview(nameLabel!)
        contentView.addSubview(downloadLabel!)

    }

}
