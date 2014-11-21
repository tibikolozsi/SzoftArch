//
//  Group.h
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 21/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject
@property (nonatomic) NSString* groupName;
@property (nonatomic) NSInteger groupID;

-(id)initWithJson:(NSDictionary*)json;

@end
