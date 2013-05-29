//
//  FirstViewController.m
//  Riffs
//
//  Created by James Snee on 27/05/2013.
//  Copyright (c) 2013 James Snee. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Record_VC.h"
#import "Riff.h"
#import "Riff_Manager.h"

@interface Record_VC ()

@property BOOL recording;

@property (strong, nonatomic) NSTimer *timer;
@property NSTimeInterval start_time;

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
	
	// Setup the UI
	[[[self save_details] layer] setMasksToBounds:YES];
	[[[self save_details] layer] setCornerRadius:8.0f];
	[[self time] setText:@"0:00.0"];
	
	
	// Setup for the first recording
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
	
	[self setRecording:NO];
}

- (void)update_time{
	if([[self audio_recorder] isRecording]){
		NSTimeInterval curr_time = [NSDate timeIntervalSinceReferenceDate];
		NSTimeInterval elapsed = curr_time - [self start_time];
		
		int mins = (int) (elapsed / 60.0);
		elapsed -= mins * 60;
		int secs = (int) (elapsed);
		elapsed -= secs;
		int fraction = elapsed * 10.0;
		
		NSString *new_time = [NSString stringWithFormat:@"%u:%02u.%u",mins,secs,fraction];
		[[self time] setText:new_time];
	}
}

#pragma mark - States

- (IBAction)start_recording:(id)sender{
	if([[self audio_recorder] isRecording]){
		NSLog(@"Recording all ready on, pausing");
		[[self audio_recorder] pause];
		[[self record] setTitle:@"PAUSED" forState:UIControlStateNormal];
	}else{
		NSLog(@"Starting recording");
		NSError *error;
		AVAudioSession *audio_session = [AVAudioSession sharedInstance];
		[audio_session setActive:YES error:&error];
		
		if(error){
			NSLog(@"There was an error setting the audios session as active");
		}
		
		// Setup and start the timer
		[self setStart_time:[NSDate timeIntervalSinceReferenceDate]];
		[self setTimer:[NSTimer scheduledTimerWithTimeInterval:1.0f/10.0f target:self selector:@selector(update_time) userInfo:nil repeats:YES]];

		// Start the recording
		[[self audio_recorder] record];
		[[self record] setTitle:@"PAUSE" forState:UIControlStateNormal];
		[self setRecording:YES];
	}
}

- (IBAction)stop:(id)sender{
	if([self recording]){
		NSLog(@"Stopping recording");
		
		// Stop the recording
		[[self audio_recorder] stop];
		[[self record] setTitle:@"RECORD" forState:UIControlStateNormal];
		
		// Stop and reset the timer
		[[self timer] invalidate];
		[[self time] setText:@"0:00.0"];
		
		[self setRecording:NO];
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

#pragma mark - Saving

- (IBAction)save:(id)sender{
	if([[self cancel] isHidden]){
		[[self save] setTitle:@"OK" forState:UIControlStateNormal];
		
		[[self cancel] setAlpha:0.0f];
		[[self cancel] setHidden:NO];
		
		// Animate the SAVE button to new pos.
		CGPoint new_center = CGPointMake([[self save] center].x - 52.0f, [[self save] center].y);
		[UIView animateWithDuration:0.5 animations:^{
			[self save].center = new_center;
		}];
		
		// Animate the save details
		CGPoint details_center = CGPointMake([[self save_details] center].x, [[self save_details] center].y + 230);
		[UIView animateWithDuration:0.5 animations:^{
			[self save_details].center = details_center;
			[[self cancel] setAlpha:1.0f];
		}];
		
	}else{
		BOOL result = [Riff_Manager create_riff_with_title:[[self clip_title] text]
										 key:[[self key] text]
										tags:[[self tags] text]
									and_link:[[[self audio_recorder] url] description]];
		if(result){
			NSLog(@"SUCCESSFULLY SAVED");
		}
		[self reset_save];
	}
}

- (IBAction)cancel_save:(id)sender{
	[self reset_save];
}

- (void)reset_save{
	[[self cancel] setHidden:YES];
	[[self save] setTitle:@"SAVE" forState:UIControlStateNormal];
	
	// Animate the SAVE button to original pos.
	CGPoint new_center = CGPointMake([[self save] center].x + 52.0f, [[self save] center].y);
	[UIView animateWithDuration:0.5 animations:^{
		[self save].center = new_center;
	}];
	
	// Animate the save details to original pos.
	CGPoint details_center = CGPointMake([[self save_details] center].x, [[self save_details] center].y - 230);
	[UIView animateWithDuration:0.5 animations:^{
		[self save_details].center = details_center;
	}];
	
	[[self clip_title] setText:@""];
	[[self key] setText:@""];
	[[self tags] setText:@""];
}

#pragma mark - AVAudioRecorder delegate
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
	[[self record] setTitle:@"RECORD" forState:UIControlStateNormal];
}

#pragma mark - AVAudioPlayer delegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
	NSLog(@"Playback finished");
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
