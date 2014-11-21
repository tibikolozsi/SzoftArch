//
//  Group.m
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 21/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import "Group.h"

@implementation Group

- (id)initWithJson:(NSDictionary *)json
{
    self = [super init];
    if (self) {
        self.groupName = [json objectForKey:@"name"];
        self.groupID = [[json objectForKey:@"id"] integerValue];
    }
    return self;
}

@end
