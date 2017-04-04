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
    
    func parseMealPlanJson(data: Data) {
        
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
