//
//  AudioController.h
//  SoundClip
//
//  Created by Thomas Fleischer on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol AudioControllerDelegate 
@required
- (void)playbackStopped;
@end

@interface AudioController : NSObject <AVAudioPlayerDelegate, AVAudioRecorderDelegate> {
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;

    id delegate;
    
    NSMutableDictionary *recordSetting;
    NSString *recorderFileName;
    NSString *recorderFilePath;
}
    
@property (nonatomic, retain) id delegate;
@property (nonatomic, readonly) NSString *recorderFileName;
@property (nonatomic, readonly) NSString *recorderFilePath;

-(void)record;
-(void)play;
-(void)stopRecord;
-(void)stopPlay;

-(BOOL)recording;

@end
