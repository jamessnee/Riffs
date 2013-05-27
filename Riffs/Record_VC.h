//
//  FirstViewController.h
//  Riffs
//
//  Created by James Snee on 27/05/2013.
//  Copyright (c) 2013 James Snee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface Record_VC : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) AVAudioRecorder	*audio_recorder;
@property (strong, nonatomic) AVAudioPlayer		*audio_player;

// UI
@property (strong, nonatomic) IBOutlet UIButton	*record;
@property (strong, nonatomic) IBOutlet UIButton *start;
@property (strong, nonatomic) IBOutlet UIButton *stop;
@property (strong, nonatomic) IBOutlet UITextField *clip_title;
@property (strong, nonatomic) IBOutlet UITextField *tags;
@property (strong, nonatomic) IBOutlet UITextField *key;

- (IBAction)start_recording:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)start_playback:(id)sender;
- (IBAction)save:(id)sender;

@end
