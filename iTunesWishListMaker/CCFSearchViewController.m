//
//  CCFViewController.m
//  iTunesShoppingListScratch2
//
//  Created by Chris Adamson on 2/27/13.
//  Copyright (c) 2013 Subsequently & Furthermore, Inc. All rights reserved.
//

#import "CCFSearchViewController.h"
#import "CCFMediaTypeSearch.h"
#import "CCFGenericItemCollectionCell.h"
#import "CCFMediaTypeSearchDelegate.h"
#import "CCFStoreItemDetailViewController.h"

@interface CCFSearchViewController () <CCFMediaTypeSearchDelegate>
@property (strong) NSMutableArray *resultsArray;
@property (weak, nonatomic) IBOutlet UICollectionView *resultsView;
@end

@implementation CCFSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.resultsArray = [[NSMutableArray alloc] initWithCapacity:4];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark collection data source
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	if (! self.resultsArray) {
		return 0;
	} else {
		return [self.resultsArray count];
	}
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	if (! self.resultsArray) {
		return 0;
	} else {
		CCFMediaTypeSearch *search = [self.resultsArray objectAtIndex:section];
		return [search.results count];
	}
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	CCFGenericItemCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GenericItemCell"
																		   forIndexPath:indexPath];
	CCFMediaTypeSearch *search = [self.resultsArray objectAtIndex:indexPath.section];
	NSDictionary *item = [search.results objectAtIndex:indexPath.row];
	NSString *title = [item objectForKey:@"collectionName"];
	if (!title) {
		title = [item objectForKey:@"trackName"];
	}
	if (!title) {
		title = [item objectForKey:@"trackCensoredName"];
	}
	cell.titleLabel.text = title;
//	cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[item objectForKey:@"artworkUrl100"]]]];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSData *imageData = [NSData dataWithContentsOfURL:
							 [NSURL URLWithString:
							  [item objectForKey:@"artworkUrl100"]]];
		dispatch_async(dispatch_get_main_queue(), ^{
			cell.imageView.image = [UIImage imageWithData:imageData];
		});
	});
	return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
																			  withReuseIdentifier:@"SectionHeader" forIndexPath:indexPath];
	UILabel *titleLabel = (UILabel*) [headerView viewWithTag:100];
	CCFMediaTypeSearch *search = [self.resultsArray objectAtIndex:indexPath.section];
	titleLabel.text = search.mediaType;
	return headerView;
}

#pragma mark collection delegate

#pragma mark serach bar delegate
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	[self.resultsArray removeAllObjects];

	// albums
	NSString *searchTerm = [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	searchTerm = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *searchString = [NSString stringWithFormat:@"https://itunes.apple.com/search?media=music&entity=album&limit=50&term=%@",searchTerm];
	NSURL *searchURL = [NSURL URLWithString:searchString];

	CCFMediaTypeSearch *search = [[CCFMediaTypeSearch alloc] initWithSearchURL:searchURL
																	 mediaType:@"Albums"
																	  delegate:self];
	[self.resultsArray addObject:search];
	
	// books
	searchString = [NSString stringWithFormat:@"https://itunes.apple.com/search?media=ebook&entity=ebook&limit=50&term=%@",searchTerm];
	searchURL = [NSURL URLWithString:searchString];
	search = [[CCFMediaTypeSearch alloc] initWithSearchURL:searchURL
												 mediaType:@"Books"
												  delegate:self];
	[self.resultsArray addObject:search];

	// movies
	searchString = [NSString stringWithFormat:@"https://itunes.apple.com/search?media=movie&entity=movie&limit=50&term=%@",searchTerm];
	searchURL = [NSURL URLWithString:searchString];
	search = [[CCFMediaTypeSearch alloc] initWithSearchURL:searchURL
												 mediaType:@"Movies"
												  delegate:self];
	[self.resultsArray addObject:search];

	// tv
	searchString = [NSString stringWithFormat:@"https://itunes.apple.com/search?media=tvSho&entity=tvSeason&limit=50&term=%@",searchTerm];
	searchURL = [NSURL URLWithString:searchString];
	search = [[CCFMediaTypeSearch alloc] initWithSearchURL:searchURL
												 mediaType:@"TV Shows"
												  delegate:self];

	[self.resultsArray addObject:search];

	NSLog (@"resultsArray: %@", self.resultsArray);
	
}


#pragma mark copy support

-(BOOL) canBecomeFirstResponder {
	return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	if (action == @selector(copy:)) {
		return YES;
	}
	return [super canPerformAction:action withSender:sender];
}


- (BOOL)collectionView:(UICollectionView *)collectionView
	  canPerformAction:(SEL)action
	forItemAtIndexPath:(NSIndexPath *)indexPath
			withSender:(id)sender {
	return action == @selector(copy:);
}

- (BOOL)collectionView:(UICollectionView *)collectionView
shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
		 performAction:(SEL)action
	forItemAtIndexPath:(NSIndexPath *)indexPath
			withSender:(id)sender {
	if (action == @selector(copy:)) {
		CCFMediaTypeSearch *search = [self.resultsArray objectAtIndex:indexPath.section];
		NSDictionary *item = [search.results objectAtIndex:indexPath.row];
		NSString *title = [item objectForKey:@"collectionName"];
		if (!title) {
			title = [item objectForKey:@"trackName"];
		}
		if (!title) {
			title = [item objectForKey:@"trackCensoredName"];
		}
		NSDictionary *pasteboardItem = @ {
			@"public.text" : title
		};
		[UIPasteboard generalPasteboard].items = @[pasteboardItem];
	}
}


#pragma mark search delegate
-(void) mediaTypeSearchDidFinish: (CCFMediaTypeSearch*) search {
	[self.resultsView reloadData];
}

#pragma mark seque
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"ShowItemDetails"]) {
		NSIndexPath *indexPath = [[self.resultsView indexPathsForSelectedItems] objectAtIndex:0];
		CCFMediaTypeSearch *search = [self.resultsArray objectAtIndex:indexPath.section];
		NSDictionary *item = [search.results objectAtIndex:indexPath.row];
		CCFStoreItemDetailViewController *detailVC =
		(CCFStoreItemDetailViewController*) segue.destinationViewController;
		detailVC.mediaItemDict = item;
	}
}

@end
