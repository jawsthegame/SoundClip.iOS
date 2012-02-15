//
//  ViewController.m
//  SoundClip
//
//  Created by Thomas Fleischer on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "Utilities.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@implementation ViewController

@synthesize recordButton, playButton, stopButton, loadingSpinner, locationLabel, timestampLabel;

-(IBAction)recordAudio {
    recordButton.enabled = NO;
    playButton.enabled = NO;
    stopButton.enabled = YES;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    recordSetting = [[NSMutableDictionary alloc] init];
    
    // We can use kAudioFormatAppleIMA4 (4:1 compression) or kAudioFormatLinearPCM for nocompression
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
    
    // We can use 44100, 32000, 24000, 16000 or 12000 depending on sound quality
    [recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
    
    // We can use 2(if using additional h/w) or 1 (iPhone only has one microphone)
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    // These settings are used if we are using kAudioFormatLinearPCM format
    //[recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    //[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    
    
    // Create a new dated file
    //NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    // NSString *caldate = [now description];
    // recorderFilePath = [[NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, caldate] retain];

    recorderFileName = [[NSString stringWithFormat:@"%@.caf", [Utilities generateUUIDString]] retain];
    recorderFilePath = [[NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER, recorderFileName] retain];
    
    NSLog(@"recorderFilePath: %@",recorderFilePath);
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    
    err = nil;
    
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    if(audioData)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[url path] error:&err];
    }
    
    err = nil;
    audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!audioRecorder){
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    //prepare to record
    [audioRecorder setDelegate:self];
    [audioRecorder prepareToRecord];
    audioRecorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable = audioSession.inputIsAvailable;
    if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: @"Audio input hardware not available"
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [cantRecordAlert show];
        [cantRecordAlert release];
        return;
    }
    
    [loadingSpinner startAnimating];
    
    // start recording
    [audioRecorder record];
}

-(IBAction)playAudio {
    recordButton.enabled = NO;
    playButton.enabled = NO;
    stopButton.enabled = YES;
    
    NSLog(@"playRecording");
    // Init audio with playback capability
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [audioPlayer setDelegate:self];
    audioPlayer.numberOfLoops = 0;
    
    [audioPlayer play];
    NSLog(@"playing");

}

-(IBAction)stop {
    recordButton.enabled = YES;
    playButton.enabled = YES;
    stopButton.enabled = NO;
    
    NSLog(@"stop");
    if(audioRecorder.recording) {
        NSLog(@"stop recording");
        [audioRecorder stop];
        
        [loadingSpinner stopAnimating];
        
        // get geolocation
        locationController = [[LocationController alloc] init];
        locationController.delegate = self;
        [locationController.locationManager startUpdatingLocation];
        
        // get timestamp
        NSDate *date = [NSDate date];
        timestampLabel.text = date.description;
        
        // upload to dropbox
        dropboxController = [[DropboxController alloc] init];
        dropboxController.delegate = self;
        [dropboxController uploadFile:recorderFileName localPath:recorderFilePath destDir:@"/"];
    } else {
        NSLog(@"stop playback");
        [audioPlayer stop];
    }
    NSLog(@"end of stop");
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    recordButton.enabled = YES;
    playButton.enabled = YES;
    stopButton.enabled = NO;
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"Decode Error occurred");
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"Record successful?");
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"Encode Error occurred");
}

- (void)locationUpdate:(CLLocation *)location {
    locationLabel.text = location.description;
}

- (void)locationError:(NSError *)error {
    
}
    
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] link];
    }
    
    recordButton.enabled = YES;
    stopButton.enabled = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc
{
    [audioPlayer release];
    [audioRecorder release];
    [locationController release];
    [dropboxController release];
    [super dealloc];
}

@end
