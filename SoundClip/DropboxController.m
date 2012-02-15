//
//  DropboxController.m
//  SoundClip
//
//  Created by Thomas Fleischer on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DropboxController.h"

@implementation DropboxController

@synthesize delegate;

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    }
    return restClient;
}

-(void)uploadFile:(NSString *)filename localPath:(NSString *)localPath destDir:(NSString *)destDir {
    [[self restClient] uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
    NSLog(@"Tried to upload...");
}

@end
