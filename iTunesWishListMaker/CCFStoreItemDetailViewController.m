//
//  CCFStoreItemDetailViewController.m
//  iTunesShoppingListScratch2
//
//  Created by Chris Adamson on 3/4/13.
//  Copyright (c) 2013 Subsequently & Furthermore, Inc. All rights reserved.
//

#import "CCFStoreItemDetailViewController.h"
//#import "CCFWishListsStore.h"

@interface CCFStoreItemDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
- (IBAction)handleAddToWishListTapped:(id)sender;
@end

@implementation CCFStoreItemDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	NSString *title = [self.mediaItemDict objectForKey:@"collectionName"];
	if (!title) {
		title = [self.mediaItemDict objectForKey:@"trackName"];
	}
	if (!title) {
		title = [self.mediaItemDict objectForKey:@"trackCensoredName"];
	}
	self.titleLabel.text = title;
	self.artistLabel.text = [self.mediaItemDict valueForKey:@"artistName"];
	self.artworkImageView.image = [UIImage imageWithData:
								   [NSData dataWithContentsOfURL:
									[NSURL URLWithString:
									 [self.mediaItemDict valueForKey:@"artworkUrl100"]]]];
	NSString *description = [self.mediaItemDict valueForKey:@"description"];
	if (! description) {
		description = [self.mediaItemDict valueForKey:@"longDescription"];
	}
	self.descriptionLabel.text = description;

	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleAddToWishListTapped:(id)sender {
//	NSLog (@"currentWishList.mutableWishListDicts is a %@",
//		   [[CCFWishListsStore sharedInstance].currentWishList.mutableWishListDicts class]);
//	CCFWishListDocument *wishListDoc = [CCFWishListsStore sharedInstance].currentWishList;
//	[wishListDoc addItemDict:self.mediaItemDict];
//	// can we auto-navigate to the list page?
}

@end
