//
//  SpoonApi.swift
//  foodieApp
//
//  Created by Mr. Lopez on 2/27/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

// The getExplorePageData method makes the POST and then gets a response that is a Data object.
// The Data object is likely going to be JSON sent as a response from the server
// that needs to be parsed (this example does not parse it).

// In getExplorePageData:
// toURLString - is the URL to which the POST is to be made.  It can contain GET variables.
// dataString - is an & separated set of key/value pairs that are the POST data.
// completionHandler - is the closure to be called after the POST is made and the response is 
//                     received.
//                   - the parameters on the completionHandler are a Data optional and a String 
//                     optional that contains an error message
//                     if not nil.  If String optional is not nil an error occurred.

// To do a POST the httpMethod on the URLRequest object must be set to "POST".
// The the httpBody on the URLRequest object is set to the data which in this case
// is based on key/value pairs in a String.  The dataString is converted to a UTF8 encoded
// Data object before it is set as the httpBody on the URLRequest object.

// When a response is received or an error occurs the completionHandler is invoked.
// Because the request happens on a thread different than the main/UI thread
// DispatchQueue.main.sync is used to invoke the completionHandler on the main thread.
// The UI (say, a method or closure in a View Controller) should never be called directly
// from another thread than the main thread.

import UIKit
import Foundation

class SpoonApi: NSObject {
    // MARK: - Class Members
    let baseURL = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/"
    let recipeURI = "recipes/search?"
    
    
    var recipesArray = [Recipe]()
    var httpReturnValue = HTTPURLResponse()
    var jsonResponse = Data()
    
    // MARK: - ViewController
    func getInstructionData(recipeId: Int, completionHandler: @escaping (Data?, String?) -> Void) {
        
        let instructionsURI = "recipes/\(recipeId)/analyzedInstructions?stepBreakdown=true"
        
        let fullURLstring:String = "\(baseURL)\(instructionsURI)"
        
        // Session Configuration \\
        let config = URLSessionConfiguration.default
        
        // Load configuration into Session \\
        let session = URLSession(configuration: config)
        
        // Make sure url is valid \\
        let url = URL(string: fullURLstring)
        
        var urlRequest = URLRequest(url: url!)
        
        urlRequest.httpMethod = "GET"
        
        // Request Headers for GET \\
        let headers = [
            "cache-control": "no-cache",
            "accept": "application/json",
            "content-type": "application/json",
            "x-mashape-key": getAuthKey()
        ]
        
        urlRequest.allHTTPHeaderFields = headers
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            if error != nil {
                DispatchQueue.main.sync(execute: {
                    completionHandler(nil, error!.localizedDescription)
                })
            } else {
                DispatchQueue.main.sync(execute: {
                    completionHandler(data, nil)
                })
                
            }
        }
        
        task.resume()
    }
    
    func getExplorePageData(urlParams:String, completionHandler: @escaping (Data?, String?) -> Void) {
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
        
        //paramName=param&paramName=param
        let params = "diet=vegetarian&excludeIngredients=coconut&instructionsRequired=true&intolerances=egg%2C+gluten&limitLicense=false&number=10&offset=0&query=burger&type=main+course"
        
        let fullURLstring:String = "\(baseURL)\(recipeURI)\(params)"
        
        // Session Configuration \\
        let config = URLSessionConfiguration.default
        
        // Load configuration into Session \\
        let session = URLSession(configuration: config)
        
        // Make sure url is valid \\
        let url = URL(string: fullURLstring)
        
        var urlRequest = URLRequest(url: url!)
        
        urlRequest.httpMethod = "GET"
        
        
        
        // Request Headers for GET \\
        let headers = [
            "cache-control": "no-cache",
            "accept": "application/json",
            "content-type": "application/json",
            "x-mashape-key": getAuthKey()
        ]
        
        urlRequest.allHTTPHeaderFields = headers
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            if error != nil {
                DispatchQueue.main.sync(execute: {
                    completionHandler(nil, error!.localizedDescription)
                })
            } else {
                DispatchQueue.main.sync(execute: {
                    completionHandler(data, nil)
                })
                
            }
            
        }
        
        task.resume()
    }
    
    func parseJson(data: Data){
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]{
            
            /*
             if let results = root["results"] as? [String:Any] {
             print("PARSEJSON \(results)\n\n\n")
             }
             */
            
            //var resultsArray = json["results"] as? [String:Any]
            
            for (key, value) in json{
                print("KEY::\(key) \n\n RESULTS::\(value)\n\n\n")
                if (key == "results"){
                    if let resultsArray = value as? [[String:Any]] {
                        print("\n\nRESULTSARRAY\(resultsArray)\n\n")
                        
                        
                        for result in resultsArray {
                            print("\n\nRESULTSPART\(result)\n\n")
                            
                            if let recipeTitle = result["title"] as? String,
                                let recipeId = result["id"] as? Int {
                                    
                                
                                
                                let newRecipe:Recipe = Recipe(name: recipeTitle, id: recipeId, image: UIImage())
                                recipesArray.append(newRecipe)
                            }
                        }
                    }
                }
            }
        }
    } //end of parseJson
    
    func getAuthKey() -> String {
        var keys: NSDictionary?
        
        
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
            
            if let dict = keys {
                if let apiKey = dict["apiKey"] as? String{
                    return apiKey
                }
            }
        }
        
        return ""
    }
}
