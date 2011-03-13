//
//  GoogleReader.m
//  lastread
//
//  Created by Simone on 3/13/11.
//  Copyright 2011 Self-employed. All rights reserved.
//

#import "GoogleReader.h"
#import "Constants.h"

@interface GoogleReader(PrivateAPI)

// token
+ (NSString *)getToken:(BOOL)forced;

// get/post
+ (void)getRequestWithURL:(NSString *)url options:(NSDictionary*)dict;
+ (void)postRequestWithURL:(NSString *)url body:(NSString *)body contentType:(NSString *)contentType options:(NSDictionary *)dict;

// api proxy
+ (NSString *)makeApiCallWithURL:(NSString *)url options:(NSDictionary *)dict;

@end


@implementation GoogleReader

static NSString *auth = @"";
static NSString *token = @"";
static NSHTTPURLResponse *response;
static NSMutableDictionary *requestArgs;
static NSError *error;
static NSData *responseData;

#pragma mark -
#pragma mark initializer

+ (void)initialize
{
	response = [[NSHTTPURLResponse alloc] init];
	error = [[NSError alloc] init];
	responseData = [[NSData alloc] init];
	requestArgs = [[NSMutableDictionary alloc] init];
	
	[requestArgs setValue:AGENT forKey:@"client"];
	
	NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
	if ([userdef objectForKey:GOOGLE_TOKEN_KEY]) {
		auth = [userdef objectForKey:GOOGLE_TOKEN_KEY];
	}
	
}


#pragma mark -
#pragma mark authentication

+ (BOOL)isNeedToAuth
{
	return ((auth.length > 0) == NO);
}

+ (BOOL)makeLoginWithUsername:(NSString *)username password:(NSString*)passwd
{
	
	NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
	
	if ([username isEqualToString:@""] || [passwd isEqualToString:@""]) 
	{
		NSLog(@"GoogleReader -makeLogin error: please set username and password");
		return NO;
	}
	
	int statusCode = 0;
	NSString *responseString = nil;
	NSString *bodyRequest = [NSString stringWithFormat:@"Email=%@&Passwd=%@&service=reader&accountType=GOOGLE&source=lastread-ipad-reader",
							 username, passwd];
	
	[self postRequestWithURL:GOOGLE_CLIENT_AUTH_URL 
						body:bodyRequest 
				 contentType:@"application/x-www-form-urlencoded" 
					 options:nil];
	
	if([responseData length] > 0)
	{
		responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
		statusCode = [response statusCode];
		
		if(statusCode == 200)
		{	
			// 200 OK
			NSLog(@"GoogleReader.m: -makeLogin OK: %d - %@", statusCode, responseString);
			
			if([responseString rangeOfString:@"SID="].length > 0)
			{
				// set the Auth token
				auth = [[[responseString componentsSeparatedByString:@"\n"] objectAtIndex:2] stringByReplacingOccurrencesOfString:@"Auth=" withString:@""];
				[userdef setObject:auth forKey:GOOGLE_TOKEN_KEY];
				
				return YES;
				
			}
			
		} 
		else 
		{
			NSLog(@"GoogleReader.m: -makeLogin statusCode: %d - %@", statusCode, error);
			return NO;
		}

	}
	return NO;
}

