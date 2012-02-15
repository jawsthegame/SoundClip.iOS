//
//  ViewController.h
//  SoundClip
//
//  Created by Thomas Fleischer on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <DropboxSDK/DropboxSDK.h>
#import "AudioController.h"
#import "LocationController.h"
#import "DropboxController.h"

@interface ViewController : UIViewController <AudioControllerDelegate, LocationControllerDelegate, DBRestClientDelegate> {
    AudioController *audioController;
    LocationController *locationController;
    DropboxController *dropboxController;
    
    UIButton *recordButton;        
    UIButton *playButton;
    UIButton *stopButton;
    UIButton *uploadButton;
    
    UIActivityIndicatorView *loadingSpinner;
    
    UILabel *locationLabel;
    UILabel *timestampLabel;
}

@property (nonatomic, retain) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;
@property (nonatomic, retain) IBOutlet UIButton *uploadButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) IBOutlet UILabel *timestampLabel;

-(IBAction)recordAudio;
-(IBAction)playAudio;
-(IBAction)stop;
-(IBAction)upload;

- (void)playbackStopped;

- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;

@end
