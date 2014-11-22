//
//  GroupsTableViewController.m
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 21/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import "GroupsTableViewController.h"
#import "NetworkManager.h"
#import "UsersTableViewController.h"
#import "AddGroupViewController.h"
#import "DetailViewController.h"

@interface GroupsTableViewController ()

@property (nonatomic) NSMutableArray* groups;
@property (nonatomic) id<DetailProtocol> detailDelegate;
@property (nonatomic) UIRefreshControl* refreshControl;
@end

@implementation GroupsTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getGroups];
}

- (void)setupDetailDelegate
{
    UINavigationController* detailNavController = [self.splitViewController.viewControllers lastObject];
    if ([[detailNavController topViewController] isKindOfClass:[DetailViewController class]]) {
        DetailViewController* detailVC = (DetailViewController*)[detailNavController topViewController];
        self.detailDelegate = detailVC;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(getGroups) forControlEvents:UIControlEventValueChanged];
    [self setupDetailDelegate];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)getGroups
{
    [NetworkManager DownloadGroupsWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"got groups: %@",responseObject);
        self.groups = [NSMutableArray array];
        for (id obj in responseObject) {
            Group* group = [[Group alloc] initWithJson:obj];
            [self.groups addObject:group];
        }
        [self reloadData];
        [self.detailDelegate updateDetailWithType:DetailTypeAllGroups dictionary:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        NSLog(@"failed : %@",[error description]);
    }];
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
    if ([self.groups count] > 0) {
        [self removeEmptyMessage];
        // Return the number of rows in the section.
        return [self.groups count];
    } else {
        // Display a message when the table is empty
        [self displayEmptyMessage];
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell" forIndexPath:indexPath];
    Group* group = [self.groups objectAtIndex:indexPath.row];
    cell.textLabel.text = group.groupName;
//     Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"GoToUsersSegue" sender:self];
    Group* selectedGroup = [self.groups objectAtIndex:indexPath.row];
    NSDictionary* dictionary = @{@"groupname" : selectedGroup.groupName};
    [self.detailDelegate updateDetailWithType:DetailTypeSelectedGroup dictionary:dictionary];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"GoToUsersSegue"]) {
        NSLog(@"thats it");
        if ([segue.destinationViewController isKindOfClass:[UsersTableViewController class]]) {
            UsersTableViewController* utvc = (UsersTableViewController*)segue.destinationViewController;
            NSUInteger selectedIndex = [self.tableView indexPathForSelectedRow].row;
            utvc.group = [self.groups objectAtIndex:selectedIndex];
        }
    } else if ([segue.identifier isEqualToString:@"AddGroupSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[AddGroupViewController class]]) {
            AddGroupViewController* agvc = (AddGroupViewController*)segue.destinationViewController;
            agvc.groupDelegate = self;
        }
    }
}


@end
