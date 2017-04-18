//
//  Recipe.swift
//  foodieApp
//
//  Created by Mr. Lopez on 3/1/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

import Foundation
import UIKit

class FoodieRecipe: NSObject{
    
    // MARK: - Class Members
    var recipeName:String
    var recipeId:Double
    var recipeImage:UIImage?
    var recipeTime: Double
    var recipeServings: Double
    var foodHour: Int?
    
    
    
    var instructions:[String] = [String]()
    var ingredients:[String] = [String]()
    
    
    
    // MARK: - Init
    init(name:String, id:Double, image:UIImage, time:Double, servings:Double){
        recipeName = name
        recipeImage = image
        recipeId = id
        recipeTime = time
        recipeServings = servings
    }

    
}
