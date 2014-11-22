//
//  UsersTableViewController.h
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 21/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"
#import "Group.h"

@interface UsersTableViewController : PullToRefreshTableViewController

@property (nonatomic) Group* group;

@end
