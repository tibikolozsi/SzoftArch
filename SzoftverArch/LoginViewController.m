//
//  ViewController.m
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 08/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import "LoginViewController.h"
#import "SzoftverArch-Swift.h"
#import "NetworkManager.h"

@interface LoginViewController ()
@property(weak, nonatomic) IBOutlet UIView* loginContainerView;
@property(weak, nonatomic)
IBOutlet NSLayoutConstraint* loginContainerBottomConstraint;
@property(nonatomic) CGFloat tempBottomConstraint;
@property(nonatomic) PieChartView* pieChart;
@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tempBottomConstraint = 234.0;
    [self registerForKeyboardNotifications];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self unregisterForKeyboardNotifications];
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIKeyboardWillShowNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSDictionary* info = [notification userInfo];
    CGSize kbSize =
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3
                     animations:^{
                         NSLog(@"%f", self.tempBottomConstraint);
                         self.loginContainerBottomConstraint.constant =
                         kbSize.height;
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3
                     animations:^{
                         NSLog(@"%f", self.tempBottomConstraint);
                         self.loginContainerBottomConstraint.constant =
                         self.tempBottomConstraint;
                         [self.view layoutIfNeeded];
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginButtonPressed:(id)sender {
    [NetworkManager LoginWithUsername: self.usernameTF.text password:self.passwordTF.text success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"login successful");
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"couldnt log you in");
        NSLog(@"error: %@",[error description]);
    }];
}

@end
