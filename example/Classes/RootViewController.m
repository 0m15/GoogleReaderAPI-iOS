//
//  RootViewController.m
//  example
//
//  Created by Aaron Brethorst on 4/2/11.
//  Copyright 2011 Structlab LLC. All rights reserved.
//

#import "RootViewController.h"
#import "GDataOAuthViewControllerTouch.h"

@interface RootViewController ()
- (void)loadSubscriptions;
@end


@implementation RootViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	reader = [[GoogleReader alloc] init];
	[reader setDelegate:self];
	
	if (reader.requiresAuthentication)
	{
		NSString *scope = @"http://www.google.com/reader/api http://www.google.com/reader/atom";
		GDataOAuthViewControllerTouch *viewController = [[[GDataOAuthViewControllerTouch alloc] initWithScope:scope
																									 language:nil
																							   appServiceName:kAppServiceName
																									 delegate:self
																							 finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];
		[[self navigationController] pushViewController:viewController animated:YES];
	}
	else
	{
		[reader getUnreadItems];
	}
}

- (void)viewController:(GDataOAuthViewControllerTouch *)viewController
	  finishedWithAuth:(GDataOAuthAuthentication *)auth
				 error:(NSError *)error {
	if (error != nil)
	{
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Sign-in failed" message:@"FAILED!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[alert show];
	}
	else
	{
		reader.oauthAuthentication = auth;
		[reader getUnreadItems];
	}
}

#pragma mark -
#pragma mark GoogleReaderRequestDelegate

- (void)didFinishRequest
{
	[self.tableView reloadData];
}

- (void)GoogleReaderRequestDidFailWithError:(NSError *)error
{
	NSLog(@"");
}

- (void)GoogleReaderRequestDidLoadJSON:(NSDictionary *)dict
{
	NSLog(@"");
}

- (void)GoogleReaderRequestDidLoadFeed:(NSString *)feed
{
	NSLog(@"");
}

- (void)GoogleReaderRequestDidAuthenticateWithUser:(NSDictionary *)userDict
{
	[self loadSubscriptions];
}

#pragma mark -
#pragma mark Private

- (void)loadSubscriptions
{
	[reader getSubscriptionsList];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [reader.feedItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
	MWFeedItem *item = [reader.feedItems objectAtIndex:indexPath.row];
	
	cell.textLabel.text = item.title;
	cell.detailTextLabel.text = item.link;
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

