//
//  StoreCell.swift
//  Guidebook
//
//  Created by Steven Ha on 9/2/17.
//  Copyright © 2017 Steven Ha. All rights reserved.
//

import UIKit

class StoreCell: UITableViewCell {
    var id: Int?
    var imageTitle: String?
    var nameLabel: UILabel?
    var name: String?
    var state: String?
    var type: String?
    var isDownloaded: Bool?
    
    let margin: CGFloat = 10.0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let titleFrame = CGRect(x: margin, y: margin, width: (contentView.frame.width - (2.0 * margin)), height: 20.0)
        
        nameLabel = UILabel(frame: titleFrame)
        
        contentView.addSubview(nameLabel!)
    }

}
