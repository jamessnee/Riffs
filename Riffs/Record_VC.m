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
#import "FlatUIKit.h"

@interface Record_VC ()

@property BOOL recording;
@property BOOL playing;

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
	[[self state] setText:@"Ready"];
	
	[self setup_ui];
	
//	// Setup for the first recording
//	int timestamp = [[NSDate date] timeIntervalSince1970];
//	NSString *filename = [NSString stringWithFormat:@"%d",timestamp];
//	
//	NSArray *path_components = [NSArray arrayWithObjects:
//								[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
//								filename,
//								nil];
//	NSURL *output_file = [NSURL fileURLWithPathComponents:path_components];
//	
//	// Audio Setup
//	NSError *error;
//	AVAudioSession *audio_session = [AVAudioSession sharedInstance];
//	[audio_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
//	
//	if(error){
//		NSLog(@"There was an error setting up the audio session");
//	}
//	
//	NSMutableDictionary *record_setting = [[NSMutableDictionary alloc] init];
//	[record_setting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
//    [record_setting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
//    [record_setting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
//	
//	[self setAudio_recorder:[[AVAudioRecorder alloc] initWithURL:output_file settings:record_setting error:&error]];
//	[[self audio_recorder] setDelegate:self];
//	[[self audio_recorder] setMeteringEnabled:YES];
//	[[self audio_recorder] prepareToRecord];
//	
//	[self setRecording:NO];
//	[self setPlaying:NO];
}

