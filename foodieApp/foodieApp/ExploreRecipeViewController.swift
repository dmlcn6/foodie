//
//  ExploreRecipeViewController.swift
//  foodieApp
//
//  Created by Mr. Lopez on 2/27/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

import UIKit

class ExploreRecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Class Members
    var objects = [String]()
    var recipesArray = [Recipe]()
    
    //DB access
    var spoonApiAccess:SpoonApi = SpoonApi()

    @IBOutlet weak var recipeTableView: UITableView!
    
    
    // MARK: - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        objects = ["recipe1","recipe2","Recipe3","recipe4","recipe5","Recipe6"]
        
        
        let recipeParams = ""
        
        getRecipes(parameters: recipeParams)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showRecipe", sender: self)
    }
    
    // Configure the cell \\
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get resuable cell name
        let cell = tableView.dequeueReusableCell(withIdentifier: "exploreRecipeCell", for: indexPath) as! ExploreRecipeTableViewCell
        
        //set recipeImageView
        
        
        //set recipeLabel
        cell.recipeLabel.text = objects[indexPath.row]
        
        //set button tags so the indexPath is know in the buttons func
        cell.recipeLikeButton.tag = indexPath.row
        cell.recipeAddButton.tag = indexPath.row
        
        //set buttons targe func name
        cell.recipeLikeButton.addTarget(self, action: #selector(likeRecipe(sender:)), for: .touchUpInside)
        cell.recipeAddButton.addTarget(self, action: #selector(addRecipe(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    
    // MARK: - TableView Actions
    
    // Add recipe to list of like recipes
    @IBAction func likeRecipe(sender: UIButton){
        let title = objects[sender.tag] as String
        
        
        let activityCont: UIActivityViewController = UIActivityViewController(activityItems: [title], applicationActivities: nil)
        
        self.present(activityCont, animated: true, completion: nil)
        
        print("hello")
    }
    
    // Add recipe to Weekly Meal
    @IBAction func addRecipe(sender: UIButton){
        let title = objects[sender.tag] as String
        
        let alertString = "Added \(title) to your list!"
        
        let alertCont: UIAlertController = UIAlertController(title: "Added", message: alertString, preferredStyle: .alert)
        
        // set the confirm action
        let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        // add confirm button to alert
        alertCont.addAction(confirmAction)
        
        self.present(alertCont, animated: true, completion: nil)
    }
    
    
    // MARK: - SpoonApi
    
    // Populates the tableView with recipes
    func getRecipes(parameters: String){
        let params = ""
        
        //loads only once\\
        spoonApiAccess.getExplorePageData(urlParams: params) {
            (data, errorStr) -> Void in
            if let errorString = errorStr {
                print("::ERROR:: \(errorString)")
            } else {
                if let data = data {
                    let dataString = String(data: data, encoding: String.Encoding.utf8)
                    print("\n\n::DATASTRING:: \(dataString)\n\n\n")
                    
                    self.parseJson(data: data)
                }
            }
        }
    }
    
    func getParamsForRecipes(){
        
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
                                let recipeId = result["id"] as? Int,
                                let recipeImage = result["image"] as? UIImage{
                                
                                let newRecipe:Recipe = Recipe(name: recipeTitle, image: recipeImage, id: recipeId)
                                recipesArray.append(newRecipe)
                            }
                            print("\n\nTTITLE::\(result["title"])\n\n")
                        }
                    }
                }
            }
                
            print("JSONNNNNNN\(json)\n\n")
            //print("\(json["results"])")
            
            
            
            

        }
    } //end of parseJson

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "showRecipe"){
            if let destination = segue.destination as? ShowRecipeViewController,
                let selectedIndex = recipeTableView.indexPathForSelectedRow{
                destination.title = objects[selectedIndex.row]
            }
        }
    }
}
