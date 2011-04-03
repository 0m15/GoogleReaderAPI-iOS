//
//  GoogleReader.m
//  A wrapper around Google Reader API
//
//  Created by Simone Carella on 3/13/11.
//  Copyright 2011 Simone Carella. All rights reserved.
//

#import "Constants.h"
#import "GoogleReader.h"
#import "JSON.h"
#import "NSDictionary+URLEncoding.h"
#import "SBJsonParser.h"
#import "GDataOAuthViewControllerTouch.h"

@interface GoogleReader(PrivateAPI)
// token
- (NSString *)getToken:(BOOL)forced;

// low level private api methods
- (void)makeEditApiWithTargetEdit:(NSString *)targetEdit requestBody:(NSString *)requestBody;
- (void)makeEditApiWithTargetEdit:(NSString *)targetEdit argDictionary:(NSDictionary *)dict;

// medium level private api methods
- (void)editTag;
- (void)editSubscription:(NSString *)feed withAction:(NSString *)action add:(NSString *)add remove:(NSString *)remove title:(NSString *)title;

// get/post
- (void)getSynchronousRequestWithURL:(NSString *)url options:(NSDictionary *)dict;
- (void)getRequestWithURL:(NSString *)url options:(NSDictionary*)dict;
- (void)postRequestWithURL:(NSString *)url body:(NSString *)body contentType:(NSString *)contentType options:(NSDictionary *)dict;
- (void)postRequestWithURL:(NSString *)url postArgs:(NSDictionary *)body headerArgs:(NSDictionary *)dict;

// api proxy
- (void)makeApiCallWithURL:(NSString *)url options:(NSDictionary *)dict;


@end


@implementation GoogleReader

@synthesize responseData, web, oauthAuthentication, feedItems, requiresAuthentication;

#pragma mark -
#pragma mark initializer
- (id)init
{
	self = [super init];
	
	if (self) {
		self.web = [[NSURLConnection alloc] init];
		NSInteger timestamp = [[NSDate date] timeIntervalSince1970] * 1000 * -1;
		
		NSLog(@"---------------------- timestamp: %d", timestamp * 1000 * -1);
		
		feedItems = [[NSMutableArray alloc] init];
		
		GDataOAuthAuthentication *newAuth = [GDataOAuthAuthentication authForInstalledApp];

		requiresAuthentication = ![GDataOAuthViewControllerTouch authorizeFromKeychainForName:kAppServiceName authentication:newAuth];
		
		if (!requiresAuthentication)
		{
			self.oauthAuthentication = newAuth;
		}

		JSON = [[SBJsonParser alloc] init];
		response = [[NSHTTPURLResponse alloc] init];
		error = [[NSError alloc] init];
		self.responseData = [NSMutableData data];
		URLresponse = [[NSURLResponse alloc] init];
		headerArgs = [[NSMutableDictionary alloc] init];
		getArgs = [[NSMutableDictionary alloc] init];
		postArgs = [[NSMutableDictionary alloc] init];
		//expectedResponseLength = [[NSNumber alloc] init];
		
		[postArgs removeAllObjects];
		
		[headerArgs setValue:AGENT forKey:@"client"];
		[headerArgs setValue:[NSString stringWithFormat:@"%d", timestamp] forKey:@"ck"];
	}
	
	return self;
}

- (void)dealloc
{
	self.web = nil;
	self.responseData = nil;
	
	[feedItems release];
	[JSON release];
	[response release];
	[error release];
	[URLresponse release];
	[headerArgs release];
	[getArgs release];
	[postArgs release];
		
	[super dealloc];
}

- (void)initialize
{
}

- (void)setDelegate:(id)d
{
	<GoogleReaderRequestDelegate> newDelegate = d;
	delegate = newDelegate;
}

- (<GoogleReaderRequestDelegate>) delegate
{
	return delegate;
}

#pragma mark -
#pragma mark authentication & authorization


- (NSString*)getToken:(BOOL)forced
{
	if(forced == YES || [token isEqualToString:@""])
	{
		[self getSynchronousRequestWithURL:[NSString stringWithFormat:@"%@%@?client=%@", GOOGLE_API_PREFIX_URL, API_TOKEN, AGENT] 
												   options:nil];
		
		NSString *stringData = [[NSString alloc] initWithData:staticResponseData encoding:NSASCIIStringEncoding];
		token = [[stringData stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"//" withString:@""];
		
		NSLog(@"------- self.token: %@", token);
		
		return token;
	}
	return token;
}


#pragma mark -
#pragma mark low level api methods
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)getAllFeeds 
{
	[self getFeedWithFeedName:nil orURL:nil excludeTarget:nil];
}

