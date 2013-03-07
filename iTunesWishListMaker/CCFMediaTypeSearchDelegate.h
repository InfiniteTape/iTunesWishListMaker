//
//  CCFMediaTypeSearchDelegate.h
//  iTunesShoppingListScratch2
//
//  Created by Chris Adamson on 2/28/13.
//  Copyright (c) 2013 Subsequently & Furthermore, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CCFMediaTypeSearch;

@protocol CCFMediaTypeSearchDelegate <NSObject>
-(void) mediaTypeSearchDidFinish: (CCFMediaTypeSearch*) search;
@end
