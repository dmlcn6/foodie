//
//  ShoppingListViewController.swift
//  foodieApp
//
//  Created by Mr. Lopez on 3/12/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

import UIKit
import CoreData

class CollapsableShoppingList {
    let label: String
    let children: [CollapsableShoppingList]
    var isCollapsed: Bool
    var isDeletable: Bool
    
    init(label: String, children: [CollapsableShoppingList] = [], isCollapsed: Bool = true, isDeletable: Bool) {
        self.label = label
        self.children = children
        self.isCollapsed = isCollapsed
        self.isDeletable = isDeletable
    }
}

class ShoppingListViewController: UITableViewController {
    
    var displayedRows: [CollapsableShoppingList] = []
    var recipeList: [Recipe] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData() {
        let context = DatabaseController.getContext()
        
        var collapsedCellList:[CollapsableShoppingList] = [CollapsableShoppingList]()

        
        do {
            let data = try context.fetch(fetchRequest())
            print("\n\ndata\(data)")
            recipeList = data
            
            for recipe in data {
                
                var childrenList:[CollapsableShoppingList] = [CollapsableShoppingList]()
                
                if let collapseableIngs = recipe.ingredientList {
                    //let collapse = NSKeyedUnarchiver.unarchiveObject(with: collapseableIngs)
                    
                    if let collapse = collapseableIngs.allObjects as? [Ingredient]{
                        for ingredient in collapse{
                            if let ingredientName = ingredient.ingName  {
                                let newCollapsedIngCell = CollapsableShoppingList(label: ingredientName, children: [CollapsableShoppingList](), isCollapsed: true, isDeletable: false)
                                childrenList.append(newCollapsedIngCell)
                            }
                        }
                    }
                }
                
                if let recipeName = recipe.recipeName {
                    let newRecipeCell = CollapsableShoppingList(label: recipeName, children: childrenList, isCollapsed: true, isDeletable: true)
                    collapsedCellList.append(newRecipeCell)
                }
            }
            displayedRows = collapsedCellList
        } catch {
            print("Fetching Failed")
        }
        tableView.reloadData()
    }
    
    func fetchRequest() -> NSFetchRequest<Recipe> {
        let nsFetch = NSFetchRequest<Recipe>(entityName: "Recipe")
        nsFetch.returnsObjectsAsFaults = false
        return nsFetch
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return displayedRows.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeIngCell", for: indexPath) as! ShoppingListTableViewCell

        let viewCell = displayedRows[indexPath.row]
        // Configure the cell...
        if (cell.infoLabel.text != nil) {
            cell.infoLabel.text = viewCell.label
        }
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
         let viewModel = displayedRows[indexPath.row]
            
        
        if viewModel.children.count > 0 {
            let range = indexPath.row+1...indexPath.row+viewModel.children.count as CountableClosedRange<Int>
            
            let indexPaths = range.map{return NSIndexPath.init(row: $0, section: indexPath.section)} as [IndexPath]
            
            tableView.beginUpdates()
            if viewModel.isCollapsed {
                displayedRows.insert(contentsOf: viewModel.children, at: indexPath.row+1)
                tableView.insertRows(at: indexPaths as [IndexPath], with: .automatic)
            } else {
                displayedRows.removeSubrange(range)
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
            tableView.endUpdates()
        }
        viewModel.isCollapsed = !viewModel.isCollapsed
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data sourcelet fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Employee")
            if (displayedRows[indexPath.row].isCollapsed == true && displayedRows[indexPath.row].isDeletable == true) {
                let context = DatabaseController.getContext()
                let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipe")
                
                fetch.predicate = NSPredicate(format: "recipeId==\(recipeList[indexPath.row].recipeId)")
                
                do {
                    if let data = try context.fetch(fetch) as? [Recipe] {
                    
                        for object in data {
                            context.delete(object)
                        }
                    }
                }catch{
                    let nserror = error as NSError
                    print("Unresolved error \(nserror), \(nserror.userInfo)")
                }
                
                tableView.beginUpdates()
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                displayedRows.remove(at: indexPath.row)
                
                tableView.endUpdates()
                tableView.reloadData()
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