- (void)getFeedWithFeedName:(NSString *)feedName orURL:(NSString *)url excludeTarget:(NSString *)exclude
{
	NSString *URLstring; 
	
	if (url != nil) 
	{
		URLstring = [NSString stringWithFormat:@"%@%@&@", GOOGLE_ATOM_URL, ATOM_GET_FEED, [url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	}
	
	if (feedName == nil) 
	{
		URLstring = [NSString stringWithFormat:@"%@%@", GOOGLE_ATOM_URL, ATOM_STATE_READING_LIST, [feedName stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];	
	} else 
	{
		URLstring = [NSString stringWithFormat:@"%@%@", GOOGLE_ATOM_URL, [feedName stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	}
	
	if (exclude != nil) 
	{
		URLstring = [URLstring stringByAppendingFormat:@"?xt=%@", exclude];
		//[getArgs setValue:exclude forKey:@"xt"];
	}
	
	
	[self getRequestWithURL:URLstring options:nil];	
}

- (void)makeApiCallWithURL:(NSString *)url options:(NSDictionary *)dict
{
	//[headerArgs setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", auth] forKey:@"Authorization"];
	
	[getArgs setValue:@"json" forKey:@"output"];
	[getArgs setValue:[self getToken:YES] forKey:@"token"];
	
	NSString *options = [getArgs URLEncodedString];
	NSString *urlString = [NSString stringWithFormat:@"%@?%@", url, options];
	
	NSLog(@">>>>>>>>>>>>>> urlString: %@", urlString);
	
	[self getRequestWithURL:urlString options:nil];
}

- (void)makeEditApiWithTargetEdit:(NSString *)targetEdit requestBody:(NSString *)requestBody
{
	
	//[headerArgs setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", auth] forKey:@"Authorization"];
	[postArgs setValue:[self getToken:YES] forKey:@"T"];
	
	NSString *urlString = [NSString stringWithFormat:@"%@%@", GOOGLE_API_PREFIX_URL, targetEdit];
	
	[self postRequestWithURL:urlString postArgs:postArgs headerArgs:headerArgs];
	

}


#pragma mark -
#pragma mark medium level api methods
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)editTag:(NSString *)feed add:(NSString *)add remove:(NSString *)remove;
{
	[postArgs setValue:ATOM_STATE_READING_LIST forKey:@"i"];
	[postArgs setValue:@"edit-tags" forKey:@"ac"];
	
	if (add != nil) 
	{
		[postArgs setValue:add forKey:@"a"];
	}
	
	if (remove != nil) 
	{
		[postArgs setValue:remove forKey:@"r"];
	}
	
	if (feed != nil) 
	{
		[postArgs setValue:feed forKey:@"i"];
	}
	
	[self makeEditApiWithTargetEdit:API_EDIT_TAG requestBody:nil];
	
}

- (void)editSubscription:(NSString *)feed withAction:(NSString *)action add:(NSString *)add remove:(NSString *)remove title:(NSString *)title;
{
	//NSString *bodyRequest = [NSString stringWithFormat:@"ac=unsubscribe"]
	NSLog(@"editSubscription: %@ - %@", feed, action);

	[postArgs setValue:@"unsubscribe" forKey:@"ac"];
	[postArgs setValue:@"null" forKey:@"s"];
	
	if (feed != nil) 
	{
		[postArgs setValue:feed forKey:@"s"];
	}
	
	if (title != nil) 
	{
		[postArgs setValue:title forKey:@"t"];
	}
	
	if (add != nil) 
	{
		[postArgs setValue:add forKey:@"a"];
	}
	
	if (remove != nil) 
	{
		[postArgs setValue:remove forKey:@"r"];
	}
	
	if (action != nil) 
	{
		[postArgs setValue:action forKey:@"ac"];
	}
	
	[self makeEditApiWithTargetEdit:API_EDIT_SUBSCRIPTIONS requestBody:nil];

}

- (void)getPreference
{
	NSString *stringURL = [NSString stringWithFormat:@"%@%@", GOOGLE_API_PREFIX_URL, API_LIST_PREFERENCES];
	[self makeApiCallWithURL:[NSURL URLWithString:stringURL] options:nil];
}

- (void)getSubscriptionsList
{
	NSString *stringURL = [NSString stringWithFormat:@"%@%@", GOOGLE_API_PREFIX_URL, API_LIST_SUBSCRIPTIONS];
	[self makeApiCallWithURL:[NSURL URLWithString:stringURL] options:nil];
}

- (void)getTagList
{
	NSString *stringURL = [NSString stringWithFormat:@"%@%@", GOOGLE_API_PREFIX_URL, API_LIST_TAG];
	[self makeApiCallWithURL:[NSURL URLWithString:stringURL] options:nil];
}

- (void)getUnreadCountList
{
	NSString *stringURL = [NSString stringWithFormat:@"%@%@", GOOGLE_API_PREFIX_URL, API_LIST_UNREAD_COUNT];
	[self makeApiCallWithURL:[NSURL URLWithString:stringURL] options:nil];
}


#pragma mark -
#pragma mark high level api methods
- (void)addSubscriptionWithURL:(NSString *)url feed:(NSString *)feed labels:(NSArray *)labels
{
	NSLog(@"--- addSubscription 1");
	
	//[headerArgs setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", auth] forKey:@"Authorization"];
	
	[postArgs setValue:@"subscribe" forKey:@"ac"];
	[postArgs setValue:[self getToken:YES] forKey:@"T"];
	[postArgs setValue:[url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] forKey:@"quickadd"];
	
	NSLog(@"--- addSubscription 2");
	
	[self postRequestWithURL:QUICK_ADD_URL postArgs:postArgs headerArgs:headerArgs];
	
	NSLog(@"--- addSubscription 3");
	
	//NSString *stringData = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
	//NSString *savedFeed;
	
	//NSLog(@"--------------------------------------------------------------\n\nresponse: %@", stringData);

	//NSDictionary *returnDict = [NSDictionary dictionaryWithDictionary:[stringData JSONValue]];

	/*if ([[returnDict objectForKey:@"streamId"] length] > 0) {
		savedFeed = [returnDict objectForKey:@"streamId"];
		
		for (NSString *l in labels) {
			[self editSubscription:savedFeed 
						withAction:@"edit" 
							   add:[NSString stringWithFormat:@"%@%@", ATOM_PREFIX_LABEL, l] 
							remove:nil 
							 title:nil];
		}
		
		return returnDict;
	}*/
	
	NSLog(@"--------- URL: %@", url);
	
}

- (void)deleteSubscribptionWithFeedName:(NSString *)feed
{	
	if (feed != nil)
	{
		[self editSubscription:feed withAction:@"unsubscribe" add:nil remove:nil title:nil];
	}
	
}

- (void)getUnreadItems
{
	[self getFeedWithFeedName:nil orURL:nil excludeTarget:ATOM_STATE_READ];
}

- (void)setRead:(NSString *)entry
{
	[self editTag:entry add:ATOM_STATE_READ remove:ATOM_STATE_UNREAD];
}

- (void)setUnread:(NSString *)entry
{
	[self editTag:entry add:ATOM_STATE_UNREAD remove:ATOM_STATE_READ];
}

- (void)addStar:(NSString *)entry
{
	[self editTag:entry add:ATOM_STATE_STARRED remove:nil];
}

- (void)deleteStar:(NSString *)entry
{
	return [self editTag:entry add:nil remove:ATOM_STATE_STARRED];
}

- (void)addPublic:(NSString *)entry
{
	return [self editTag:entry add:ATOM_STATE_BROADCAST	remove:nil];
}

- (void)deletePublic:(NSString *)entry
{
	return [self editTag:entry add:nil remove:ATOM_STATE_BROADCAST];
}

- (void)addLabel:(NSString *)label toEntry:(NSString *)entry
{
	return [self editTag:entry 
			  add:[NSString stringWithFormat:@"%@%@", ATOM_PREFIX_LABEL, label] 
		   remove:nil];
}

- (void)deleteLabel:(NSString *)label toEntry:(NSString *)entry
{
	return [self editTag:entry 
			  add:nil
		   remove:[NSString stringWithFormat:@"%@%@", ATOM_PREFIX_LABEL, label]];
}

#pragma mark -
#pragma mark private methods
- (void)getSynchronousRequestWithURL:(NSString *)url options:(NSDictionary *)dict
{
	NSURL *requestURL = [NSURL URLWithString:url];
	NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] init];
	
	[theRequest setHTTPMethod:@"GET"];
	[theRequest setTimeoutInterval:30.0];
	//[theRequest addValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", auth] forHTTPHeaderField:@"Authorization"];
	[theRequest setURL:requestURL];
	[self.oauthAuthentication authorizeRequest:theRequest];
	
	staticResponseData = [NSURLConnection sendSynchronousRequest:theRequest 
										returningResponse:&response
													error:&error];		
}

// get request
- (void)getRequestWithURL:(NSString *)url 
				  options:(NSDictionary *)dict
{
	NSURL *requestURL = [NSURL URLWithString:url];
	NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] init];
	
	[theRequest setHTTPMethod:@"GET"];
	[theRequest setTimeoutInterval:30.0];
	//[theRequest addValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", auth] forHTTPHeaderField:@"Authorization"];
	[theRequest setURL:requestURL];
	[self.oauthAuthentication authorizeRequest:theRequest];
	
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
	
	NSLog(@"-------------------------- connection: %@", conn);
	
	self.web = conn;

	[conn release];

	//NSLog(@"########## get response: %d", [response statusCode]);
	
	
	
}

