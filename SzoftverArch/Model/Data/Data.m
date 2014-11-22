//
//  Data.m
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 22/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import "Data.h"

@implementation Data

- (id)initWithValue:(float)value text:(NSString*)text
{
    self = [super init];
    if (self) {
        self.value = value;
        self.text = text;
    }
    return self;
}

@end
