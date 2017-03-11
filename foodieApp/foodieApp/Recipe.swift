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
    var recipeId:Int
    var recipeImage:UIImage?
    var recipeTime: Int
    
    
    
    var instructions:[String] = [String]()
    
    
    
    // MARK: - Init
    init(name:String, id:Int, image:UIImage, time:Int){
        recipeName = name
        recipeImage = image
        recipeId = id
        recipeTime = time
    }

    
}
