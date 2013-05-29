//
//  FirstViewController.m
//  Riffs
//
//  Created by James Snee on 27/05/2013.
//  Copyright (c) 2013 James Snee. All rights reserved.
//

#import "Record_VC.h"
#import "Riff.h"
#import "Riff_Manager.h"

@interface Record_VC ()

@end

@implementation Record_VC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = @"Record";
		self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];

	int timestamp = [[NSDate date] timeIntervalSince1970];
	NSString *filename = [NSString stringWithFormat:@"%d",timestamp];
	
	NSArray *path_components = [NSArray arrayWithObjects:
								[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
								filename,
								nil];
	NSURL *output_file = [NSURL fileURLWithPathComponents:path_components];
	
	// Audio Setup
	NSError *error;
	AVAudioSession *audio_session = [AVAudioSession sharedInstance];
	[audio_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
	
	if(error){
		NSLog(@"There was an error setting up the audio session");
	}
	
	NSMutableDictionary *record_setting = [[NSMutableDictionary alloc] init];
	[record_setting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [record_setting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [record_setting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
	
	[self setAudio_recorder:[[AVAudioRecorder alloc] initWithURL:output_file settings:record_setting error:&error]];
	[[self audio_recorder] setDelegate:self];
	[[self audio_recorder] setMeteringEnabled:YES];
	[[self audio_recorder] prepareToRecord];
	
	NSLog(@"Setup and ready to go");
}

- (IBAction)start_recording:(id)sender{
	if([[self audio_recorder] isRecording]){
		NSLog(@"Recording all ready on, pausing");
		[[self audio_recorder] pause];
		[[self record] setTitle:@"Paused!" forState:UIControlStateNormal];
	}else{
		NSLog(@"Starting recording");
		NSError *error;
		AVAudioSession *audio_session = [AVAudioSession sharedInstance];
		[audio_session setActive:YES error:&error];
		
		if(error){
			NSLog(@"There was an error setting the audios session as active");
		}
		
		[[self audio_recorder] record];
		[[self record] setTitle:@"Pause" forState:UIControlStateNormal];
	}
}

- (IBAction)stop:(id)sender{
	if([[self audio_recorder] isRecording]){
		NSLog(@"Stopping recording");
		[[self audio_recorder] stop];
		[[self record] setTitle:@"Record" forState:UIControlStateNormal];
	}
	
	NSError *error;
	AVAudioSession *audio_session = [AVAudioSession sharedInstance];
	[audio_session setActive:NO error:&error];
	if(error)
		NSLog(@"There was an error stopping the recording / playback");
	
	NSLog(@"Audio session released");
}

- (IBAction)start_playback:(id)sender{
	NSLog(@"Starting playback");
	if([[self audio_recorder] isRecording])
		[[self audio_recorder] stop];
	
	NSError *error;
	[self setAudio_player:[[AVAudioPlayer alloc] initWithContentsOfURL:[[self audio_recorder] url] error:&error]];
	if(error)
		NSLog(@"There was an error setting up the audio player");
	
	[[self audio_player] setDelegate:self];
	[[self audio_player] play];
}

- (IBAction)save:(id)sender{
	[Riff_Manager create_riff_with_title:[[self clip_title] text] key:[[self key] text] tags:[[self tags] text] and_link:[[[self audio_recorder] url] description]];
}

#pragma mark - AVAudioRecorder delegate
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
	[[self record] setTitle:@"Record" forState:UIControlStateNormal];
}

#pragma mark - AVAudioPlayer delegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
													message: @"Finish playing the recording!"
												   delegate: nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UITextField delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
	
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
