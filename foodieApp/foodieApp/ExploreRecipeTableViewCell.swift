//
//  ExploreRecipeTableViewCell.swift
//  foodieApp
//
//  Created by Mr. Lopez on 2/26/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

import UIKit

class ExploreRecipeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeLabel: UILabel!
    @IBOutlet weak var recipeLikeButton: UIButton!
    @IBOutlet weak var recipeAddButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
