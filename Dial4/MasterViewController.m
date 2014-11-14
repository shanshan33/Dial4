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
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.addressBook = ABAddressBookCreateWithOptions(NULL, NULL);

//    if (nil == self.myContacts) {
//        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
//        if ([self check]) {
//            <#statements#>
//        }
//
//        
//    }
    return 1;
}
-(BOOL)checkAddressBookAuthorizationStatus:(UITableView *) tableView
{
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    if (authStatus != kABAuthorizationStatusAuthorized) {
        ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue()
                           , ^{
                               if (error) {
                                   NSLog(@"Error: %@", (__bridge_transfer NSError *)error);
                               }
                               else if(!granted)
                               {
                                   UIAlertController * alert=   [UIAlertController
                                                                 alertControllerWithTitle:@"Authorization Denied"
                                                                 message:@"Set permissions in Setting->General -> Privacy"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
                                   
                                   UIAlertAction* ok = [UIAlertAction
                                                        actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action)
                                                        {
                                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                                            
                                                        }];
                                   UIAlertAction* cancel = [UIAlertAction
                                                            actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                                            {
                                                                [alert dismissViewControllerAnimated:YES completion:nil];
                                                                
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
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = self.objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