- (void)setup_ui{
	FUIButton *record_flat = (FUIButton *)[self record];
	record_flat.buttonColor = [UIColor turquoiseColor];
	record_flat.shadowColor = [UIColor greenSeaColor];
	record_flat.shadowHeight = 3.0f;
	record_flat.cornerRadius = 6.0f;
	[record_flat setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
	[record_flat setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
	
	FUIButton *play_flat = (FUIButton *)[self start];
	play_flat.buttonColor = [UIColor sunflowerColor];
	play_flat.shadowColor = [UIColor tangerineColor];
	play_flat.shadowHeight = 3.0f;
	play_flat.cornerRadius = 6.0f;
	[play_flat setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
	[play_flat setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
	
	FUIButton *stop_flat = (FUIButton *)[self stop];
	stop_flat.buttonColor = [UIColor peterRiverColor];
	stop_flat.shadowColor = [UIColor belizeHoleColor];
	stop_flat.shadowHeight = 3.0f;
	stop_flat.cornerRadius = 6.0f;
	[stop_flat setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
	[stop_flat setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
	
	FUIButton *save_flat = (FUIButton *)[self save];
	save_flat.buttonColor = [UIColor nephritisColor];
	save_flat.shadowColor = [UIColor turquoiseColor];
	save_flat.shadowHeight = 3.0f;
	save_flat.cornerRadius = 6.0f;
	[save_flat setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
	[save_flat setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
	
	FUIButton *cancel_flat = (FUIButton *)[self cancel];
	cancel_flat.buttonColor = [UIColor pomegranateColor];
	cancel_flat.shadowColor = [UIColor alizarinColor];
	cancel_flat.shadowHeight = 3.0f;
	cancel_flat.cornerRadius = 6.0f;
	[cancel_flat setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
	[cancel_flat setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
}

- (void)setup_audio_session{
	// Setup for the first recording
	int timestamp = [[NSDate date] timeIntervalSince1970];
	NSString *filename = [NSString stringWithFormat:@"%d",timestamp];
	
	NSArray *path_components = @[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
								filename];
	NSURL *output_file = [NSURL fileURLWithPathComponents:path_components];
	
	// Audio Setup
	NSError *error;
	AVAudioSession *audio_session = [AVAudioSession sharedInstance];
	[audio_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
	
	if(error){
		NSLog(@"There was an error setting up the audio session");
	}
	
	NSMutableDictionary *record_setting = [[NSMutableDictionary alloc] init];
	[record_setting setValue:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    [record_setting setValue:@44100.0f forKey:AVSampleRateKey];
    [record_setting setValue:@2 forKey:AVNumberOfChannelsKey];
	
	[self setAudio_recorder:[[AVAudioRecorder alloc] initWithURL:output_file settings:record_setting error:&error]];
	[[self audio_recorder] setDelegate:self];
	[[self audio_recorder] setMeteringEnabled:YES];
	[[self audio_recorder] prepareToRecord];
	
	[self setRecording:NO];
	[self setPlaying:NO];
}

- (void)update_time{
	if([[self audio_recorder] isRecording] || [self playing]){
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
		[[self state] setText:@"Paused"];
	}else if([[[self state] text] isEqualToString:@"Ready"]){
		NSLog(@"Starting recording");
		[self setup_audio_session];
		
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
		[[self state] setText:@"Recording"];
	}else{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Start again?" message:@"Are you sure you want to delete your current recording?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
		[alert show];
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
		[[self state] setText:@"Stopped"];
	}else if([self playing]){
		[[self audio_player] stop];
		[[self state] setText:@"Stopped"];
		[self setPlaying:NO];
		
		// Stop and reset the timer
		[[self timer] invalidate];
		[[self time] setText:@"0:00.0"];
	}
	
	NSError *error;
	AVAudioSession *audio_session = [AVAudioSession sharedInstance];
	[audio_session setActive:NO error:&error];
	if(error)
		NSLog(@"There was an error stopping the recording / playback");
	
	NSLog(@"Audio session released");
}

- (IBAction)start_playback:(id)sender{
	if([[[self state] text] isEqualToString:@"Stopped"]){
		NSLog(@"Starting playback");
		if([[self audio_recorder] isRecording])
			[[self audio_recorder] stop];
		
		[[AVAudioSession sharedInstance] setActive:YES error:nil];
		
		NSError *error;
		[self setAudio_player:[[AVAudioPlayer alloc] initWithContentsOfURL:[[self audio_recorder] url] error:&error]];
		
		if(error)
			NSLog(@"There was an error setting up the audio player");
		
		// Setup and start the timer
		[self setStart_time:[NSDate timeIntervalSinceReferenceDate]];
		[self setTimer:[NSTimer scheduledTimerWithTimeInterval:1.0f/10.0f target:self selector:@selector(update_time) userInfo:nil repeats:YES]];
		[[self state] setText:@"Playing"];
		[self setPlaying:YES];
		
		[[self audio_player] setDelegate:self];
		[[self audio_player] play];
	}
}

#pragma mark - Saving

- (IBAction)save:(id)sender{
	if([[self cancel] isHidden] && [[[self state] text] isEqualToString:@"Stopped"]){
		[[self save] setTitle:@"OK" forState:UIControlStateNormal];
		
		[[self cancel] setAlpha:0.0f];
		[[self cancel] setHidden:NO];
		
		// Animate the SAVE button to new pos.
		CGPoint new_center = CGPointMake([[self save] center].x - 42.0f, [[self save] center].y);
		[UIView animateWithDuration:0.5 animations:^{
			[self save].center = new_center;
		}];
		
		// Animate the save details
		CGPoint details_center = CGPointMake([[self save_details] center].x, [[self save_details] center].y + 230);
		[UIView animateWithDuration:0.5 animations:^{
			[self save_details].center = details_center;
			[[self cancel] setAlpha:1.0f];
		}];
		
	}else if([[[self state] text] isEqualToString:@"Stopped"]){
		BOOL result = [Riff_Manager create_riff_with_title:[[self clip_title] text]
										 key:[[self key] text]
										tags:[[self tags] text]
									and_link:[[[self audio_recorder] url] description]];
		if(result){
			NSLog(@"SUCCESSFULLY SAVED");
		}
		
		[[self state] setText:@"Ready"];
		[self setPlaying:NO];
		[self setRecording:NO];
		
		[self reset_save];
	}
}

- (IBAction)cancel_save:(id)sender{
	[self reset_save];
}

- (void)reset_save{
	[[self cancel] setHidden:YES];
	[[self save] setTitle:@"SAVE" forState:UIControlStateNormal];
	
	// If the keyboard's up, remove it
	[[self clip_title] resignFirstResponder];
	[[self key] resignFirstResponder];
	[[self tags] resignFirstResponder];
	
	// Animate the SAVE button to original pos.
	CGPoint new_center = CGPointMake([[self save] center].x + 42.0f, [[self save] center].y);
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
	//[[AVAudioSession sharedInstance] setActive:NO error:nil];
}

#pragma mark - AVAudioPlayer delegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
	NSLog(@"Playback finished");
	[[self state] setText:@"Stopped"];

	// Stop and reset the timer
	[[self timer] invalidate];
	[[self time] setText:@"0:00.0"];
	[self setPlaying:NO];
}

#pragma mark - UITextField delegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex == 0){
		[[self state] setText:@"Ready"];
		[self start_recording:nil];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
