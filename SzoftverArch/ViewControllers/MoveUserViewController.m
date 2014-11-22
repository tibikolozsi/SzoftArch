//
//  MoveUserViewController.m
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 22/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import "MoveUserViewController.h"
#import "Group.h"
#import "NetworkManager.h"


@interface MoveUserViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *groupsPickerView;
@property (weak, nonatomic) IBOutlet UIButton *moveButton;

@property (nonatomic) NSMutableArray* groups;
@end

@implementation MoveUserViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self downloadGroups];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.groupsPickerView.delegate = self;
    self.groupsPickerView.dataSource = self;
    
    // Do any additional setup after loading the view.
}
- (IBAction)moveButtonTouched:(id)sender {
    [self moveUserToSelectedGroup];
}

- (void)moveUserToSelectedGroup
{
    
}

- (void)downloadGroups
{
    [NetworkManager DownloadGroupsWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.groups = [NSMutableArray array];
        for (id obj in responseObject) {
            [self.groups addObject:[[Group alloc] initWithJson:obj]];
        }
        
        [self.groupsPickerView reloadAllComponents];
        NSLog(@"here comes the groups");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error retrieving groups: %@",[error description]);
    }];
}

#pragma mark - UIPickerView delegate & data source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.groups count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Group* currentGroup = [self.groups objectAtIndex:row];
    return currentGroup.groupName;
}


@end
