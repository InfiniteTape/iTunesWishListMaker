//
//  CCFWishListDocument.h
//  iTunesWishListMaker
//
//  Created by Brian Rogers on 3/7/13.
//  Copyright (c) 2013 Subsequently & Furthermore, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCFWishListDocument : UIDocument
// Mutable so it doesn't screw up iCloud
@property (copy) NSMutableArray *mutableWishListDicts;

-(void)addItemDict: (NSDictionary *)dict;
-(void)removeItemDict: (NSDictionary *)dict;
@end
