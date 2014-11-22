//
//  NetworkManager.h
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 21/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "Group.h"

@interface NetworkManager : NSObject

+ (void)LoginWithUsername:(NSString *)username
                 password:(NSString *)password
                  success:(void (^)(AFHTTPRequestOperation *operation,
                                    id responseObject))success
                  failure:(void (^)(AFHTTPRequestOperation *operation,
                                    NSError *error))failure;

+ (void)RegisterWithUsername:(NSString *)username
                    password:(NSString *)password
                       email:(NSString *)email
                     group:(Group *)group
                     isAdmin:(BOOL)isAdmin
                     success:(void (^)(AFHTTPRequestOperation *operation,
                                       id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *operation,
                                       NSError *error))failure;

+ (void)DownloadGroupsWithSuccess:(void (^)(AFHTTPRequestOperation *operation,
                                            id responseObject))success
                          failure:(void (^)(AFHTTPRequestOperation *operation,
                                            NSError *error))failure;

+ (void)DownloadUsersWithGroup:(Group*)group
                       success:(void (^)(AFHTTPRequestOperation *operation,
                                         id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation,
                                         NSError *error))failure;

+ (void)AddGroup:(NSString*)groupName
         success:(void (^)(AFHTTPRequestOperation *operation,
                           id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation,
                           NSError *error))failure;


@end
