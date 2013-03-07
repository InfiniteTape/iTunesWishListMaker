//
//  CCFWishListsStore.m
//  iTunesWishListMaker
//
//  Created by Brian Rogers on 3/7/13.
//  Copyright (c) 2013 Subsequently & Furthermore, Inc. All rights reserved.
//

#import "CCFWishListsStore.h"
#import "CCFWishListDocument.h"

CCFWishListsStore *CCFWishListsStoreSharedInstance;

@implementation CCFWishListsStore

@synthesize currentWishList = _currentWishList;

+(CCFWishListsStore *) sharedInstance{
    if(!CCFWishListsStoreSharedInstance) {
        CCFWishListsStoreSharedInstance = [[CCFWishListsStore alloc] init];
    }
    return CCFWishListsStoreSharedInstance;
}

- (id)init {
    self = [super init];
    if(self) {
        _localWishListURLs = [[NSMutableArray alloc] init];
        _iCloudWishListURLs = [[NSMutableArray alloc] init];
        [self loadLocalWishLists];
        [self loadiCloudWishLists];
    }
    return self;
}

#pragma mark - override get/set

-(void)setCurrentWishList:(CCFWishListDocument *)currentWishList {
    if(_currentWishList != currentWishList) {
        if(_currentWishList) {
            [_currentWishList closeWithCompletionHandler:^(BOOL success) {
                NSLog(@"closed wish list %@", _currentWishList.fileURL);
            }];
        }
        _currentWishList = currentWishList;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentWishListChanged" object:self];
    }
}


-(CCFWishListDocument *)currentWishList{
    return _currentWishList;
}

-(void) renameCurrentWishList: (NSString *)name {
    NSURL *changedURL = [[self localWishListsDirectory] URLByAppendingPathComponent:name];
    [self.currentWishList saveToURL:changedURL
                   forSaveOperation:UIDocumentSaveForCreating
                  completionHandler:^(BOOL success) {
                      [[NSNotificationCenter defaultCenter]postNotificationName:@"CurrentWishListChanged" object:self];
                      [self loadLocalWishLists];
                  }];
    
}

#pragma mark - local files

-(NSURL *)localDocumentsDirectory {
    NSArray *directories = [[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return directories[0];
}

-(NSURL *)localWishListsDirectory {
    return [[self localDocumentsDirectory] URLByAppendingPathComponent:@"wishlists"];
}

-(void)loadLocalWishLists {
    [self.localWishListURLs removeAllObjects];
    NSString *wishListsPath = [[self localWishListsDirectory] path];
    BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:wishListsPath];
    if(!pathExists){
        // create directory and seed empty document
        NSError *createDirectoryError = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:wishListsPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&createDirectoryError];
        NSURL *defaultDocURL = [[self localWishListsDirectory]URLByAppendingPathComponent:@"Untitled.wishlist"];
        CCFWishListDocument *emptyWishList = [[CCFWishListDocument alloc] initWithFileURL:defaultDocURL];
        [emptyWishList saveToURL:defaultDocURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            NSLog(@"created %@", defaultDocURL);
            [self loadLocalWishLists];
        }];
        return;
    }
    
    // load the .wishlist urls
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self localWishListsDirectory]
                                                      includingPropertiesForKeys:nil
                                                                         options:0
                                                                           error:nil];
    for(NSURL *wishListURL in contents) {
        if([[wishListURL pathExtension] isEqualToString:@"wishlist"]) {
            [self.localWishListURLs addObject:wishListURL];
            if(! self.currentWishList) {
                CCFWishListDocument *defaultWishList = [[CCFWishListDocument alloc] initWithFileURL:wishListURL];
                [defaultWishList openWithCompletionHandler:^(BOOL success) {
                    self.currentWishList = defaultWishList;
                    NSLog(@"opened default wishlist at %@", wishListURL);
                }];
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LocalWishListsChanged" object:self];
}

#pragma mark icloud

-(NSURL *)iCloudDocumentsDirectory {
    NSURL *cloudURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    cloudURL = [cloudURL URLByAppendingPathComponent:@"Documents"];
    return cloudURL;
}

-(NSURL *)iCloudWishListsDirectory {
    return [[self iCloudDocumentsDirectory] URLByAppendingPathComponent:@"wishlists"];
}

-(void)loadiCloudWishLists {
    [self.iCloudWishListURLs removeAllObjects];
    // bail if no iCloud
    if(! [self iCloudDocumentsDirectory])
        return;
    
    NSString *wishListsPath = [[self iCloudWishListsDirectory] path];
    BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:wishListsPath];
    if(!pathExists){
        // create directory and seed empty document
        NSError *createDirectoryError = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:wishListsPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&createDirectoryError];
    }
    
    // load the .wishlist urls
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self iCloudWishListsDirectory]
                                                      includingPropertiesForKeys:nil
                                                                         options:0
                                                                           error:nil];
    for(NSURL *wishListURL in contents) {
        if([[wishListURL pathExtension] isEqualToString:@"wishlist"]) {
            [self.iCloudWishListURLs addObject:wishListURL];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"iCloudWishListsChanged" object:self];
}

-(BOOL) saveWishListToiCloud:(CCFWishListDocument *) wishList {
    if(![self iCloudDocumentsDirectory])
        return NO;
    
    NSString *fileName = [wishList.fileURL lastPathComponent];
    NSURL *iCloudURL = [[self iCloudWishListsDirectory] URLByAppendingPathComponent:fileName];
    CCFWishListDocument *iCloudList = [[CCFWishListDocument alloc] initWithFileURL:iCloudURL];
    iCloudList.mutableWishListDicts = wishList.mutableWishListDicts;
    [iCloudList saveToURL:iCloudURL
         forSaveOperation:UIDocumentSaveForCreating
        completionHandler:^(BOOL success) {
            NSLog(@"saved to iCloud %@", iCloudURL);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"iCloudWishListsChanged"
                                                                object:self];
        }];
    
    return YES;
}

#pragma mark defined methods

-(void)createAndMakeCurrentWishList:(NSString *)name {
    NSURL *newURL = [[self localWishListsDirectory] URLByAppendingPathComponent:name];
    CCFWishListDocument *emptyWishList = [[CCFWishListDocument alloc] initWithFileURL:newURL];
    [emptyWishList saveToURL:newURL
            forSaveOperation:UIDocumentSaveForCreating
           completionHandler:^(BOOL success) {
               self.currentWishList = emptyWishList;
               [self loadLocalWishLists];
           }];
}

#pragma mark - import export

-(void) importWishListFromURL:(NSURL *) url{
    CCFWishListDocument *importedWishList = [[CCFWishListDocument alloc]initWithFileURL:url];
    [importedWishList openWithCompletionHandler:^(BOOL success) {
        if(success) {
            NSString *fileName = [url lastPathComponent];
            NSURL *localURL = [[self localWishListsDirectory] URLByAppendingPathComponent:fileName];
            [importedWishList saveToURL:localURL
                       forSaveOperation:UIDocumentSaveForCreating
                      completionHandler:^(BOOL success) {
                          self.currentWishList = importedWishList;
                          [self loadLocalWishLists];
                      }];
        }
    }];
}
@end
