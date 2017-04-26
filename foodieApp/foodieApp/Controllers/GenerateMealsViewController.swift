//
//  GenerateMealsViewController.swift
//  foodieApp
//
//  Created by Mr. Lopez on 4/3/17.
//  Copyright © 2017 Darryl Lopez. All rights reserved.
//

import UIKit

class GenerateMealsViewController: UIViewController{
    
    //access SpoonApi singleton instance
    var spoonApiAccess: SpoonApi!
    
    @IBOutlet weak var dietInput: UITextField!
    @IBOutlet weak var excludedInput: UITextField!
    @IBOutlet weak var caloriesInput: UITextField!
    @IBOutlet weak var mealsCollectionView: UICollectionView!
    
    var breakfast = [FoodieRecipe]()
    var lunch = [FoodieRecipe]()
    var dinner = [FoodieRecipe]()
    var meals = [FoodieRecipe]()
    var mealErrors = [String]()
    let indicator = ActivityIndicatorController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //grab spoonApi singleton from tabbarviewcont
        if let tbvc = tabBarController as? TabBarController{
            spoonApiAccess = tbvc.spoonApi
        }
        
        // Header pin Is only feature of UICollectionViewFlowLayout not UICollectionViewLayout
        if let layout = mealsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            layout.sectionHeadersPinToVisibleBounds = true
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - SpoonApi
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
        
        indicator.setup(parentView: self.view)
        indicator.start()
        
        //loads only once\\
        spoonApiAccess.getMealPlanData(queryString: queryString){
            (data,error) in
            
            if let data = data {
                self.parseMealPlanJson(data: data)
                self.mealsCollectionView.reloadData()
                
                self.indicator.stop()
            }else if let error = error{
                self.mealErrors.append(error.description)
                self.mealsCollectionView.reloadData()
                
                self.indicator.stop()
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
                        var foodHour = 0
                        for result in resultsArray {
                            //print("\n\nRESULTSPART\(result)\n\n")
                            for (key, value) in result{
                                
                                //print("\n\nVALUE: \(value)\n\n")
                                
                                if (key == "slot"){
                                    if let value = value as? Int{
                                        foodHour = value
                                    }
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
                                            savingRecipe.foodHour = foodHour
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
            
            sortMeals(recipeArray: meals)
        }
    }
    
    func sortMeals(recipeArray: [FoodieRecipe]){
        for meal in meals{
            if let foodHour = meal.foodHour{
                switch foodHour {
                case 1:
                    breakfast.append(meal)
                case 2:
                    lunch.append(meal)
                case 3:
                    dinner.append(meal)
                default:
                    break
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
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}
extension GenerateMealsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mealPlan", for: indexPath) as! MealCollectionViewCell
        
        if (meals.count > 0){
            switch indexPath.section {
            case 0:
                cell.mealImageView.image = breakfast[indexPath.row].recipeImage
                cell.mealLabel.text = breakfast[indexPath.row].recipeName
            case 1:
                cell.mealImageView.image = lunch[indexPath.row].recipeImage
                cell.mealLabel.text = lunch[indexPath.row].recipeName
            case 2:
                cell.mealImageView.image = dinner[indexPath.row].recipeImage
                cell.mealLabel.text = dinner[indexPath.row].recipeName
            default:
                break
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "foodHour", for: indexPath) as! MealHeaderReusableView
        
        if (meals.count > 0){
            switch kind {
            case UICollectionElementKindSectionHeader:
                var mealHeader = ""
                var mealHeaderColor = UIColor()

                if (indexPath.section == 0) {
                    mealHeader = "Breakfast"
                    mealHeaderColor = hexStringToUIColor(hex: "#ffbd04")
                }else if (indexPath.section == 1) {
                    mealHeader = "Lunch"
                    mealHeaderColor = hexStringToUIColor(hex: "#eb8c00")
                }else {
                    mealHeader = "Main Course"
                    mealHeaderColor = hexStringToUIColor(hex: "#dc6900")
                }
                
                header.backgroundColor = mealHeaderColor
                header.mealHeader.text = mealHeader
                
                
            default:
                assert(false, "Unexpected element kind")
            }
        }
        
        return header
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0
        if (meals.count > 0){
            
            switch section{
                case 0:
                    count = breakfast.count
                case 1:
                    count = lunch.count
                case 2:
                    count = dinner.count
                default:
                    return 0
            }
            
            return count
            
        }else{
            return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}



