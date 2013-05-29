//
//  SecondViewController.m
//  Riffs
//
//  Created by James Snee on 27/05/2013.
//  Copyright (c) 2013 James Snee. All rights reserved.
//

#import "Library_VC.h"
#import "Riff_Manager.h"
#import "Riff.h"
#import "Library_Cell.h"

@interface Library_VC ()

@property (strong, nonatomic) NSArray *all_riffs;
@property int colour_counter;

@end

@implementation Library_VC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = @"Library";
		self.tabBarItem.image = [UIImage imageNamed:@"second"];
		self.colour_counter = 0;
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
	NSArray *fetched = [Riff_Manager get_all_riffs];
	
	if([fetched count] != [[self all_riffs] count]){
		[self setAll_riffs:fetched];
		
		//	[[self library_table] reloadData];
		NSMutableArray *tableview_indexes = [[NSMutableArray alloc] init];
		for(int i = 0; i < [fetched count]; i++){
			[tableview_indexes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
		}
		
		[[self library_table] beginUpdates];
		[[self library_table] insertRowsAtIndexPaths:tableview_indexes withRowAnimation:UITableViewRowAnimationLeft];
		[[self library_table] endUpdates];
	}
}

#pragma mark - UITableView Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString *identifier = @"RIFFS_LIBRARY";
	Library_Cell *cell = (Library_Cell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if(!cell){
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"Library_Cell" owner:nil options:nil];
        for(id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass:[Library_Cell class]])
            {
                cell = (Library_Cell *)currentObject;
                break;
            }
        }
	}
	
	// Fill in the data
	Riff *curr_riff = [[self all_riffs] objectAtIndex:[indexPath row]];
	
	[[cell main_title] setText:[curr_riff name]];
	[[cell sub_title_1] setText:[curr_riff key]];
	[[cell sub_title_2] setText:[curr_riff tags]];
	
	if([self colour_counter] == 0)
		[[cell background_image] setImage:[UIImage imageNamed:@"cell_LightBlue.png"]];
	else if([self colour_counter] == 1)
		[[cell background_image] setImage:[UIImage imageNamed:@"cell_DarkBlue.png"]];
	else if([self colour_counter] == 2)
		[[cell background_image] setImage:[UIImage imageNamed:@"cell_LightOrange.png"]];
	else{
		[[cell background_image] setImage:[UIImage imageNamed:@"cell_DarkOrange.png"]];
		[self setColour_counter:0];
	}
	[self setColour_counter:[self colour_counter] + 1];

	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [[self all_riffs] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 59.0f;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	//[[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
	Riff *curr_riff = [[self all_riffs] objectAtIndex:[indexPath row]];

	NSError *error;
	[self setTEMP_audio_player:[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:[curr_riff link]]
																	  error:&error]];
	if(error)
		NSLog(@"There was an error setting up the audio player");
	
	[[self TEMP_audio_player] setDelegate:self];
	[[self TEMP_audio_player] play];
}

#pragma mark - AVAudioPlayer delegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
	NSLog(@"Playback finished");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
