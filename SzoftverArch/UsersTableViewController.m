//
//  UsersTableViewController.m
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 21/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import "UsersTableViewController.h"
#import "NetworkManager.h"
#import "DetailViewController.h"

@interface UsersTableViewController ()

@property (nonatomic) NSMutableArray* users;
@property (nonatomic) id<DetailProtocol> detailDelegate;

@end

@implementation UsersTableViewController

- (void)setupDetailDelegate
{
    UINavigationController* detailNavController = [self.splitViewController.viewControllers lastObject];
    if ([[detailNavController topViewController] isKindOfClass:[DetailViewController class]]) {
        DetailViewController* detailVC = (DetailViewController*)[detailNavController topViewController];
        self.detailDelegate = detailVC;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self downloadUsersForGroup];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(downloadUsersForGroup) forControlEvents:UIControlEventValueChanged];
    [self setupDetailDelegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([self.users count] > 0) {
        [self removeEmptyMessage];
        // Return the number of rows in the section.
        return [self.users count];
    } else {
        // Display a message when the table is empty
        [self displayEmptyMessage];
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.users objectAtIndex:indexPath.row];
    // Configure the cell...
    return cell;
}

- (void)downloadUsersForGroup
{
    [NetworkManager DownloadUsersWithGroup:self.group
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       NSLog(@"got users: %@", responseObject);
                                       self.users = responseObject;
                                       self.users = [NSMutableArray arrayWithArray:@[@"User1", @"User2", @"User3"]];
                                       [self reloadData];
                                   } failure:^(AFHTTPRequestOperation *operation,
                                               NSError *error) {
                                       [self.refreshControl endRefreshing];
                                       NSLog(@"error retrieving users: %@",[error description]);
                                   }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* username = [self.users objectAtIndex:indexPath.row];
    NSDictionary* dictionary = @{@"groupname" : self.group.groupName,
                                 @"username" : username};
    [self.detailDelegate updateDetailWithType:DetailTypeSelectedUser dictionary:dictionary];
}

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
