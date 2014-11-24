//
//  ContactsDetailsTableViewController.h
//  Dial4
//
//  Created by Shanshan ZHAO on 17/11/14.
//  Copyright (c) 2014 Shanshan ZHAO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>


@interface ContactsDetailsTableViewController : UITableViewController

@property (nonatomic, assign) ABRecordRef person;

@end