// post request
- (void)postRequestWithURL:(NSString *)url 
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
	[self.oauthAuthentication authorizeRequest:theRequest];
	// make request
	//responseData = [NSURLConnection sendSynchronousRequest:theRequest 
	//									 returningResponse:&response 
	//												 error:&error];	
	
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
	self.web = conn;
	
	[conn release];
	
	NSLog(@"########## REQUEST URL: %@", url);
	
	
	
	
	// request and response sending and returning objects
}

- (void)postRequestWithURL:(NSString *)url 
				  postArgs:(NSDictionary *)body 
				headerArgs:(NSDictionary *)dict
{
	NSString *bodyRequest = [body URLEncodedString];
	NSURL *requestURL = [NSURL URLWithString:url];
	NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] init];
	
	NSLog(@"-------------- bodyRequest: %@", bodyRequest);
	
	if([dict count] > 0)
	{
		for (id key in dict) {
			NSLog(@"[theRequest addValue:%@ forHTTPHeaderField:%@]", [dict valueForKey:key], key);
			[theRequest addValue:[dict valueForKey:key] forHTTPHeaderField:key];
		}
	}
	
	[theRequest setURL:requestURL];
	[theRequest setTimeoutInterval:30.0];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody:[bodyRequest dataUsingEncoding:NSASCIIStringEncoding]];
	[self.oauthAuthentication authorizeRequest:theRequest];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
	self.web = conn;
	
	[conn release];
	
}

