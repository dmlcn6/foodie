//
//  DatabaseController.swift
//  foodieApp
//
//  Created by Mr. Lopez on 3/12/17.
//  Copyright © 2017 Darryl Lopez. All rights reserved.
//

import CoreData
import Firebase
import FirebaseAuth
typealias AuthClosure = (Int?) -> Void

class DatabaseController{
    
    //singleton of DB controller
    private static var sharedInstance: DatabaseController = {
        let dbInstance = DatabaseController()
        dbInstance.firebaseSingleton = FIRDatabase .database().reference(withPath: "foodieappserver")
        
        return dbInstance
    }()
    
    private init () {
        self.firebaseSingleton = FIRDatabaseReference()
    }
    
    //MARK: - Class Variables
    var firebaseSingleton: FIRDatabaseReference!
    
    //MARK: - DB Singleton Accessor
    class func shared() -> DatabaseController {
        return sharedInstance
    }
    
    //
    func getRequestsAvailable(completionHandle: @escaping AuthClosure) {
        var returnValue: Int? = nil
        
        let requestRef = firebaseSingleton.child("foodieRequestLimit").child("requestsAvailable")
        
        
        
            if let auth = FIRAuth.auth(), let _ = auth.currentUser {
                
                _ = requestRef.observe(.value, with: {
                    (snapshot) in
                    
                    print("\n\nsnapshot CHILD COUNT:: \(snapshot.childrenCount)\n\n")
                    print("\n\nsnapshot DESCRIPTION:: \(snapshot.description)\n\n")
                    
                    if let value = snapshot.value as? Int {
                        returnValue = value
                    }
                    
                    
                    completionHandle(returnValue)
                    
                })
                
            }else {
                 returnValue = nil
            }
        
    }
    
    func setRequestsAvailable(_ newReqs: Int) -> Int{
        
        if let auth = FIRAuth.auth(), let _ = auth.currentUser {
            let requestRef = firebaseSingleton.child("foodieRequestLimit")
            
            //temp var to hold reqs from db
            var currReqs: Int!
            
            //help wait for async call to firebase
            let sem = DispatchSemaphore.init(value: 0)
            
            //so i think i jsut implemented a double nested clojure
            //requestRef.runTransactionBlock(<#T##block: (FIRMutableData) -> FIRTransactionResult##(FIRMutableData) -> FIRTransactionResult#>, andCompletionBlock: <#T##(Error?, Bool, FIRDataSnapshot?) -> Void#>)
            
            requestRef.runTransactionBlock({
                (currData: FIRMutableData) -> FIRTransactionResult in
                
                if var postData = currData.value as? [String:Any] {
                    
                    currReqs = postData["requestsAvailable"] as? Int ?? 5000
                    
                    if(newReqs < currReqs){
                        postData["requestsAvailable"] = newReqs as AnyObject?
                        currData.value = postData
                        return FIRTransactionResult.success(withValue: currData)
                    }
                    
                    // Set value and report transaction success
                    currData.value = postData
                }

                return FIRTransactionResult.success(withValue: currData)
            }) { (error, status, snapshot) in
            
                if let error = error {
                    print("\n\n ERROR IN SET REQ NUM \(error.localizedDescription)\n\n")
                }
                
                sem.signal()
            }
            
            sem.wait()
            
            return currReqs
        }else {
            return 5000
        }
    }
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "foodieApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    // MARK: - Core Data Context getter
    class func getContext() -> NSManagedObjectContext{
        return self.persistentContainer.viewContext
    }
    
    
    // MARK: - Core Data Saving support
    class func saveContext() -> Bool {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                return true
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                return false
            }
        }else {
            return false
        }
    }
}
