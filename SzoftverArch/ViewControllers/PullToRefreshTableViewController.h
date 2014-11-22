//
//  PullToRefreshTableViewController.h
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 22/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullToRefreshTableViewController : UITableViewController

- (void)reloadData;
- (void)removeEmptyMessage;
- (void)displayEmptyMessage;

@end
