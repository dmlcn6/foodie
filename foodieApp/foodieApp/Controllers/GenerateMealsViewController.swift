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
        
        var queryString = "?"
        
        if let dietText = dietInput.text {
            if !(dietText.isEmpty){
                queryString += "diet=\(dietText)"
            }
            
        }
        if let excludeText = excludedInput.text{
            if !(excludeText.isEmpty){
                if (queryString == "?"){
                    queryString += "exclude="
                }else {
                    queryString += "&exclude="
                }
                if (excludeText.contains(",")){
                    let excludeIngs = excludeText.components(separatedBy: ",")
                    
                    for ing in excludeIngs{
                        
                        let parsedIngs = ing.components(separatedBy: " ")
                        for eachIng in parsedIngs{
                            if (ing == excludeIngs.last){
                                queryString += eachIng
                            }else{
                                if(eachIng != ""){
                                    queryString += eachIng + "%2C"
                                }
                            }
                        }
                        
                    }
                }else{
                    queryString += excludeText
                }
            }
        }
        if let calorieText = caloriesInput.text{
            if !(calorieText.isEmpty){
                if let calories = Int(calorieText){
                    if (queryString == "?"){
                        queryString += "targetCalories=\(calories)"
                    }else {
                        queryString += "&targetCalories=\(calories)"
                    }
                }
            }
        }
        
        if (queryString == "?"){
            queryString += "timeFrame=week"
        }else {
            queryString += "&timeFrame=week"
        }
        
        //var queryString = "diet=\(diet)&exclude=\(exclude)&targetCalories=\(calories)&timeFrame=week"
        
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
            
            //save recipe to local context for offline usage
            //let context = DatabaseController.getContext()
            
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
                            for (key, value) in result{
                                
                                //print("\n\nVALUE: \(value)\n\n")
                                if (key == "day"){
                                    
                                }
                                if (key == "slot"){
                                    
                                }
                                if let value = value as? String, key == "value" {
                                    if let dataValue = value.data(using: .utf8){
                                        if let mealObject = try? JSONSerialization.jsonObject(with: dataValue, options: []) as! [String:Any]{
                                            
                                            let savingRecipe: FoodieRecipe = FoodieRecipe(name: "", id: 0, image: UIImage(), time: 0, servings: 0)

                                            for (key,value) in mealObject{
                                                
                                                print("\n\nK:\(key) V: \(value)\n\n")
                                                
                                                if (key == "id"){
                                                    if let value = value as? Double{
                                                        
                                                        savingRecipe.recipeId = value
                                                        
                                                        
                                                    }
                                                }
                                                if let imgType = value as? String, key == "imageType" {
                                                
                                                    let baseImageUrl = "https://spoonacular.com/recipeImages/\(Int(savingRecipe.recipeId))-480x360.\(imgType)"
                                                    
                                                    
                                                    if let recipeImageUrl = URL(string: baseImageUrl),
                                                        let imageData = try? Data(contentsOf: recipeImageUrl) {
                                                        
                                                        let image = UIImage(data: imageData)
                                                        
                                                        
                                                        savingRecipe.recipeImage = image
                                                        
                                                    }else {
                                                        savingRecipe.recipeImage = UIImage()
                                                    }
                                                }
                                                if (key == "title"){
                                                    if let name = value as? String{
                                                        savingRecipe.recipeName = name
                                                    }
                                                }
                                            }
                                            
                                            savingRecipe.recipeServings = 0
                                            savingRecipe.recipeTime = 0
                                            
                                            meals.append(savingRecipe)
                                        }
                                    }
                                }
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
