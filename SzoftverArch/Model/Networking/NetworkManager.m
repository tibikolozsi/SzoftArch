//
//  NetworkManager.m
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 21/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import "NetworkManager.h"

static const NSString *kMainUrl = @"http://tippjatek-onnlab.appspot.com";

@implementation NetworkManager

+ (void)LoginWithUsername:(NSString *)username
                 password:(NSString *)password
                  success:(void (^)(AFHTTPRequestOperation *, id))success
                  failure:(void (^)(AFHTTPRequestOperation *,
                                    NSError *))failure {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    NSString *loginURL = [NSString stringWithFormat:@"%@/sz_login", kMainUrl];
    NSDictionary *parameters = @{
                                 @"username" : username,
                                 @"password" : password
                                 };
    
    [manager GET:loginURL parameters:parameters success:success failure:failure];
}

+ (void)RegisterWithUsername:(NSString *)username
                    password:(NSString *)password
                       email:(NSString *)email
                     group:(Group *)group
                     isAdmin:(BOOL)isAdmin
                     success:(void (^)(AFHTTPRequestOperation *, id))success
                     failure:(void (^)(AFHTTPRequestOperation *,
                                       NSError *))failure {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    manager.responseSerializer = responseSerializer;
    NSString *registerURL =
    [NSString stringWithFormat:@"%@/sz_registration", kMainUrl];
    NSDictionary *parameters = @{
                                 @"username" : username,
                                 @"password" : password,
                                 @"email" : email,
                                 @"groupID" : [NSString stringWithFormat:@"%d",group.groupID],
                                 @"isAdmin" : (isAdmin ? @"true" : @"false")
                                 };
    
    NSLog(@"parameters: %@",parameters);
    [manager POST:registerURL
       parameters:parameters
          success:success
          failure:failure];
}

+ (void)DownloadGroupsWithSuccess:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    NSString *downloadGroupsURL = [NSString stringWithFormat:@"%@/sz_GetData", kMainUrl];
    NSDictionary *parameters = @{ @"data" : @"groups" };
    
    [manager GET:downloadGroupsURL parameters:parameters success:success failure:failure];
}

+ (void)DownloadUsersWithGroup:(Group*)group
                       success:(void (^)(AFHTTPRequestOperation *operation,
                                         id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation,
                                         NSError *error))failure
{
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    NSString *downloadGroupUsersURL = [NSString stringWithFormat:@"%@/sz_GetData", kMainUrl];
    NSDictionary *parameters = @{ @"data" : @"group",
                                  @"parameter" : @"users",
                                  @"groupID" : [NSString stringWithFormat:@"%d",group.groupID]};
    
    [manager GET:downloadGroupUsersURL parameters:parameters success:success failure:failure];
}

+ (void)AddGroup:(NSString*)groupName
         success:(void (^)(AFHTTPRequestOperation *operation,
                           id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation,
                           NSError *error))failure
{
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    NSString *addGroupURL = [NSString stringWithFormat:@"%@/sz_RegisterGroup", kMainUrl];
    NSDictionary *parameters = @{ @"groupname" : groupName};
    
    [manager POST:addGroupURL parameters:parameters success:success failure:failure];
}

@end
