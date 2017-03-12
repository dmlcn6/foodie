//
//  ShowRecipeViewController.swift
//  foodieApp
//
//  Created by Mr. Lopez on 2/26/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

import UIKit

class ShowRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - View Elements
    // subView elements \\
    @IBOutlet weak var recipeInfoSegmentor: UISegmentedControl!
    @IBOutlet weak var recipeInfoTableView: UITableView!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeTimeLabel: UILabel!
    @IBOutlet weak var recipeServingsLabel: UILabel!
    
    // MARK: - Class Members
    var selectedRecipe: Recipe?
    var selectedSegment: Int = 0

    // MARK: - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recipeInfoTableView.reloadData()
        
        if let selectedRecipe = selectedRecipe {
            recipeImage.image = selectedRecipe.recipeImage
            recipeTimeLabel.text = convertTime(time: selectedRecipe.recipeTime)
            recipeServingsLabel.text = selectedRecipe.recipeServings.description
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //converts parsed time into human readable time: 99h 59min
    func convertTime(time: Int) -> String{
        var remainingTime = 0
        var hours = 0
        
        if (time > 120){
            remainingTime = time - 120
            hours = 2
        }else if (time > 60){
            remainingTime = time - 60
            hours = 1
        }else{
            remainingTime = time
        }
        
        if (hours == 0){
            return "\(remainingTime)mins"
        }else {
            return "\(hours)h \(remainingTime)min"
        }
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        //if segmentor section is changed
        //get new segment index
        selectedSegment = recipeInfoSegmentor.selectedSegmentIndex
        
        //reload the table w different data
        recipeInfoTableView.reloadData()
    }
    
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let selectedRecipe = selectedRecipe {
            if (selectedSegment == 0){
                return selectedRecipe.instructions.count
            }else{
                return selectedRecipe.ingredients.count
            }
        }else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "showRecipe", sender: self)
    }
    
    // Configure the cell \\
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{

        //get resuable cell name
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeInfoCell", for: indexPath) as! RecipeInfoTableViewCell
        
        if let selectedRecipe = selectedRecipe {
            if (selectedSegment == 0){
                cell.infoLabel.text = selectedRecipe.instructions[indexPath.row]
            }else{
                cell.infoLabel.text = selectedRecipe.ingredients[indexPath.row]
            }
        }
        return cell
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
