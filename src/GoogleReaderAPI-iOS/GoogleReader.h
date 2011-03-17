//
//  GoogleReader.h
//  A wrapper around Google Reader API
//
//  Created by Simone Carella on 3/13/11.
//  Copyright 2011 Simone Carella. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJsonParser.h"

@protocol GoogleReaderRequestDelegate

- (void)didFinishRequest;
- (void)GoogleReaderRequestDidFailWithError:(NSError *)error;
- (void)GoogleReaderRequestDidLoadJSON:(NSDictionary *)dict;
- (void)GoogleReaderRequestDidLoadFeed:(NSString *)feed;
- (void)GoogleReaderRequestReceiveBytes:(float)partial onTotal:(float)total;

@optional

- (void)GoogleReaderRequestDidAuthenticateWithUser:(NSDictionary *)userDict;
- (void)GoogleReaderRequestSendBytes:(float)partial onTotal:(float)total;

@end


@interface GoogleReader : NSObject
{
	// public delegate
	id <GoogleReaderRequestDelegate> delegate;
	
	// private
	SBJsonParser *JSON;
	NSString *auth;
	NSString *token;
	NSURLConnection *web;
	NSHTTPURLResponse *response;
	NSURLResponse *URLresponse;
	NSMutableDictionary *headerArgs;
	NSMutableDictionary *getArgs;
	NSMutableDictionary *postArgs;
	NSError *error;
	NSError *JSONerror;
	NSMutableData *responseData;
	NSData *staticResponseData;
	NSNumber *expectedResponseLength;
}
@property(nonatomic, retain) NSURLConnection *web;
@property(nonatomic, retain) NSMutableData *responseData;

// instance methods
- (id)init;
- (void)setDelegate:(id)d;

// authentication & authorization
- (BOOL)isNeedToAuth;
- (BOOL)makeLoginWithUsername:(NSString *)username password:(NSString*)passwd;

// low level api methods
- (void)getAllFeeds;
- (void)getFeedWithFeedName:(NSString *)feedName orURL:(NSString *)url excludeTarget:(NSString *)exclude;

// medium level api methods
- (void)getPreference;
- (void)getSubscriptionsList;
- (void)getTagList;
- (void)getUnreadCountList;

// high level api methods
- (void)addSubscriptionWithURL:(NSString *)url feed:(NSString *)feed labels:(NSArray *)labels;
- (void)deleteSubscribptionWithFeedName:(NSString *)feed;
- (void)getUnreadItems;
- (void)setUnread:(NSString *)entry;
- (void)setRead:(NSString *)entry;
- (void)addStar:(NSString *)entry;
- (void)deleteStar:(NSString *)entry;
- (void)addPublic:(NSString *)entry;
- (void)deletePublic:(NSString *)entry;
- (void)addLabel:(NSString *)label toEntry:(NSString *)entry;
- (void)deleteLabel:(NSString *)label toEntry:(NSString *)entry;

- (void)test;

@end
