//
//  MasterViewController.h
//  Dial4
//
//  Created by Shanshan ZHAO on 11/11/14.
//  Copyright (c) 2014 Shanshan ZHAO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController<UISearchBarDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;


@end

