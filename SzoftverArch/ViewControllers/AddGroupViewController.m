//
//  AddGroupViewController.m
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 22/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import "AddGroupViewController.h"
#import "NetworkManager.h"

@interface AddGroupViewController ()
@property (weak, nonatomic) IBOutlet UITextField *groupNameTF;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@end

@implementation AddGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addButtonTouched:(id)sender {
    [self addGroup];
}

- (void)addGroup {
    [NetworkManager AddGroup:self.groupNameTF.text success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"group registered");
        [self.groupDelegate getGroups];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"erro registering group %@",[error description]);
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
