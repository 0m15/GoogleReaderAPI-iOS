//
//  GoogleReader.h
//  A wrapper around Google Reader API
//
//  Created by Simone Carella on 3/13/11.
//  Copyright 2011 Simone Carella. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJsonParser.h"
#import "GDataOAuthAuthentication.h"
#import "MWFeedParser.h"

#define kAppServiceName @"Google Reader App"

@protocol GoogleReaderRequestDelegate<NSObject>

- (void)didFinishRequest;
- (void)GoogleReaderRequestDidFailWithError:(NSError *)error;
- (void)GoogleReaderRequestDidLoadJSON:(NSDictionary *)dict;
- (void)GoogleReaderRequestDidLoadFeed:(NSString *)feed;
- (void)GoogleReaderRequestReceiveBytes:(float)partial onTotal:(float)total;

@optional

- (void)GoogleReaderRequestDidAuthenticateWithUser:(NSDictionary *)userDict;
- (void)GoogleReaderRequestSendBytes:(float)partial onTotal:(float)total;

@end


@interface GoogleReader : NSObject <MWFeedParserDelegate>
{
	// public delegate
	id <GoogleReaderRequestDelegate> delegate;
	
	// private
	NSString *token;
	SBJsonParser *JSON;
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
	GDataOAuthAuthentication *oauthAuthentication;
	
	NSMutableArray *feedItems;
	
	BOOL requiresAuthentication;
}
@property(nonatomic, retain) NSURLConnection *web;
@property(nonatomic, retain) NSMutableData *responseData;
@property(nonatomic, retain) GDataOAuthAuthentication *oauthAuthentication;
@property(nonatomic, readonly) NSArray *feedItems;
@property(readonly) BOOL requiresAuthentication;

// instance methods
- (id)init;
- (void)setDelegate:(id)d;

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

@end
