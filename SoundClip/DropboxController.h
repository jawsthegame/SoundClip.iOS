//
//  DropboxController.h
//  SoundClip
//
//  Created by Thomas Fleischer on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>

@interface DropboxController : NSObject {
    DBRestClient *restClient;
    id delegate;
}

@property(nonatomic, retain) id delegate;

-(void)uploadFile:(NSString *)filename
        localPath:(NSString *)localPath
        destDir:(NSString *)destDir;

@end
