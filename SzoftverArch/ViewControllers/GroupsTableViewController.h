//
//  GroupsTableViewController.h
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 21/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"

@protocol GroupDelegate <NSObject>
- (void)getGroups;
@end

@interface GroupsTableViewController : PullToRefreshTableViewController <GroupDelegate>

@end

