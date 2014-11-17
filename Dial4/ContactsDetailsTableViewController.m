//
//  ContactsDetailsTableViewController.m
//  Dial4
//
//  Created by Shanshan ZHAO on 17/11/14.
//  Copyright (c) 2014 Shanshan ZHAO. All rights reserved.
//

#import "ContactsDetailsTableViewController.h"
#import <AddressBook/AddressBook.h>

@interface ContactsDetailsTableViewController ()

@property (nonatomic, assign) ABRecordRef person;
@end

@implementation ContactsDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(self.person, kABPersonPhoneProperty);
    
    // add 2 for names
    int retNum = (int)ABMultiValueGetCount(phoneNumbers) +2 ;
    return retNum;
}

-(void)callThisNumber:(NSString *)number
{
    NSString * url = [NSString stringWithFormat:@"tel:%@",number];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                      reuseIdentifier:@"DetailCell"];
    }
    
    if (indexPath.row < 2) // names
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    
    NSString * title ;
    NSString * text;
    
    switch (indexPath.row) {
        case 0:
            title = @"First Name";
            text = (__bridge_transfer NSString *)ABRecordCopyValue(self.person, kABPersonFirstNamePhoneticProperty);
            break;
        case 1:
            title = @"Last Name";
            text = (__bridge_transfer NSString *)ABRecordCopyValue(self.person, kABPersonLastNamePhoneticProperty);
            break;
        default:
            title = @"Phone";
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(self.person, kABPersonPhoneProperty);
            if (phoneNumbers && ABMultiValueGetCount(phoneNumbers) > 0 ) {
                text = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, indexPath.row - 2);
                
                CFRelease(phoneNumbers);
            }
            break;
    }
    
    [cell.textLabel setText: title];
    [cell.detailTextLabel setText:text];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 1) {
        [self callThisNumber:[[[tableView cellForRowAtIndexPath:indexPath] detailTextLabel] text]];
    }
    
}

@end
