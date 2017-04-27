//
//  CuratedList.swift
//  foodieApp
//
//  Created by Mr. Lopez on 4/19/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

import UIKit

class CuratedList: NSObject{
    
    // MARK: - Class Members
    var listName:String
    var listImage:UIImage?
    var curationQuery: String
    
    // MARK: - Init
    init(name:String, image:UIImage, query:String){
        listName = name
        listImage = image
        curationQuery = query
    }
    
    
}
