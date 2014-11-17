//
//  MasterViewController.m
//  Dial4
//
//  Created by Shanshan ZHAO on 11/11/14.
//  Copyright (c) 2014 Shanshan ZHAO. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <AddressBook/AddressBook.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIViewController.h>


@interface MasterViewController ()

@property NSMutableArray *objects;

@property (nonatomic,strong) NSArray * myContacts;
@property (nonatomic) ABAddressBookRef addressBook;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Dial4"];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self doCallDisplayButton:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segues

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([[segue identifier] isEqualToString:@"showDetail"])
//    {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSDate *object = self.objects[indexPath.row];
//        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
//        [controller setDetailItem:object];
//        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//        controller.navigationItem.leftItemsSupplementBackButton = YES;
//    }
//}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.addressBook = ABAddressBookCreateWithOptions(NULL, NULL);

    if (nil == self.myContacts)
    {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        if ([self checkAddressBookAuthorizationStatus:tableView])
        {
            self.myContacts = [NSArray arrayWithArray:(__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook)];
        }
    }
    
    return 1;
}

// check the authorazation to access data
-(BOOL)checkAddressBookAuthorizationStatus:(UITableView *) tableView
{
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    
    //check the current authorization
    if (authStatus != kABAuthorizationStatusAuthorized)
    {
        ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue()
                           , ^{
                               if (error)
                               {
                                   NSLog(@"Error: %@", (__bridge_transfer NSError *)error);
                               }
                               else if(!granted)
                               {
                                   //alertView replace by UIAlertController
                                   UIAlertController * alert=   [UIAlertController
                                                                 alertControllerWithTitle:@"Authorization Denied"
                                                                 message:@"Set permissions in Setting->General -> Privacy"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
                                   

                                   
                                   UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK"
                                                                                 style:UIAlertActionStyleDefault
                                                                               handler:^(UIAlertAction *action) {
                                                                                   [alert dismissViewControllerAnimated:YES
                                                                                                             completion:nil];
                                                                               }];
                                   UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                                                    style:UIAlertActionStyleDefault
                                                                                  handler:^(UIAlertAction * action) {
                                                                                    [alert dismissViewControllerAnimated:YES
                                                                                                              completion:nil];
                                                                
                                                                                }];
                                   
                                   [alert addAction:ok];
                                   [alert addAction:cancel];
                                   
                                   [self presentViewController:alert animated:YES completion:nil];
                               }
                               
                               else
                               {
                                   ABAddressBookRevert(self.addressBook);
                                   self.myContacts = [NSArray arrayWithArray:(__bridge_transfer NSArray*) ABAddressBookCopyArrayOfAllPeople(self.addressBook)];
                                   [tableView reloadData];
                               }
                           });
        });
    }
    return authStatus == kABAuthorizationStatusAuthorized;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.myContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //default cell
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//
//    NSDate *object = self.objects[indexPath.row];
//    cell.textLabel.text = [object description];
//    return cell;
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }

        NSData * data = (__bridge_transfer NSData *) ABPersonCopyImageData((__bridge ABRecordRef)[self.myContacts objectAtIndex:indexPath.row]);
    if (data != nil) {
        UIImage * image = [UIImage imageWithData:data];
        [[cell imageView] setImage:image];
    }
    else
    {
        [[cell imageView] setImage:nil];
    }
    
    cell.textLabel.text = [self personDisplayText:(__bridge ABRecordRef)([self.myContacts objectAtIndex:indexPath.row])];
    return cell;
}

-( NSString *)personDisplayText:(ABRecordRef)person
{
    NSString * firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString * lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    NSString * fullName = nil;
    
    // when first name or last name exist
    if (firstName || lastName)
    {
        if (ABPersonGetCompositeNameFormatForRecord(person) == kABPersonCompositeNameFormatFirstNameFirst)
        {
            fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
        }
        else
        {
            fullName = [NSString stringWithFormat:@"%@ %@", lastName,firstName];
        }
    }
    else
    {
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        if (phoneNumbers && ABMultiValueGetCount(phoneNumbers) > 0 )
        {
            fullName = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
            CFRelease(phoneNumbers);
        }
    }
    
    return fullName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self handleRowSelection:indexPath];
}


-(void)callThisNumber:(NSString *)phoneNumber
{
    NSString * url = [NSString stringWithFormat:@"tel:%@", phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

-(void)handleRowSelection:(NSIndexPath *)indexPath
{
    ABRecordRef person = (__bridge ABRecordRef)([self.myContacts objectAtIndex:indexPath.row]);
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    if (ABMultiValueGetCount(phoneNumbers) == 1) {
        [self callThisNumber:(__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, 0)];
    }
    else if (ABMultiValueGetCount(phoneNumbers) > 1)
    {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Pick up a Number "
                                                             message:@"Which number could you like to call ? "
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:nil];
        for (int i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
            [alertView addButtonWithTitle:(__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i)];
        }
        if (phoneNumbers) {
            CFRelease(phoneNumbers);
        }
        
        [alertView show];
    
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > 0) {
        [self callThisNumber:[alertView buttonTitleAtIndex:buttonIndex]];
    }
}

-(void)doCallDisplayButton:(id)sender
{
    NSString * buttonTitle = @"Display";
    if (sender != nil && [[sender title] compare:@"Display" ] == NSOrderedSame) {
        buttonTitle = @"Call";
    }
    
    UIBarButtonItem * bbi = [[UIBarButtonItem alloc] initWithTitle:buttonTitle
                                                             style:UIBarButtonItemStylePlain target:self action:@selector(doCallDisplayButton:)];
    self.navigationItem.leftBarButtonItem = bbi;
}


@end