// get the token
// token is like Auth, but it expires quickly
+ (NSString*)getToken:(BOOL)forced
{
	if(forced == YES || [token isEqualToString:@""])
	{
		[self getRequestWithURL:[NSString stringWithFormat:@"%@%@?client=%@", GOOGLE_API_PREFIX_URL, API_TOKEN, AGENT] 
												   options:nil];
		
		NSString *stringData = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
		token = [[stringData stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"//" withString:@""];
		
		NSLog(@"------- self.token: %@", token);
		
		return token;
		
	}
	return token;
}


#pragma mark -
#pragma mark low level api methods

+ (NSObject *)getAllFeeds 
{
	return [self getFeedWithFeedName:nil orURL:nil];
}

+ (NSObject*)getFeedWithFeedName:(NSString *)feedName orURL:(NSString *)url
{
	
	NSString *URLstring; 
	
	if (url != nil) 
	{
		URLstring = [NSString stringWithFormat:@"%@%@&@", GOOGLE_ATOM_URL, ATOM_GET_FEED, [url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	}
	
	if (feedName == nil) 
	{
		URLstring = [NSString stringWithFormat:@"%@%@", GOOGLE_ATOM_URL, ATOM_STATE_READING_LIST, [feedName stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];	
	} else {
		URLstring = [NSString stringWithFormat:@"%@%@", GOOGLE_ATOM_URL, [feedName stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	}
	
	[self getRequestWithURL:URLstring options:nil];					   
	
	NSString *stringData = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
	
	//NSLog(@"========= urlString: %@", URLstring);	
	NSLog(@"========= response: %@", stringData);
	
	return nil;
}

+ (NSString *)makeApiCallWithURL:(NSString *)url options:(NSDictionary *)dict
{
	
	NSString *options;
	
	// TODO: Add SBSJSONParser to library and parse json
	options = [NSString stringWithFormat:@"client=%@&output=json", AGENT];
	
	for (id key in dict) {
		options = [options stringByAppendingFormat:[NSString stringWithFormat:@"&%@=%@", key, [[dict objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
		
	}
	
	NSString *urlString = [NSString stringWithFormat:@"%@?%@", url, options];
	NSLog(@">>>>>>>>>>>>>> urlString: %@", urlString);
	
	[self getRequestWithURL:urlString options:nil];
	NSString *stringData = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
	
	NSLog(@"========== response: %@", stringData);
	
	return nil;
}

+ (NSString*)makeEditApiWithTargetEdit:(NSString *)targetEdit argDictionary:(NSDictionary *)dict
{
	
	NSString *bodyRequest;
	bodyRequest = [NSString stringWithFormat:@"client=%@&token=%@", AGENT, [self getToken:YES]];
	
	for (id key in dict) {
		bodyRequest = [bodyRequest stringByAppendingFormat:[NSString stringWithFormat:@"&%@=%@", key, [[dict objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
	}
	
	NSString *urlString = [NSString stringWithFormat:@"%@%@", GOOGLE_API_PREFIX_URL, targetEdit];
	
	[requestArgs setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", auth] forKey:@"Authorization"];
	
	
	[self postRequestWithURL:urlString 
						body:bodyRequest 
				 contentType:nil 
					 options:requestArgs];
	
	NSLog(@"---------- bodyRequest: %@", bodyRequest);
	NSLog(@"---------- URLString: %@", urlString);
	
	NSString *stringData = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
	
	NSLog(@"========== response: %@", stringData);
	
	
	return nil;
}


#pragma mark -
#pragma mark medium level api methods

+ (NSString *)editTag
{
	[requestArgs setValue:ATOM_STATE_READING_LIST forKey:@"i"];
	[requestArgs setValue:@"edit-tags" forKey:@"ac"];
	
	[self makeEditApiWithTargetEdit:API_EDIT_TAG argDictionary:requestArgs];
	
	return nil;
}

+ (NSString *)editSubscription
{
	[requestArgs setValue:@"edit" forKey:@"ac"];
	[requestArgs setValue:@"null" forKey:@"item"];
	[self makeEditApiWithTargetEdit:API_EDIT_SUBSCRIPTIONS argDictionary:requestArgs];
}

+ (NSString *)getPreference
{
	return nil;
}

+ (NSString *)getSubscriptionsList
{
	NSString *stringURL = [NSString stringWithFormat:@"%@%@", GOOGLE_API_PREFIX_URL, API_LIST_SUBSCRIPTIONS];
	//NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:AGENT,@"client",nil];
	return [self makeApiCallWithURL:[NSURL URLWithString:stringURL] options:nil];
}

+ (NSString *)getTagList
{
	NSString *stringURL = [NSString stringWithFormat:@"%@%@", GOOGLE_API_PREFIX_URL, API_LIST_TAG];
	//NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:AGENT,@"client",nil];
	return [self makeApiCallWithURL:[NSURL URLWithString:stringURL] options:nil];
}

+ (NSString *)getUnreadCountList
{
	NSString *stringURL = [NSString stringWithFormat:@"%@%@", GOOGLE_API_PREFIX_URL, API_LIST_UNREAD_COUNT];
	//NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:AGENT,@"client",nil];
	return [self makeApiCallWithURL:[NSURL URLWithString:stringURL] options:nil];
}

#pragma mark -
#pragma mark high level api methods
+ (NSString *)addSubscriptionWithURL:(NSString *)url feed:(NSString *)feed labels:(NSArray *)labels
{
	//[requestArgs setValue:[url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] forKey:@"quickadd"];
	//[requestArgs setValue:[self getToken:YES] forKey:@"T"];
	[requestArgs setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", auth] forKey:@"Authorization"];
	
	NSString *bodyRequest = [NSString stringWithFormat:@"ac=subscribe&T=%@&quickadd=%@", [self getToken:YES], [url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	
	for (id key in requestArgs) {
		//bodyRequest = [bodyRequest stringByAppendingFormat:[NSString stringWithFormat:@"&%@=%@", key, [[requestArgs objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
	}
	
	[self postRequestWithURL:QUICK_ADD_URL
						body:bodyRequest
				 contentType:nil
					 options:requestArgs];
	
	NSString *stringData = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
	
	NSLog(@"========== response: %@", stringData);

	return nil;
	
}

#pragma mark -
#pragma mark private methods
// get request
+ (void)getRequestWithURL:(NSString *)url 
						options:(NSDictionary *)dict
{
	NSURL *requestURL = [NSURL URLWithString:url];
	NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] init];
	
	[theRequest setHTTPMethod:@"GET"];
	[theRequest setTimeoutInterval:30.0];
	[theRequest addValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", auth] forHTTPHeaderField:@"Authorization"];
	[theRequest setURL:requestURL];
	
	responseData = [NSURLConnection sendSynchronousRequest:theRequest 
										 returningResponse:&response 
													 error:&error];
	NSLog(@"########## get response: %d", [response statusCode]);
	
}

// post request
+ (void)postRequestWithURL:(NSString *)url 
							body:(NSString *)body 
					 contentType:(NSString *)contentType 
						 options:(NSDictionary *)dict
{
	// set request
	NSURL *requestURL = [NSURL URLWithString:url];
	NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] init];

	
	if([dict count] > 0)
	{
		for (id key in dict) {
			NSLog(@"[theRequest addValue:%@ forHTTPHeaderField:%@]", [dict valueForKey:key], key);
			[theRequest addValue:[dict valueForKey:key] forHTTPHeaderField:key];
		}
	}
	
	if (contentType != nil) {
		[theRequest addValue:contentType forHTTPHeaderField:@"Content-type"];
	}
	
	[theRequest setURL:requestURL];
	[theRequest setTimeoutInterval:30.0];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];
	
	// make request
	responseData = [NSURLConnection sendSynchronousRequest:theRequest 
										 returningResponse:&response 
													 error:&error];	
	
	NSLog(@"######### POST response: %d", [response statusCode]);
	
	// request and response sending and returning objects
}

@end
