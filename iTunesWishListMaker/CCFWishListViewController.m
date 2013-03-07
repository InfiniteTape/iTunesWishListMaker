//
//  CCFWishListViewController.m
//  iTunesWishListMaker
//
//  Created by Brian Rogers on 3/7/13.
//  Copyright (c) 2013 Subsequently & Furthermore, Inc. All rights reserved.
//

#import "CCFWishListViewController.h"
#import "CCFWishListsStore.h"

@interface CCFWishListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)handleUndoTapped:(id)sender;

@end

@implementation CCFWishListViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:@"CurrentWishListChanged"
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          [self.tableView reloadData];
                                                          self.navigationController.navigationBar.topItem.title = [[CCFWishListsStore sharedInstance].currentWishList.fileURL lastPathComponent];
                                                      }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark table stuff
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [CCFWishListsStore sharedInstance].currentWishList.mutableWishListDicts.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WishListCell"];
    NSDictionary *item = [CCFWishListsStore sharedInstance].currentWishList.mutableWishListDicts[indexPath.row];
    NSString *title = item[@"collectionName"];
    if(!title) {
        title = item[@"trackName"];
    }
    if(!title) {
        title = item[@"trackCensoredName"];
    }
    cell.textLabel.text = title;
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *item = [[CCFWishListsStore sharedInstance].currentWishList.mutableWishListDicts objectAtIndex:indexPath.row];
        [[CCFWishListsStore sharedInstance].currentWishList removeItemDict:item];
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (IBAction)handleUndoTapped:(id)sender {
    CCFWishListDocument *wishListDocument = [CCFWishListsStore sharedInstance].currentWishList;
    if([wishListDocument.undoManager canUndo]) {
        [wishListDocument.undoManager undo];
        [self.tableView reloadData];
    }
    else {
        UIAlertView *cantUndoAlert = [[UIAlertView alloc]initWithTitle:@"Can't Undo"
                                                               message:@"Nothing to undo"
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
        [cantUndoAlert show];
    }
}
@end
