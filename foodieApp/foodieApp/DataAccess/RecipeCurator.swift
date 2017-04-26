//
//  RecipeCurator.swift
//  foodieApp
//
//  Created by Mr. Lopez on 4/19/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

import UIKit
import Foundation

class RecipeCurator: NSObject {
    
    enum TypeOfList: String{
        case Breakfast
        case Lunch
        case Dinner
    }
    
    var breakfast = {[
    
    CuratedList.init(name: "Smoothies for Sunrises!", image: UIImage(named: "smoothiesforsunrises.jpg")!, query: "?instructionsRequired=true&number=15&offset=0&query=smoothie&type=drink"),
    CuratedList.init(name: "In a Rush? Need a quick Bkfast?", image:  UIImage(named: "quickbreakfast.jpeg")!, query: "?excludeIngredients=smoothie&instructionsRequired=true&number=10&offset=0&query=quick&type=breakfast"),
    CuratedList.init(name: "Sunday Mornin' Breaksfasts", image:  UIImage(named: "sundaymorningbreakfasts.jpg")!, query: "?excludeIngredients=smoothie&instructionsRequired=true&number=10&offset=0&query=&type=breakfast")
    
    ]}()
    
    var lunch = {[
        
    CuratedList.init(name: "Skip the Fast Food Run! Try these Healthy Vegan Lunches", image:  UIImage(named: "healthyveganlunches.jpg")!, query: "?diet=vegan&excludeIngredients=smoothie&instructionsRequired=true&number=10&offset=0&query=&type=side+dish"),
    CuratedList.init(name: "Quick & Delicious Salads for Lunch!", image:  UIImage(named: "saladsforlunch.jpeg")!, query: ""),
    CuratedList.init(name: "Hungry at home? Grab and Go Snacks.", image:  UIImage(named: "grabandgosnacks.jpg")!, query: "")
        
    ]}()
    
    var dinner = {[
        
    CuratedList.init(name: "Main Courses of the Week", image:  UIImage(named: "maincoursesoftheweekjpeg.jpeg")!, query: ""),
    CuratedList.init(name: "Recovery Smoothies", image:  UIImage(named: "recoverysmoothies.jpg")!, query: ""),
    CuratedList.init(name: "30 Mouth Watering Vegan Dinners", image:  UIImage(named: "mouthwateringvegandinners.jpeg")!, query: "")
        
    ]}()
    
    func curateList(type: TypeOfList) -> [CuratedList] {
        
        switch type {
        case .Breakfast:
            return breakfast
        case .Lunch:
            return lunch
        case .Dinner:
            return dinner
        }
    }
}
