//
//  Data.h
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 22/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Data : NSObject

@property (nonatomic) float value;
@property (nonatomic) NSString* text;

- (id)initWithValue:(float)value text:(NSString*)text;

@end
