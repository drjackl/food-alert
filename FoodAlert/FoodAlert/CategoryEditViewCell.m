//
//  CategoryEditViewCell.m
//  FoodAlert
//
//  Created by Jack Li on 3/21/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "CategoryEditViewCell.h"
#import "DataSource.h"

@interface CategoryEditViewCell ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@end

@implementation CategoryEditViewCell

- (void) setCategory:(Categorie*)category {
    _category = category;
    self.nameField.text = category.title;
    self.backgroundColor = category.color;
}

- (IBAction)setCategoryName:(UITextField*)sender {
    self.category.title = sender.text;
    
    [[DataSource sharedInstance] archiveCategories];
}

@end
