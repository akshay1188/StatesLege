//
//  BillVotesDataSource.m
//  Created by Gregory S. Combs on 3/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "BillVotesDataSource.h"
#import "SLFDataModels.h"

#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "TexLegeStandardGroupCell.h"
#import "LegislatorDetailViewController.h"

@interface BillVotesDataSource (Private)
- (void) loadVotesAndVoters;
@end

@implementation BillVotesViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.tableView.rowHeight = 73.0f;
	self.tableView.separatorColor = [TexLegeTheme separator];
	self.tableView.backgroundColor = [TexLegeTheme tableBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}
@end

@implementation BillVotesDataSource

@synthesize billVotes = billVotes_, voters = voters_, voteID, viewController;

- (id)initWithBillVotes:(NSMutableDictionary *)newVotes {
	if ((self = [super init])) {
		voters_ = nil;
		if (newVotes) {
			billVotes_ = [newVotes retain];
			voteID = [[newVotes objectForKey:@"vote_id"] retain];
			[self loadVotesAndVoters];
		}
	}
	return self;
}

- (void)dealloc {	
	self.voteID = nil;
	self.voters = nil;	
	self.billVotes = nil;	
    [super dealloc];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

// legislator name is displayed in a plain style tableview

// return the legislator at the index in the sorted by symbol array
- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
	if (!IsEmpty(voters_) && [voters_ count] > indexPath.row)
		return [voters_ objectAtIndex:indexPath.row];
	return nil;	
}

- (NSIndexPath *)indexPathForDataObject:(id)dataObject {
	if (!IsEmpty(voters_))
		return [NSIndexPath indexPathForRow:[voters_ indexOfObject:dataObject] inSection:0];
	return nil;
}

- (void)resetCoreData:(NSNotification *)notification {
	[self loadVotesAndVoters];
}

#pragma mark - UITableViewDataSource methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
	// deselect the new row using animation
	[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];	
	
	NSDictionary *voter = [self dataObjectForIndexPath:newIndexPath];
    NSString *legID = [voter objectForKey:@"legID"];
    if (IsEmpty(legID))
        return;
    
    LegislatorDetailViewController *legVC = [[LegislatorDetailViewController alloc] initWithNibName:@"LegislatorDetailViewController" bundle:nil];
    legVC.detailObjectID = legID;	
    if (self.viewController)
        [self.viewController.navigationController pushViewController:legVC animated:YES];
    [legVC release];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *dataObj = [self dataObjectForIndexPath:indexPath];

	NSString *leg_cell_ID = @"StandardVotingCell";		

	TexLegeStandardGroupCell *cell = (TexLegeStandardGroupCell *)[tableView dequeueReusableCellWithIdentifier:leg_cell_ID];
	
	if (cell == nil) {
		cell = [[[TexLegeStandardGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:leg_cell_ID] autorelease];
		cell.accessoryView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 50.f, 50.f)] autorelease];
		cell.detailTextLabel.font = [TexLegeTheme boldFifteen];
		cell.textLabel.font =		[TexLegeTheme boldTwelve];
	}
	NSInteger voteCode = [[dataObj objectForKey:@"vote"] integerValue];
	UIImageView *imageView = (UIImageView *)cell.accessoryView;
	
	switch (voteCode) {
		case BillVotesTypeYea:
			imageView.image = [UIImage imageNamed:@"VoteYea"];
			break;
		case BillVotesTypeNay:
			imageView.image = [UIImage imageNamed:@"VoteNay"];
			break;
		case BillVotesTypePNV:
		default:
			imageView.image = [UIImage imageNamed:@"VotePNV"];
			break;
	}
	cell.textLabel.text = [dataObj objectForKey:@"subtitle"];
	cell.detailTextLabel.text = [dataObj objectForKey:@"name"];
	cell.imageView.image = [UIImage imageNamed:[dataObj objectForKey:@"photo"]];

	cell.backgroundColor = (indexPath.row % 2 == 0) ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	return cell;	
}

#pragma mark -
#pragma mark Indexing / Sections


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {	
	return 1; 
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
	if (!IsEmpty(voters_)) {
		return [voters_ count];
	}
	return 0;	
}

#pragma mark -
#pragma mark Data Methods

- (void) loadVotesAndVoters {
	if (!billVotes_)
		return;
	
	nice_release(voters_);
	voters_ = [[NSMutableArray alloc] init];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
	NSArray *allMembers = [SLFLegislator findByAttribute:@"chamber" withValue:[billVotes_ objectForKey:@"chamber"]];
	NSDictionary *memberLookup = [allMembers indexKeyedDictionaryWithKey:@"legID"];
	
	NSArray *voteTypes = [NSArray arrayWithObjects:@"other", @"no", @"yes", nil];

	NSInteger codeIndex = BillVotesTypePNV;
	for (NSString *type in voteTypes) {
		NSString *countString = [type stringByAppendingString:@"_count"];
		NSString *votesString = [type stringByAppendingString:@"_votes"];
		NSNumber *voteCode = [NSNumber numberWithInteger:codeIndex];
		
		if ([billVotes_ objectForKey:countString] && [[billVotes_ objectForKey:countString] integerValue]) {
			
			for (NSMutableDictionary *voter in [billVotes_ objectForKey:votesString]) {
									
				// Rather than hard code special cases like the Texas Speaker, who never has a leg_id in vote records 
				//		(because he appears as "Speaker") we skip troublesome voters.
				
				if (IsEmpty([voter objectForKey:@"leg_id"]))
					continue;
				
				SLFLegislator *member = [memberLookup objectForKey:[voter objectForKey:@"leg_id"]];
				if (member) {
					
					NSMutableDictionary *voter = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
												  [member shortNameForButtons], @"name",
												  [member fullNameLastFirst], @"nameReverse",
												  member.lastnameInitial, @"initial",
												  member.legID, @"legID",
												  voteCode, @"vote",
												  [member labelSubText], @"subtitle",
												  member.photoURL, @"photo",
												  nil];
					[voters_ addObject:voter];
					[voter release];
				}
			}
		}
		codeIndex++;
	}
	
	[voters_ sortUsingDescriptors:[NSArray arrayWithObject:
								   [NSSortDescriptor sortDescriptorWithKey:@"nameReverse" ascending:YES]]];
	
	[pool drain];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"BILLVOTES_LOADED" object:self];
	
}

- (NSFetchedResultsController *)fetchedResultsController {
    return nil;		// in case someone wants this from our [super]
}    

@end
