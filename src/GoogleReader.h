//
//  GoogleReader.h
//  A wrapper around Google Reader API
//
//  Created by Simone Carella on 3/13/11.
//  Copyright 2011 Simone Carella. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleReader : NSObject {}

// class methods

// initialize
+ (void)initialize;

// login
+ (BOOL)isNeedToAuth;
+ (BOOL)makeLoginWithUsername:(NSString *)username password:(NSString*)passwd;

// low level api methods
+ (NSObject*)getAllFeeds;
+ (NSObject*)getFeedWithFeedName:(NSString *)feedName orURL:(NSString *)url;
+ (NSString*)makeEditApiWithTargetEdit:(NSString *)targetEdit argDictionary:(NSDictionary *)dict;

// medium level api methods
+ (NSString *)getSubscribptionList;
+ (NSString *)getTagList;
+ (NSString *)getUnreadCountList;

@end
