//
//  GenerateMealsViewController.swift
//  foodieApp
//
//  Created by Mr. Lopez on 4/3/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

import UIKit

class GenerateMealsViewController: UIViewController {
    
    var spoonApiAccess = SpoonApi()
    
    @IBOutlet weak var mealsTableView: UITableView!
    @IBOutlet weak var dietInput: UITextField!
    @IBOutlet weak var excludedInput: UITextField!
    @IBOutlet weak var caloriesInput: UITextField!
    
    var meals = [FoodieRecipe]()
    var mealErrors = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView Config
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rowCount = 0
        
        if meals.count > 0{
            rowCount = meals.count
        }else if(mealErrors.count > 0){
            rowCount = mealErrors.count
            
        }
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //loads only once\
        //let selectedRecipeId = meals[indexPath.row].recipeId
        
    }
    
    // Configure the cell \\
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get resuable cell name
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealPlan", for: indexPath) as! MealTableViewCell
        
        if (meals.count > 0) {
            cell.isUserInteractionEnabled = true
            
            //set recipeImageView
            cell.mealImageView.image = meals[indexPath.row].recipeImage
            
            //set recipeLabel
            cell.mealLable.text = meals[indexPath.row].recipeName
            
        }else if (mealErrors.count > 0){
            cell.mealLable.text = mealErrors[indexPath.row]
            
            cell.mealImageView.image = UIImage()
            
            cell.isUserInteractionEnabled = false
        }
        return cell
    }
    
    @IBAction func generateMealPlan(_ sender: Any) {
        meals.removeAll()
        mealErrors.removeAll()
        
        var diet = ""
        var exclude = ""
        var calories = ""
        
        if let dietText = dietInput.text {
            diet = dietText
        }
        if let excludeText = excludedInput.text{
            if (excludeText.contains(",")){
                let excludeIngs = excludeText.components(separatedBy: ",")
                
                for ing in excludeIngs{
                    if (ing == excludeIngs.last){
                        exclude += ing
                    }else{
                        exclude += ing + "%2C+"
                    }
                }
            }else if(excludeText.isEmpty){
                exclude = ""
            }
            else{
                exclude = excludeText
            }
        }
        if let calorieText = caloriesInput.text{
            calories = calorieText
        }
        
        let queryString = "diet=\(diet)&exclude=\(exclude)&targetCalories=\(calories)&timeFrame=week)"
        
        //loads only once\\
        spoonApiAccess.getMealPlanData(queryString: queryString){
            (data,error) in
            
            if let data = data {
                self.parseMealPlanJson(data: data)
                self.mealsTableView.reloadData()
            }else if let error = error{
                self.mealErrors.append(error.description)
                self.mealsTableView.reloadData()
            }
        }
    }
    
    func parseMealPlanJson(data: Data){
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]{
            
            print("PARSEJSON \(json)\n\n\n")
            /*
             if let results = root["results"] as? [String:Any] {
             print("PARSEJSON \(results)\n\n\n")
             }
             */
            
            //var resultsArray = json["results"] as? [String:Any]
            
            for (key, value) in json{
                print("KEY::\(key) \n\n RESULTS::\(value)\n\n\n")
                if(key == "status"){
                    if let httpStatus = value as? Int, httpStatus == 404 {
                        let alert = UIAlertController(title: "Error", message: "We're so sorry, something went wrong.", preferredStyle: .alert)
                        
                        // set the confirm action
                        let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        
                        // add confirm button to alert
                        alert.addAction(confirmAction)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                if (key == "items"){
                    if let resultsArray = value as? [[String:Any]] {
                        //print("\n\nRESULTSARRAY\(resultsArray)\n\n")
                        
                        for result in resultsArray {
                            //print("\n\nRESULTSPART\(result)\n\n")
                            
                            if let value = result["value"] as? [String:Any]{
                                print("\n\nVALUE: \(value)\n\n")
                                
                                //let baseImageUrl = "https://spoonacular.com/recipeImages/\(Int(recipeId))-480x360.jpg"
                                
                                /*
                                
                                if let recipeImageUrl = URL(string: baseImageUrl),
                                    let imageData = try? Data(contentsOf: recipeImageUrl) {
                                    
                                    let image = UIImage(data: imageData)
                                    
                                    if let recipeImage = image{
                                        let newRecipe:FoodieRecipe = FoodieRecipe(name: recipeTitle, id: recipeId, image: recipeImage, time: recipeTime, servings: 0)
                                        meals.append(newRecipe)
                                    }else {
                                        let newRecipe:FoodieRecipe = FoodieRecipe(name: recipeTitle, id: recipeId, image: UIImage(), time: recipeTime, servings: 0)
                                        meals.append(newRecipe)
                                    }
                                }
                                */
                                
                            }
                        }
                    }
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
