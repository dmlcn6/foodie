//
//  SpoonApi.swift
//  foodieApp
//
//  Created by Mr. Lopez on 2/27/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

import UIKit
import Foundation


class SpoonApi: NSObject {
    //shared instance: Singleton\\
    static let sharedInstance = SpoonApi()
    
    let baseURL = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/"
    
    var recipeCache = [String:Any]()
    var httpReturnValue = HTTPURLResponse()
    var jsonResponse = Data()
    
    func populateExplorePage() -> HTTPURLResponse{
        //add params for query\\
        //paramName=param&paramName=param
        
        /*
          diet - pescetarian, lacto vegetarian, ovo vegetarian, vegan, and vegetarian
          excludeIngredients - comma-separated list of ingredients
          instructionsRequired - BOOL: Whether the recipes must have instructions.
          intolerances - comma-separated list of intolerances. %2C+ == comma and space after comma
          limitLicense - should have an open license that allows for displaying with proper attribution.
          number - number of results to return  (between 0 and 100).
          offset - number of results to skip  (between 0 and 900).
          query - (natural language) recipe search
          type - main course, side dish, dessert, appetizer, salad, bread, breakfast, soup, beverage, sauce, or drink
        */
        
        let recipeURI = "recipes/search?"
        
        let params = "diet=vegetarian&excludeIngredients=coconut&instructionsRequired=true&intolerances=egg%2C+gluten&limitLicense=false&number=10&offset=0&query=burger&type=main+course"
        
        let fullURLstring:String = "\(baseURL)\(recipeURI)\(params)"
        
        var urlRequest = URLRequest(url: URL(string:fullURLstring)! as URL)
        urlRequest.httpMethod = "GET"
        urlRequest.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData

        let headers = [
            "cache-control": "no-cache",
            "accept": "application/json",
            "content-type": "application/json",
            "x-mashape-key": "0NXqyVUB4cmsh4im2YPEAGkKz59Bp1nEIIcjsnXKjfCE4bbHBq"
        ]
        
        urlRequest.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: urlRequest as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print("ERROR IN GET \(error!)")
            } else {
                if let httpResponse = response as? HTTPURLResponse,
                    let responseDesc = response?.description ,
                    let jsonResponse = data{
                    
                    self.httpReturnValue = httpResponse
                    print(("\n\nRESPONSE:: \(responseDesc)\n\n") as String)
                    print("\n\nBODY: COUNT: \(jsonResponse.count))\n\n")
                    let dataString:String = String(data: jsonResponse, encoding: String.Encoding.utf8)!
                    print("\n\nBODY: DATA: \(dataString))\n\n")
                    
                }
            }
        })
        
        dataTask.resume()
        
        return httpReturnValue
        
    }
    
}
