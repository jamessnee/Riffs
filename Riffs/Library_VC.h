//
//  SecondViewController.h
//  Riffs
//
//  Created by James Snee on 27/05/2013.
//  Copyright (c) 2013 James Snee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface Library_VC : UIViewController <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *library_table;
@property (strong, nonatomic) AVAudioPlayer		*TEMP_audio_player;

@end
