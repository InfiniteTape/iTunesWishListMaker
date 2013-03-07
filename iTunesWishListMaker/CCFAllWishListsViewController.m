//
//  CCFAllWishListsViewController.m
//  iTunesShoppingListScratch2
//
//  Created by Chris Adamson on 3/4/13.
//  Copyright (c) 2013 Subsequently & Furthermore, Inc. All rights reserved.
//

#import "CCFAllWishListsViewController.h"
//#import "CCFWishListDocument.h"
#import "CCFWishListsStore.h"

@interface CCFAllWishListsViewController ()
@end

@implementation CCFAllWishListsViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//		self.delegate = self;
//    }
//    return self;
//}

-(id) initWithCoder:(NSCoder *)aDecoder {
	
	self = [super initWithCoder:aDecoder];
	if (self) {
		// get the split view delegate callback so we can find the button
		self.delegate = self;
        [CCFWishListsStore sharedInstance];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark UISplitViewDelegate
- (void)splitViewController:(UISplitViewController *)svc
	 willHideViewController:(UIViewController *)aViewController
		  withBarButtonItem:(UIBarButtonItem *)barButtonItem
	   forPopoverController:(UIPopoverController *)pc {
	if (!barButtonItem.title) {
		barButtonItem.title = NSLocalizedString (@"Wish Lists", @"wish lists split button title");
	}
	self.navigationController.navigationBar.topItem.leftBarButtonItem = barButtonItem;
}


@end
