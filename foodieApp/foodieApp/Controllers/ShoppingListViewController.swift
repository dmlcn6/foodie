//
//  ShoppingListViewController.swift
//  foodieApp
//
//  Created by Mr. Lopez on 3/12/17.
//  Copyright © 2017 Darryl Lopez. All rights reserved.
//

import UIKit
import CoreData

//custom recipe obj wrapper
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
    @IBOutlet var shoppingListTableView: UITableView!
    
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
    
    private func getData() {
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
        shoppingListTableView.reloadData()
    }
    
    //grab all saved recipes
    private func fetchRequest() -> NSFetchRequest<Recipe> {
        let nsFetch = NSFetchRequest<Recipe>(entityName: "Recipe")
        nsFetch.returnsObjectsAsFaults = false
        return nsFetch
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        //return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return the number of rows
        return displayedRows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeIngCell", for: indexPath) as! ShoppingListTableViewCell
        
        let viewCell = displayedRows[indexPath.row]
        
        
        // Configure the cell...
        if (cell.infoLabel.text != nil) {
            cell.infoLabel.text = viewCell.label
            
            if displayedRows[indexPath.row].isDeletable == true {
                
            }
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        let selectedRecipe = displayedRows[indexPath.row]
            
        
        //if children count is > 0, there are ings in the recipe
        if selectedRecipe.children.count > 0 {
            let range = indexPath.row+1...indexPath.row+selectedRecipe.children.count as CountableClosedRange<Int>
            
            let indexPaths = range.map{return NSIndexPath.init(row: $0, section: indexPath.section)} as [IndexPath]
            
            shoppingListTableView.beginUpdates()
            
            if selectedRecipe.isCollapsed {
                displayedRows.insert(contentsOf: selectedRecipe.children, at: indexPath.row+1)
                shoppingListTableView.insertRows(at: indexPaths as [IndexPath], with: .automatic)
            } else {
                displayedRows.removeSubrange(range)
                shoppingListTableView.deleteRows(at: indexPaths, with: .automatic)
            }
            
            shoppingListTableView.endUpdates()
        }
        
        //update the isCollapsed status of cell
        selectedRecipe.isCollapsed = !selectedRecipe.isCollapsed
    }
    
    //allowing editing for only an enclosing recipe cell, not an ingredient cell
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (displayedRows[indexPath.row].isDeletable == true){
            return true
        }else {
            return false
        }
    }

    
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
                
                shoppingListTableView.beginUpdates()
                
                shoppingListTableView.deleteRows(at: [indexPath], with: .fade)
                displayedRows.remove(at: indexPath.row)
                
                shoppingListTableView.endUpdates()
                shoppingListTableView.reloadData()
            }
        }
    }
}
