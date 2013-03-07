
//
//  CCFWishListPDFExport.m
//  iTunesWishListMaker
//
//  Created by Brian Rogers on 3/7/13.
//  Copyright (c) 2013 Subsequently & Furthermore, Inc. All rights reserved.
//

#import "CCFWishListPDFExport.h"
#import "CCFWishListsStore.h"
#import "CCFWishListDocument.h"


@implementation CCFWishListPDFExport

-(NSURL *)URLForExportedWishList {
    CCFWishListDocument *wishList = [CCFWishListsStore sharedInstance].currentWishList;
    NSString *nameStub = [[wishList.fileURL lastPathComponent] stringByDeletingPathExtension];
    NSString *exportName = [nameStub stringByAppendingPathExtension:@"pdf"];
    NSArray *directories = [[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *pdfURL = [directories[0] URLByAppendingPathComponent:exportName];
    
    CGRect pdfBox = CGRectMake(0.0, 0.0, 612.0, 792.0);
    CGContextRef context = CGPDFContextCreateWithURL((__bridge CFURLRef)(pdfURL), &pdfBox, NULL);
    CGContextBeginPage(context, &pdfBox);
    CGContextSelectFont(context, "Helvetica Bold", 20.0, kCGEncodingMacRoman);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    NSString *lineText = @"iTunes Wish List";
    CGContextShowTextAtPoint(context, 200.0, 750.0, [lineText UTF8String], [lineText length]);
    
    CGFloat drawY = 700.0;
    for(NSDictionary *item in wishList.mutableWishListDicts) {
        drawY -= 25.0;
        CGContextSelectFont(context, "Helvetica Bold", 14.0, kCGEncodingMacRoman);
        NSString *title = item[@"collectionName"];
        if(!title) {
            title = item[@"trackName"];
        }
        if(!title) {
            title = item[@"trackCensoredName"];
        }
        lineText = title;
        CGContextShowTextAtPoint(context, 20.0, drawY, [lineText UTF8String], [lineText length]);
        CGContextSelectFont(context, "Helvetica", 12.0, kCGEncodingMacRoman);
        lineText = item[@"artistName"];
        drawY -= 15.0;
        CGContextShowTextAtPoint(context, 20.0, drawY, [lineText UTF8String], [lineText length]);
    }
    CGContextEndPage(context);
    CGContextFlush(context);
    CGContextRelease(context);
    
    return pdfURL;
}

@end
