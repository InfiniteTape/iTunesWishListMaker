//
//  CCFMediaTypeSearch.h
//  iTunesShoppingListScratch2
//
//  Created by Chris Adamson on 2/28/13.
//  Copyright (c) 2013 Subsequently & Furthermore, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCFMediaTypeSearchDelegate.h"

@interface CCFMediaTypeSearch : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (copy) NSString *mediaType;
@property (copy) NSArray *results;
-(id) initWithSearchURL: (NSURL*) iTunesSearchURL
			  mediaType: (NSString*) mediaType
			   delegate: (id<CCFMediaTypeSearchDelegate>) delegate;
@property (weak) id<CCFMediaTypeSearchDelegate> delegate;
@end
