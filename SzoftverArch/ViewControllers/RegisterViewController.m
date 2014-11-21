//
//  RegisterViewController.m
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 21/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import "RegisterViewController.h"
#import "NetworkManager.h"
#import "Group.h"

@interface RegisterViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UIPickerView *groupPicker;
@property (weak, nonatomic) IBOutlet UISwitch *adminSwitch;
@property (nonatomic) NSMutableArray* groups;

@end

@implementation RegisterViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self downloadGroups];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.groupPicker.dataSource = self;
    self.groupPicker.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerButtonPressed:(id)sender {
    NSInteger selected = [self.groupPicker selectedRowInComponent:0];
    NSLog(@"selected: %d",selected);
    Group* group = [self.groups objectAtIndex:selected];
    
    [NetworkManager RegisterWithUsername:self.usernameTF.text
                                password:self.passwordTF.text
                                   email:self.emailTF.text
                                 group:group
                                 isAdmin:self.adminSwitch.isOn
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     NSLog(@"Register successful : %@",responseObject);
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     NSLog(@"failure while registering: %@",[error description]);
                                 }];
}


- (void)downloadGroups
{
    [NetworkManager DownloadGroupsWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.groups = [NSMutableArray array];
        for (id obj in responseObject) {
            [self.groups addObject:[[Group alloc] initWithJson:obj]];
        }

        [self.groupPicker reloadAllComponents];
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
