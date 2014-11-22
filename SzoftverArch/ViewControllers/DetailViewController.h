//
//  DetailViewController.h
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 21/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DetailTypeAllGroups,
    DetailTypeSelectedGroup,
    DetailTypeSelectedUser,
} DetailType;

@protocol DetailProtocol <NSObject>

- (void)updateDetailWithType:(DetailType)type dictionary:(NSDictionary*)dictionary;

@end

@interface DetailViewController : UIViewController <DetailProtocol>

@end
