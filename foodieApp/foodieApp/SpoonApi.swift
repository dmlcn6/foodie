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
    
    // Session Configuration \\
    let config = URLSessionConfiguration.default
    
    var recipesArray = [Recipe]()
    var httpReturnValue = HTTPURLResponse()
    var jsonResponse = Data()
    
    
    // MARK: - Global URL Config
    func configureURLRequest(httpUrl: String, httpAction: String, httpHeaders: [String:String]) -> URLRequest? {
        let url = URL(string: "")
        
        // Make sure url is valid \\
        if let url = URL(string: httpUrl) {
            var urlRequest = URLRequest(url: url)
            
            urlRequest.httpMethod = httpAction
            
            urlRequest.allHTTPHeaderFields = httpHeaders
            
            return urlRequest
        }else{
            return nil
        }
    }
    
    // MARK: - API Requests
    func getAdvancedRecipeData(recipeId: Double, completionHandler: @escaping (Data?, String?) -> Void) {
        
        //paramName=param&paramName=param
        let params = "includeNutrition=false"
        
        let informationURI = "recipes/\(Int(recipeId))/information?"
        
        let fullURLstring:String = "\(baseURL)\(informationURI)\(params)"
        
        // Request Headers for GET \\
        let headers = [
            "cache-control": "no-cache",
            "accept": "application/json",
            "content-type": "application/json",
            "x-mashape-key": getAuthKey()
        ]
        
        if let urlRequest = configureURLRequest(httpUrl: fullURLstring, httpAction: "GET", httpHeaders: headers) {
        
            // Load configuration into Session \\
            let session = URLSession(configuration: config)
            
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
        }else {
            let alert = UIAlertController(title: "Error", message: "We're so sorry, something went wrong.", preferredStyle: .alert)
            
            // set the confirm action
            let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            // add confirm button to alert
            alert.addAction(confirmAction)
            
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //gonna try this w a sephamore
    func getHomePageData(timeOfDay: String){
        
    }
    
    func getExplorePageData(queryString: String, completionHandler: @escaping (Data?, String?) -> Void) {
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
        
        //base recipe URL
        let recipeURI = "recipes/search?"
        
        //paramName=param&paramName=param
        //let params = "diet=vegetarian&excludeIngredients=coconut&instructionsRequired=true&intolerances=egg%2C+gluten&limitLicense=false&number=1&offset=0&query=burger&type=main+course"
        
        let fullURLstring:String = "\(baseURL)\(recipeURI)\(queryString)"
        
        // Request Headers for GET \\
        let headers = [
            "cache-control": "no-cache",
            "accept": "application/json",
            "content-type": "application/json",
            "x-mashape-key": getAuthKey()
        ]
        
        let urlRequest = configureURLRequest(httpUrl: fullURLstring, httpAction: "GET", httpHeaders: headers)
        
        // Load configuration into Session \\
        let session = URLSession(configuration: config)
        
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
    
    func getMealPlanData(queryString: String, completionHandler: @escaping(Data?, String?) -> Void){
    
        //base recipe URL
        let mealPlanURI = "recipes/mealplans/generate?"
        
        //paramName=param&paramName=param
        //let params = "diet=vegetarian&excludeIngredients=coconut&targetCalories=2000&timeFrame=week"
        
        let fullURLstring:String = "\(baseURL)\(mealPlanURI)\(queryString)"
        
        // Request Headers for GET \\
        let headers = [
            "cache-control": "no-cache",
            "accept": "application/json",
            "content-type": "application/json",
            "x-mashape-key": getAuthKey()
        ]
        
        let urlRequest = configureURLRequest(httpUrl: fullURLstring, httpAction: "GET", httpHeaders: headers)
        
        // Load configuration into Session \\
        let session = URLSession(configuration: config)
        
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
    
    // MARK: - Auth Key
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
