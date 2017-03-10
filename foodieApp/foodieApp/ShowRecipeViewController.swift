//
//  ShowRecipeViewController.swift
//  foodieApp
//
//  Created by Mr. Lopez on 2/26/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

import UIKit

class ShowRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Class Members
    
    // subView segmentor \\
    @IBOutlet weak var recipeInfoSegmentor: UISegmentedControl!
    @IBOutlet weak var recipeInfoTableView: UITableView!
    
    var selectedRecipe: Recipe?

    // MARK: - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        //performSegue(withIdentifier: "showRecipe", sender: self)
    }
    
    // Configure the cell \\
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{

        //get resuable cell name
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeInfoCell", for: indexPath) as! RecipeInfoTableViewCell
        
        
        
        /*
        set buttons targe func name
        cell.recipeLikeButton.addTarget(self, action: #selector(), for: .touchUpInside)
        cell.recipeAddButton.addTarget(self, action: #selector(), for: .touchUpInside)
        */
        
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
