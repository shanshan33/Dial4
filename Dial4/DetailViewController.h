//
//  DetailViewController.h
//  Dial4
//
//  Created by Shanshan ZHAO on 11/11/14.
//  Copyright (c) 2014 Shanshan ZHAO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

