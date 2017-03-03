//
//  Recipe.swift
//  foodieApp
//
//  Created by Mr. Lopez on 3/1/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

import Foundation
import UIKit

class Recipe: NSObject{
    
    // MARK: - Class Members
    var recipeName:String
    var recipeImage:UIImage
    var recipeId:Int
    
    var instructions:[String] = [String]()
    
    
    
    // MARK: - Init
    init(name:String, image:UIImage, id:Int){
        recipeName = name
        recipeImage = image
        recipeId = id
    }

    
}