# pragma mark -
# pragma mark NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
	NSLog(@"------------------------------- connectionDidReceiveResponse");
	expectedResponseLength = [NSNumber numberWithFloat:[aResponse expectedContentLength]];
	URLresponse = aResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{	
	NSLog(@"------------------------------- connectionDidReceiveData: %@", data);
	//float l = [responseData length];
	//[delegate GoogleReaderRequestReceiveBytes:l onTotal:[expectedResponseLength floatValue]];
	
	[self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
{
	NSLog(@"------------------------------- connectionDidSendBodyData: %d", totalBytesWritten);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)theError
{
	NSLog(@"------------------------------- connectionDidFailWithError: %@", [theError localizedDescription]);
	
	self.responseData = nil;
	
	[delegate GoogleReaderRequestDidFailWithError:theError];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"------------------------------- connectionDidFinishLoading: %d", [responseData length]);
	
	MWFeedParser *parser = [[MWFeedParser alloc] initWithData:responseData];
	parser.delegate = self;
	[parser parse];
	
#if 0
	// check if data is JSON parsable
	NSString *JSONString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSError *jsonerr = nil;
	NSDictionary *JSONdict = [JSON objectWithString:JSONString error:&jsonerr];
	
	if (!jsonerr) {
		[delegate GoogleReaderRequestDidLoadJSON:JSONdict];
	}
#endif
	
	//NSLog(@"responseData: %@", JSONString);
	self.responseData = nil;
	//response = nil;
	//error = nil;
	//expectedResponseLength = nil;
	self.web = nil;
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"%@", info);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item
{
	[feedItems addObject:item];
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"%@", item);
}

- (void)feedParserDidFinish:(MWFeedParser *)parser
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	if (delegate && [delegate respondsToSelector:@selector(didFinishRequest)])
	{
		[delegate performSelector:@selector(didFinishRequest)];
	}
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)err
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"%@", err);
}
@end
