//
//  StatesViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "StatesViewController.h"
#import "StateDetailViewController.h"
#import "SLFState.h"
#import "SLFRestKitManager.h"
#import "OpenStatesTitleView.h"

@interface StatesViewController()
- (void)pushOrSendViewControllerWithState:(SLFState *)newState;
- (void)loadFromNetworkIfEmpty;
- (void)configureTableHeader;
@end

@implementation StatesViewController
@synthesize stateMenuDelegate;

- (id)init {
    self = [super initWithState:nil resourcePath:[NSString stringWithFormat:@"/metadata?apikey=%@", SUNLIGHT_APIKEY] dataClass:[SLFState class]];
    if (self) {
        self.useTitleBar = NO;
    }
    return self;
}

- (void)dealloc {
    self.stateMenuDelegate = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.stateMenuDelegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableHeader];
    [self loadFromNetworkIfEmpty];
    self.title = [NSString stringWithFormat:@"%d States", self.tableViewModel.rowCount];
}

- (void)configureTableViewModel {
    [super configureTableViewModel];
    self.tableViewModel.showsSectionIndexTitles = YES;
    self.tableViewModel.sectionNameKeyPath = @"stateInitial";
    self.tableView.rowHeight = 48;
    SubtitleCellMapping *objCellMap = [SubtitleCellMapping cellMappingWithBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"name" toAttribute:@"textLabel.text"];
        [cellMapping mapKeyPath:@"stateID" toAttribute:@"detailTextLabel.text"];
        [cellMapping mapKeyPath:@"stateFlag" toAttribute:@"imageView.image"];
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            SLFState *state = object;
            SLFSaveSelectedState(state);
//          [[SLFRestKitManager sharedRestKit] preloadObjectsForState:state];
            [self pushOrSendViewControllerWithState:state];
        };
    }];
    [self.tableViewModel mapObjectsWithClass:self.dataClass toTableCellsWithMapping:objCellMap];
    RKTableItem *headerItem = [RKTableItem tableItemWithBlock:^(RKTableItem *tableItem){
        tableItem.text = NSLocalizedString(@"choose a state to get started.", @"");
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMappingWithBlock:^(RKTableViewCellMapping* cellMapping) {
            [cellMapping addDefaultMappings];
            cellMapping.style = UITableViewCellStyleDefault;
            cellMapping.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
                cell.textLabel.textColor = [SLFAppearance cellSecondaryTextColor];
                cell.textLabel.font = SLFItalicFont(14);
                SLFAlternateCellForIndexPath(cell, indexPath);
            };
        }];
    }];
    [self.tableViewModel addHeaderRowForItem:headerItem];
}

- (void)tableViewModelDidFinishLoading:(RKAbstractTableViewModel*)tableViewModel {
    [super tableViewModelDidFinishLoading:tableViewModel];
    self.title = [NSString stringWithFormat:@"%d States", self.tableViewModel.rowCount];
}

- (void)loadFromNetworkIfEmpty {
    NSInteger count = self.tableViewModel.rowCount;
    if (count < 30) { // Sometimes we have 1 row, so 30 is an arbitrary but reasonable sanity check.
        @try {
            [self.tableViewModel loadTableFromNetwork];
        }
        @catch (NSException *exception) {
            RKLogWarning(@"Exception while attempting to load list of available states from network (already in progress?) ... %@", exception);
        }
    }
}

CGFloat const kTitleHeight = 30;

- (void)configureTableHeader {
    if (SLFIsIpad())
        return;
    CGRect contentRect = CGRectMake(15, 0, self.view.width-30, kTitleHeight);
    OpenStatesTitleView *stretchedTitle = [[OpenStatesTitleView alloc] initWithFrame:contentRect];
    stretchedTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.navigationItem.titleView = stretchedTitle;
    [stretchedTitle release];
}

- (void)pushOrSendViewControllerWithState:(SLFState *)state {
    NSParameterAssert(state != NULL);
    if (self.stateMenuDelegate)
        [self.stateMenuDelegate stateMenuSelectionDidChangeWithState:state];
    else {
        NSString *path = [SLFActionPathNavigator navigationPathForController:[StateDetailViewController class] withResource:state];
        if (!IsEmpty(path))
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:self popToRoot:NO];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    return cell;
}

@end
