//
//  ExploreRecipeViewController.swift
//  foodieApp
//
//  Created by Mr. Lopez on 2/27/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

import UIKit
import CoreData


class ExploreRecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Class Members
    var objects = [String]()
    var recipes = [FoodieRecipe]()
    var parseData:Data = Data()
    
    //DB access
    var spoonApiAccess:SpoonApi = SpoonApi()

    @IBOutlet weak var recipeTableView: UITableView!
    
    
    // MARK: - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        objects = ["recipe1","recipe2","Recipe3","recipe4","recipe5","Recipe6"]
        
        
        //loads only once\\
        spoonApiAccess.getExplorePageData(urlParams: ""){
            (data,error) in
            
            if let data = data {
                self.parseExploreJson(data: data)
                self.recipeTableView.reloadData()
            }else{
                //internet could be down
                // or some other problem
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.recipeTableView.reloadData()
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
        
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //loads only once\
        
        let selectedRecipeId = recipes[indexPath.row].recipeId
        
        spoonApiAccess.getAdvancedRecipeData(recipeId: selectedRecipeId){
            (data,error) in
            
            if let data = data {
                self.parseAdvancedRecipeJson(data: data)
                
                self.performSegue(withIdentifier: "showRecipe", sender: self)
            }else{
                //internet could be down
                // or some other problem
                //alert user that there was a problem and try again
            }
        }
        
    }
    
    // Configure the cell \\
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get resuable cell name
        let cell = tableView.dequeueReusableCell(withIdentifier: "exploreRecipeCell", for: indexPath) as! ExploreRecipeTableViewCell
        
        //set recipeImageView
        cell.recipeImageView.image = recipes[indexPath.row].recipeImage
        
        //set recipeLabel
        cell.recipeLabel.text = recipes[indexPath.row].recipeName
        
        //set button tags so the indexPath is know in the buttons func
        cell.recipeLikeButton.tag = indexPath.row
        cell.recipeAddButton.tag = indexPath.row
        
        //set buttons targe func name
        cell.recipeLikeButton.addTarget(self, action: #selector(likeRecipe(sender:)), for: .touchUpInside)
        cell.recipeAddButton.addTarget(self, action: #selector(addRecipe(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    
    // MARK: - TableView Buttons
    
    // Add recipe to list of like recipes
    @IBAction func likeRecipe(sender: UIButton){
        let title = recipes[sender.tag].recipeName as String
        
        
        let activityCont: UIActivityViewController = UIActivityViewController(activityItems: [title], applicationActivities: nil)
        
        self.present(activityCont, animated: true, completion: nil)
        
    }
    
    // Add recipe to Weekly Meal
    @IBAction func addRecipe(sender: UIButton){
        let title = recipes[sender.tag].recipeName as String
        var alertString = ""
        
        spoonApiAccess.getAdvancedRecipeData(recipeId: Double(recipes[sender.tag].recipeId)){
            (data,error) in
            
            if let data = data {
                
                let recipes = self.recipes
                let selectedIndexPath = sender.tag
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any] {
                    print("NEWJSONN \(json)")
                    
                    for (key, value) in json {
                        print("\n\nINSTRUCTIONKEY::\(key) \n\n RESULTS::\(value)\n\n\n")
                        if (key == "servings"){
                            if let servings = value as? Double {
                                recipes[selectedIndexPath].recipeServings = servings
                            }
                        }
                        if (key == "analyzedInstructions"){
                            if let instructions = value as? [[String:Any]] {
                                for instruction in instructions {
                                    for (key,value) in instruction {
                                        if (key == "steps"){
                                            if let instructionResults = value as? [[String:Any]] {
                                                print("INSTRUCTION ARRAY \(instructionResults)\n\n")
                                                for instruction in instructionResults{
                                                    print("INSTRUCTIONS \(instruction)\n\n")
                                                    for (key,value) in instruction {
                                                        if let step = value as? String, key == "step" {
                                                            print("FINALSTEPS \(value)\n\n")
                                                            recipes[selectedIndexPath].instructions.append(step)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if (key == "extendedIngredients"){
                            if let ingredients = value as? [[String:Any]] {
                                for ingredient in ingredients {
                                    for (key,value) in ingredient {
                                        if let newIngredient = value as? String, key == "originalString"{
                                            recipes[selectedIndexPath].ingredients.append(newIngredient)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                //save recipe to local context for offline usage
                let context = DatabaseController.getContext()
                
                let savingRecipe = Recipe(context: context)
                
                if let image = recipes[sender.tag].recipeImage,
                    let imageData = UIImageJPEGRepresentation(image, 1.0){
                    savingRecipe.recipeImage = imageData as NSData
                }else {
                    savingRecipe.recipeImage = nil
                }
                
                savingRecipe.recipeId = recipes[sender.tag].recipeId
                savingRecipe.recipeName = recipes[sender.tag].recipeName
                savingRecipe.recipeServings = recipes[sender.tag].recipeServings
                savingRecipe.recipeTime = recipes[sender.tag].recipeTime
 
                let ingsObject = recipes[sender.tag].ingredients
                
                for ing in ingsObject {
                    
                    let newIng = NSEntityDescription.insertNewObject(forEntityName: "Ingredient", into: context) as? Ingredient
                    
                    if let newIng = newIng {
                        newIng.ingName = ing
                        savingRecipe.addToIngredientList(newIng)
                    }
                }
                let instructsObject = recipes[sender.tag].instructions 
                
                
                
                
                
                if let ingsObjectData = NSKeyedArchiver.archivedData(withRootObject: ingsObject) as? NSData,
                    let instructsObjectData = NSKeyedArchiver.archivedData(withRootObject: instructsObject) as? NSData {
                    
                    savingRecipe.recipeIngredients = ingsObjectData
                    savingRecipe.recipeInstructions = instructsObjectData
                }
                
                
                
                
                if(DatabaseController.saveContext() == true) {
                    alertString = "Added \(title) to your list!"
                    
                    let alertCont: UIAlertController = UIAlertController(title: "Added", message: alertString, preferredStyle: .alert)
                    
                    // set the confirm action
                    let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    // add confirm button to alert
                    alertCont.addAction(confirmAction)
                    
                    self.present(alertCont, animated: true, completion: nil)
                    
                } else {
                    //create an alert to user that Trip didnt save
                    alertString = "Trip failed to save \(title) to your list!"
                    
                    let alertCont: UIAlertController = UIAlertController(title: "Uh Oh, Something went wrong!", message: alertString, preferredStyle: .alert)
                    
                    // set the confirm action
                    let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    // add confirm button to alert
                    alertCont.addAction(confirmAction)
                    
                    self.present(alertCont, animated: true, completion: nil)
                }
        
                
            }else{
                //internet could be down
                // or some other problem
                //alert user that there was a problem and try again
            }
            
        }
    }
    
    
    // MARK: - SpoonApi
    
    func getParamsForRecipes(){
        
    }
    
    
    
    func parseAdvancedRecipeJson(data: Data){
        if let selectedIndexPath = recipeTableView.indexPathForSelectedRow {
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any] {
                print("NEWJSONN \(json)")
                
                for (key, value) in json {
                    print("\n\nINSTRUCTIONKEY::\(key) \n\n RESULTS::\(value)\n\n\n")
                    if (key == "servings"){
                        if let servings = value as? Double {
                            recipes[selectedIndexPath.row].recipeServings = servings
                        }
                    }
                    if (key == "analyzedInstructions"){
                        if let instructions = value as? [[String:Any]] {
                            for instruction in instructions {
                                for (key,value) in instruction {
                                    if (key == "steps"){
                                        if let instructionResults = value as? [[String:Any]] {
                                            print("INSTRUCTION ARRAY \(instructionResults)\n\n")
                                            for instruction in instructionResults{
                                                print("INSTRUCTIONS \(instruction)\n\n")
                                                for (key,value) in instruction {
                                                    if let step = value as? String, key == "step" {
                                                        print("FINALSTEPS \(value)\n\n")
                                                        recipes[selectedIndexPath.row].instructions.append(step)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (key == "extendedIngredients"){
                        if let ingredients = value as? [[String:Any]] {
                            for ingredient in ingredients {
                                for (key,value) in ingredient {
                                    if let newIngredient = value as? String, key == "originalString"{
                                        recipes[selectedIndexPath.row].ingredients.append(newIngredient)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func parseExploreJson(data: Data){
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]{
            
            
            /*
            if let results = root["results"] as? [String:Any] {
                print("PARSEJSON \(results)\n\n\n")
            }
            */
            
            //var resultsArray = json["results"] as? [String:Any]
          
            for (key, value) in json{
                //print("KEY::\(key) \n\n RESULTS::\(value)\n\n\n")
                if (key == "results"){
                    if let resultsArray = value as? [[String:Any]] {
                        //print("\n\nRESULTSARRAY\(resultsArray)\n\n")
                        
                        for result in resultsArray {
                            //print("\n\nRESULTSPART\(result)\n\n")
                            
                            if let recipeTitle = result["title"] as? String,
                                let recipeId = result["id"] as? Double,
                                let recipeTime = result["readyInMinutes"] as? Double {
                                
                                
                                let baseImageUrl = "https://spoonacular.com/recipeImages/\(Int(recipeId))-480x360.jpg"
                                
                                //let baseImageUrl = "https://spoonacular.com/recipeImages/\(imageString)"
                                
                                if let recipeImageUrl = URL(string: baseImageUrl),
                                    let imageData = try? Data(contentsOf: recipeImageUrl) {
                                    
                                    let image = UIImage(data: imageData)
                                    
                                    if let recipeImage = image{
                                        let newRecipe:FoodieRecipe = FoodieRecipe(name: recipeTitle, id: recipeId, image: recipeImage, time: recipeTime, servings: 0)
                                        recipes.append(newRecipe)
                                    }else {
                                        let newRecipe:FoodieRecipe = FoodieRecipe(name: recipeTitle, id: recipeId, image: UIImage(), time: recipeTime, servings: 0)
                                        recipes.append(newRecipe)
                                    }
                                }
                            }
                            //print("\n\nTTITLE::\(result["title"])\n\n")
                        }
                    }
                }
            }
        }
    } //end of parseExploreJson

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "showRecipe"){
            if let destination = segue.destination as? ShowRecipeViewController,
                let selectedIndex = recipeTableView.indexPathForSelectedRow{
                destination.selectedRecipe = recipes[selectedIndex.row]
            }
        }
    }
}
