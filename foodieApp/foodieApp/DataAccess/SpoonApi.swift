//
//  SpoonApi.swift
//  foodieApp
//
//  Created by Mr. Lopez on 2/27/17.
//  Copyright © 2017 Darryl Lopez. All rights reserved.
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

class SpoonApi: NSObject {
    
    // MARK: - INIT Class Singleton
    
    //set initial values to setup URL tasks
    private override init() {
        //declared a private init so there are no inits
        self.baseURL  = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/"
        self.config = URLSessionConfiguration.default
        self.recipesArray = [Recipe]()
        self.httpReturnValue = HTTPURLResponse()
        self.jsonResponse = Data()
        self.getHeaders = [:]
        self.requestsAvailable = nil
    }
    
    //create singleton for use thru app
    private static var sharedInstance: SpoonApi = {
        //get auth key first time user access shared instance
        
        let sharedSpoon = SpoonApi()
        
        //set headers once for all get reqs
        sharedSpoon.getHeaders = [
            "cache-control": "no-cache",
            "accept": "application/json",
            "content-type": "application/json",
            "x-mashape-key": getAuthKey()
        ]
        
        //get reqs num from server
        //class var is set in func
        getRequestNum()
        
        return sharedSpoon
    }()
    
    // MARK: - Singleton Accessor Func
    class func shared() -> SpoonApi {
        return sharedInstance
    }
    
    
    // MARK: - Class Members
    let baseURL: String
    let config: URLSessionConfiguration
    var getHeaders: [String:String]
    var recipesArray: [Recipe]
    var httpReturnValue: HTTPURLResponse
    var jsonResponse: Data
    var requestsAvailable: Int?
    
    
    
    // MARK: - Global URL Config
    private func configureURLRequest(httpUrl: String, httpAction: String, httpHeaders: [String:String]) -> URLRequest? {
        
        
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
    
    //specific data about a single recipe, based on recipeId
    func getAdvancedRecipeData(recipeId: Double, completionHandler: @escaping (Data?, String?) -> Void) {
        
        //paramName=param&paramName=param
        let params = "includeNutrition=false"
        
        let informationURI = "recipes/\(Int(recipeId))/information?"
        
        let fullURLstring:String = "\(baseURL)\(informationURI)\(params)"
        
        if let urlRequest = configureURLRequest(httpUrl: fullURLstring, httpAction: "GET", httpHeaders: getHeaders) {
        
            // Load configuration into Session \\
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: urlRequest) {
                (data, response, error) in
                if let urlResp = response{
                    print(urlResp)
                    
                    //parse away } and {
                    let respParse = urlResp.description.components(separatedBy: ["{","}"])
                        
                    if(respParse.count > 0){
                        var count = 0
                        
                        //response headers
                        let heads = respParse[4].components(separatedBy: [";","="])
                        
                        for header in heads {
                            
                            if(header.contains("X-RateLimit-requests-Remaining")){
                                print("\n\n🔥Header\(header)🔥\n")
                                
                                let remaining = heads[count+1].components(separatedBy: ["\""," "])
                                if let remainReqs = Int(remaining[1]){
                                    
                                    //get request limit
                                    print("\n\n🔥REMAINING REQS == \(remainReqs)🔥\n\n")
                                    
                                    //store in firebase as new remaing reqs
                                    
                                    
                                }
                            }
                            count += 1
                        }
                            
                        
                    }else{
                        print("\n\n🔥RESPONSE WAS NULL!🔥\n\n")
                    }
                }
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
            return
        }
    }
    
    //gonna try this w a sephamore
    private func getHomePageData(timeOfDay: String){
        
    }
    
    //searching for multiple recipes based on query, returning small recipe data
    //returning: recipeId, recipeName,
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
        let recipeURI = "recipes/search"
        
        //paramName=param&paramName=param
        //let params = "diet=vegetarian&excludeIngredients=coconut&instructionsRequired=true&intolerances=egg%2C+gluten&limitLicense=false&number=1&offset=0&query=burger&type=main+course"
        
        let fullURLstring:String = "\(baseURL)\(recipeURI)\(queryString)"
        
        
        if let urlRequest = configureURLRequest(httpUrl: fullURLstring, httpAction: "GET", httpHeaders: getHeaders){
            
            // Load configuration into Session \\
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: urlRequest) {
                (data, response, error) in
                
                if let urlResp = response{
                    print(urlResp)
                    
                    //parse away } and {
                    let respParse = urlResp.description.components(separatedBy: ["{","}"])
                    
                    if(respParse.count > 0){
                        var count = 0
                        
                        //response headers
                        let heads = respParse[4].components(separatedBy: [";","="])
                        
                        for header in heads {
                            
                            if(header.contains("X-RateLimit-requests-Remaining")){
                                print("\n\n🔥Header\(header)🔥\n")
                                
                                let remaining = heads[count+1].components(separatedBy: ["\""," "])
                                if let remainReqs = Int(remaining[1]){
                                    
                                    //get request limit
                                    print("\n\n🔥REMAINING REQS == \(remainReqs)🔥\n\n")
                                    
                                    //store in firebase as new remaing reqs
                                    self.setRequestNum(newReqs: remainReqs)
                                    
                                }
                            }
                            count += 1
                        }
                        
                        
                    }else{
                        print("\n\n🔥RESPONSE WAS NULL!🔥\n\n")
                    }
                }
                
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
            return
        }
    }
    
    func getMealPlanData(queryString: String, completionHandler: @escaping(Data?, String?) -> Void){
    
        //base recipe URL
        let mealPlanURI = "recipes/mealplans/generate"
        
        //paramName=param&paramName=param
        //let params = "diet=vegetarian&excludeIngredients=coconut&targetCalories=2000&timeFrame=week"
        
        let fullURLstring:String = "\(baseURL)\(mealPlanURI)\(queryString)"

        if let urlRequest = configureURLRequest(httpUrl: fullURLstring, httpAction: "GET", httpHeaders: getHeaders) {
            
            // Load configuration into Session \\
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: urlRequest) {
                (data, response, error) in
                
                if let urlResp = response{
                    print(urlResp)
                    
                    //parse away } and {
                    let respParse = urlResp.description.components(separatedBy: ["{","}"])
                    
                    if(respParse.count > 0){
                        var count = 0
                        
                        //response headers
                        let heads = respParse[4].components(separatedBy: [";","="])
                        
                        for header in heads {
                            
                            if(header.contains("X-RateLimit-requests-Remaining")){
                                print("\n\n🔥Header\(header)🔥\n")
                                
                                let remaining = heads[count+1].components(separatedBy: ["\""," "])
                                if let remainReqs = Int(remaining[1]){
                                    
                                    //get request limit
                                    print("\n\n🔥REMAINING REQS == \(remainReqs)🔥\n\n")
                                    
                                    //store in firebase as new remaing reqs
                                    
                                    
                                }
                            }
                            count += 1
                        }
                        
                        
                    }else{
                        print("\n\n🔥RESPONSE WAS NULL!🔥\n\n")
                    }
                }
                
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
            return
        }
    }
    
    private class func getRequestNum() {
        
        DatabaseController.shared().getRequestsAvailable(completionHandle: {
            (response) in
            
            if let response = response {
                self.sharedInstance.requestsAvailable = response
            }
        
        })
    }
    
    private func setRequestNum(newReqs: Int) {
        
       SpoonApi.sharedInstance.requestsAvailable = DatabaseController.shared().setRequestsAvailable(newReqs)
    }
    
    // MARK: - Auth Key
    private class func getAuthKey() -> String {
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
