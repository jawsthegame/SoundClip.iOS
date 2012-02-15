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

@synthesize recordButton, playButton, stopButton, uploadButton, loadingSpinner, locationLabel, timestampLabel;

#pragma mark -
#pragma mark - Button Events

-(IBAction)recordAudio {
    recordButton.enabled = NO;
    playButton.enabled = NO;
    stopButton.enabled = YES;
    uploadButton.enabled = NO;
    
    [loadingSpinner startAnimating];
    [audioController record];    
}

-(IBAction)playAudio {
    recordButton.enabled = NO;
    playButton.enabled = NO;
    stopButton.enabled = YES;
    
    [audioController play];
}

-(IBAction)stop {
    recordButton.enabled = YES;
    playButton.enabled = YES;
    stopButton.enabled = NO;
    
    if(audioController.recording) {
        [audioController stopRecord];
        
        [loadingSpinner stopAnimating];
        
        // get geolocation
        locationController = [[LocationController alloc] init];
        locationController.delegate = self;
        [locationController.locationManager startUpdatingLocation];
        
        // get timestamp
        NSDate *date = [NSDate date];
        timestampLabel.text = date.description;
        
        uploadButton.enabled = YES;
    } else {
        [audioController stopPlay];
    }
}

-(IBAction)upload {    
    uploadButton.enabled = NO;
    // upload to dropbox
    dropboxController = [[DropboxController alloc] init];
    dropboxController.delegate = self;
    [dropboxController uploadFile:audioController.recorderFileName localPath:audioController.recorderFilePath destDir:@"/"];
}

#pragma mark -
#pragma mark - AudioControllerDelegate

- (void)playbackStopped {
    recordButton.enabled = YES;
    playButton.enabled = YES;
    stopButton.enabled = NO;
}

#pragma mark -
#pragma mark - LocationControllerDelegate

- (void)locationUpdate:(CLLocation *)location {
    locationLabel.text = location.description;
}

- (void)locationError:(NSError *)error {
    
}
 
#pragma mark -
#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}

#pragma mark -
#pragma mark - System Events

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    audioController = [[AudioController alloc] init];
    audioController.delegate = self;
    
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] link];
    }
    
    recordButton.enabled = YES;
    playButton.enabled = NO;
    stopButton.enabled = NO;
    uploadButton.enabled = NO;
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
    [audioController release];
    [locationController release];
    [dropboxController release];
    [super dealloc];
}

@end
