//
//  CCFWishListPDFExport.h
//  iTunesWishListMaker
//
//  Created by Brian Rogers on 3/7/13.
//  Copyright (c) 2013 Subsequently & Furthermore, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCFWishListsStore.h"
#import "CCFWishListDocument.h"

@interface CCFWishListPDFExport : NSObject
-(NSURL *) URLForExportedWishList;
@end
