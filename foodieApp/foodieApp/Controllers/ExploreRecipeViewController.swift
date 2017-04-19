//
//  ExploreRecipeViewController.swift
//  foodieApp
//
//  Created by Mr. Lopez on 2/27/17.
//  Copyright © 2017 Darryl Lopez. All rights reserved.
//

import UIKit
import Foundation
import CoreData


class ExploreRecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: - Class Members
    let indicator = ActivityIndicatorController()
    var foodHour = DateComponents()
    var objects = [String]()
    var recipes = [FoodieRecipe]()
    var recipeErrors = [String]()
    var recipeCurations = [FoodieRecipe]()
    var searchBar = UISearchBar()
    @IBOutlet weak var mealSelection: UISegmentedControl!
    @IBOutlet weak var dietInput: UITextField!
    @IBOutlet weak var excludedInput: UITextField!
    @IBOutlet weak var recipeTableView: UITableView!

    //DB access
    var spoonApiAccess:SpoonApi = SpoonApi()

    
    // MARK: - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        objects = ["recipe1","recipe2","Recipe3","recipe4","recipe5","Recipe6"]
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        renderSearchBar()
        
        let now = Date()
        
        DateFormatter.localizedString(from: now, dateStyle: .none, timeStyle: .short)
        
        let hour = Calendar.current.component(.hour, from: now)
        
        //if morning
        if (hour > 3 && hour < 12){
            //curate some lists of breakfasts
            //some vegan bkfasts
            //some very quick bkfasts
            //some smoothies
            
            
            recipeCurations = [
                FoodieRecipe.init(name: "Smoothies for Sunrises!", id: 0, image: UIImage(named: "smoothiesforsunrises.jpg")!, time: 0, servings: 0),
                FoodieRecipe.init(name: "In a Rush? Need a quick Bkfast?", id: 0, image:  UIImage(named: "quickbreakfast.jpeg")!, time: 0, servings: 0),
                FoodieRecipe.init(name: "Sunday Mornin' Breaksfasts", id: 0, image:  UIImage(named: "sundaymorningbreakfasts.jpg")!, time: 0, servings: 0)
            ]
            
            print("hello morning\(hour)")
        }else if(hour >= 12 && hour < 18){
            //curate some lists of LUNCHES
            //some vegan snacks w veggies
            //some healthy lunches
            //some high protein smoothies
            
            recipeCurations = [
                FoodieRecipe.init(name: "Skip the Fast Food Run! Try these Healthy Vegan Lunches", id: 0, image:  UIImage(named: "healthyveganlunches.jpg")!, time: 0, servings: 0),
                FoodieRecipe.init(name: "Quick & Delicious Salads for Lunch!", id: 0, image:  UIImage(named: "saladsforlunch.jpeg")!, time: 0, servings: 0),
                FoodieRecipe.init(name: "Hungry at home? Grab and Go Snacks.", id: 0, image:  UIImage(named: "grabandgosnacks.jpg")!, time: 0, servings: 0)
            ]
            
            
            
            
            print("hello afternoon\(hour)")
        }else {
            //curate some lists of dinners
            //some vegan dinners
            //some very quick dinners
            //some high protein smoothies
            
            recipeCurations = [
                FoodieRecipe.init(name: "Main Courses of the Week", id: 0, image:  UIImage(named: "maincoursesoftheweekjpeg.jpeg")!, time: 0, servings: 0),
                FoodieRecipe.init(name: "Recovery Smoothies", id: 0, image:  UIImage(named: "recoverysmoothies.jpg")!, time: 0, servings: 0),
                FoodieRecipe.init(name: "30 Mouth Watering Vegan Dinners", id: 0, image:  UIImage(named: "mouthwateringvegandinners.jpeg")!, time: 0, servings: 0)
            ]
            print("hello NightTime\(hour)")
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Search Bar
    func renderSearchBar() {
        
        searchBar.showsCancelButton = false
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        recipes.removeAll()
        recipeErrors.removeAll()
        //recipeTableView.reloadData()
        
        var queryString = "?instructionsRequired=true"
        var query = ""
        
        if let dietText = dietInput.text {
            if !(dietText.isEmpty){
                queryString += "&diet=\(dietText)"
            }
        }
        
        switch(self.mealSelection.selectedSegmentIndex){
        case 0:
            queryString += "&type=breakfast"
        case 1:
            queryString += "&type=lunch"
        case 2:
            queryString += "&type=main+course"
        case 3:
            queryString += "&type=snack"
        case 4:
            queryString += "&type=dessert"
        default:
            break
        }
        
        if let excludeText = excludedInput.text{
            if !(excludeText.isEmpty){
                queryString += "&exclude="
                
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
        
        if let search = searchBar.text {
            var validSearch = true
            if (search.contains(" ") && search.characters.count > 1){
                let badSearch = search.trimmingCharacters(in: .whitespaces)
                if (badSearch.characters.count < 1) {
                    //alert you must enter text
                    let alertCont: UIAlertController = UIAlertController(title: "Uh Oh!", message: "Please enter a search string.", preferredStyle: .alert)
                    
                    // set the confirm action
                    let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    // add confirm button to alert
                    alertCont.addAction(confirmAction)
                    validSearch = false
                    self.present(alertCont, animated: true, completion: nil)
                }else {
                
                    let parsedQuery = search.components(separatedBy: " ")
                    
                    for word in parsedQuery{
                        
                        let parsedWords = word.components(separatedBy: " ")
                        for eachWord in parsedWords{
                            if (eachWord == parsedQuery.last){
                                query += eachWord
                            }else{
                                if(eachWord != ""){
                                    query += eachWord + "+"
                                }
                            }
                        }
                        
                    }
                }
            }else if (search.contains(" ") && search.characters.count == 1){
                query = ""
            }else {
                query += search
            }
            
            if (validSearch){
                queryString += "&number=1&offset=0&query=\(query)"
                
                indicator.setup(parentView: self.view)
                indicator.start()
                
                
                //loads only once\\
                spoonApiAccess.getExplorePageData(queryString: queryString){
                    (data,error) in
                    
                    if let data = data {
                        self.parseExploreJson(data: data)
                        self.searchBar.endEditing(true)
                        self.recipeTableView.reloadData()
                        
                        self.indicator.stop()
                    }else if let error = error{
                        self.recipeErrors.append(error.description)
                        self.searchBar.endEditing(true)
                        self.recipeTableView.reloadData()
                        
                        self.indicator.stop()
                    }
                    
                    //reset field values
                    self.mealSelection.selectedSegmentIndex = -1
                    searchBar.text = ""
                }
            }
        }
    }
    
    
    // MARK: - Keyboard Dismissal
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.navigationItem.title = "Explore"
        //this resigns the first responder also
        searchBar.endEditing(true)
    }

    // MARK: - TableView Config
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rowCount = 0
        
        if recipes.count > 0{
            rowCount = recipes.count
        }else if(recipeErrors.count > 0){
            rowCount = recipeErrors.count
        }else{
            rowCount = recipeCurations.count
        }
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //loads only once\
        indicator.setup(parentView: self.view)
        indicator.start()
        
        if (recipes.count > 0){
            
            let selectedRecipeId = recipes[indexPath.row].recipeId
            
            spoonApiAccess.getAdvancedRecipeData(recipeId: selectedRecipeId){
                (data,error) in
                
                if let data = data {
                    self.parseAdvancedRecipeJson(data: data)
                    
                    self.indicator.stop()
                    self.performSegue(withIdentifier: "showRecipe", sender: self)
                    
                }else if let error = error {
                    self.recipeErrors.append(error.description)
                    self.recipeTableView.reloadData()
                    self.indicator.stop()
                }
            }
        }else {
            /*
            var queryString = ""
            //loads only once\\
            spoonApiAccess.getExplorePageData(queryString: queryString){
                (data,error) in
                
                if let data = data {
                    self.parseExploreJson(data: data)
                    self.searchBar.endEditing(true)
                    self.recipeTableView.reloadData()
                    
                    self.indicator.stop()
                }else if let error = error{
                    self.recipeErrors.append(error.description)
                    self.searchBar.endEditing(true)
                    self.recipeTableView.reloadData()
                    
                    self.indicator.stop()
                }
            }
            */
            indicator.stop()
        }
    }
    
    // Configure the cell \\
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get resuable cell name
        let cell = tableView.dequeueReusableCell(withIdentifier: "exploreRecipeCell", for: indexPath) as! ExploreRecipeTableViewCell
        
        if (recipes.count > 0) {
            cell.isUserInteractionEnabled = true
            
            //set recipeImageView
            cell.recipeImageView.image = recipes[indexPath.row].recipeImage
            
            //set recipeLabel
            cell.recipeLabel.text = recipes[indexPath.row].recipeName
            
            //set button tags so the indexPath is know in the buttons func
            cell.recipeAddButton.isHidden = false
            cell.recipeLikeButton.isHidden = false
            
            cell.recipeLikeButton.tag = indexPath.row
            cell.recipeAddButton.tag = indexPath.row
            
            //set buttons targe func name
            cell.recipeLikeButton.addTarget(self, action: #selector(likeRecipe(sender:)), for: .touchUpInside)
            cell.recipeAddButton.addTarget(self, action: #selector(addRecipe(sender:)), for: .touchUpInside)
        }else if (recipeErrors.count > 0){
            cell.recipeLabel.text = recipeErrors[indexPath.row]
            
            cell.recipeLikeButton.isHidden = true
            cell.recipeAddButton.isHidden = true
            
            cell.recipeImageView.image = UIImage(
            )
            
            cell.isUserInteractionEnabled = false
        }
        else{
            cell.recipeLabel.text = recipeCurations[indexPath.row].recipeName
            cell.recipeImageView.image = recipeCurations[indexPath.row].recipeImage
        }
        return cell
    }
    
    // MARK: - TableView Buttons
    
    // Add recipe to list of like recipes
    @IBAction func likeRecipe(sender: UIButton){
        let title = recipes[sender.tag].recipeName as String
        
        let activityCont: UIActivityViewController = UIActivityViewController(activityItems: [title, UIImage()], applicationActivities: nil)
        
        if let popOver = activityCont.popoverPresentationController {
            popOver.sourceView = self.view
        }
        
        
        activityCont.excludedActivityTypes = [UIActivityType.postToTencentWeibo]
        
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
                //let instructsObject = recipes[sender.tag].instructions
                
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
