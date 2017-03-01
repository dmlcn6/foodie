//
//  ExploreRecipeViewController.swift
//  foodieApp
//
//  Created by Mr. Lopez on 2/27/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

import UIKit

class ExploreRecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var objects = [String]()
    
    //DB access\\
    var spoonApiAccess:SpoonApi = SpoonApi()
    
    @IBOutlet weak var recipeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        objects = ["recipe1","recipe2","Recipe3", "recipe4","recipe5","Recipe6"]
        
        
        //loads only once\\
        let response = spoonApiAccess.populateExplorePage()
        print(response)
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
        return 6
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
    
    @IBAction func likeRecipe(sender: UIButton){
        let title = objects[sender.tag] as String
        
        
        let activityCont: UIActivityViewController = UIActivityViewController(activityItems: [title], applicationActivities: nil)
        
        self.present(activityCont, animated: true, completion: nil)
        
        print("hello")
    }
    
    @IBAction func addRecipe(sender: UIButton){
        let title = objects[sender.tag] as String
        
        let alertString = "Added \(title) to your list!"
        
        let alertCont: UIAlertController = UIAlertController(title: "Added", message: alertString, preferredStyle: .alert)
        
        //set the confirm action
        let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        //add confirm button to alert
        alertCont.addAction(confirmAction)
        
        self.present(alertCont, animated: true, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "showRecipe"){
            
        }
    }
 

}
