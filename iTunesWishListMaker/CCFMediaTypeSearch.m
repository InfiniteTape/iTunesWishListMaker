//
//  CCFMediaTypeSearch.m
//  iTunesShoppingListScratch2
//
//  Created by Chris Adamson on 2/28/13.
//  Copyright (c) 2013 Subsequently & Furthermore, Inc. All rights reserved.
//

#import "CCFMediaTypeSearch.h"

@interface CCFMediaTypeSearch()
@property (strong) NSURLConnection *connection;
@property (strong) NSMutableData *connectionData;
@end

@implementation CCFMediaTypeSearch 


#pragma init/dealloc
-(id) initWithSearchURL: (NSURL*) iTunesSearchURL
			  mediaType: (NSString*) mediaType
			   delegate: (id<CCFMediaTypeSearchDelegate>) delegate {
	self = [super init];
    if (self) {
		_mediaType = [mediaType copy];
		_delegate = delegate;
		NSURLRequest *searchRequest = [NSURLRequest requestWithURL:iTunesSearchURL];
		_connectionData = [[NSMutableData alloc] init];
		_connection = [NSURLConnection connectionWithRequest:searchRequest delegate:self];
    }
    return self;
}


#pragma mark NSURLConnection delegate
-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog (@"%@ received response", self.mediaType);
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data	{
	[self.connectionData appendData:data];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog (@"%@ Failed with error: %@", self.mediaType, error);
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
	NSError *jsonErr = nil;
	NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:self.connectionData
																options:0
																  error:&jsonErr];
	NSLog (@"deserialzed json: %@", json);
	// results should be a dict with keys "results" and "resultCount"
	NSArray *jsonResults = [json valueForKey:@"results"];
	if (jsonResults) {
		self.results = jsonResults;
		[self.delegate mediaTypeSearchDidFinish:self];
	}
	self.connectionData = nil;
//	self.connection = nil;
}


@end
