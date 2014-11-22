//
//  AddGroupViewController.h
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 22/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupsTableViewController.h"

@interface AddGroupViewController : UIViewController

@property (nonatomic) id<GroupDelegate> groupDelegate;

@end
