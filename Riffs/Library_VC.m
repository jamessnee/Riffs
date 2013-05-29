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
	[self setAll_riffs:fetched];
	
	[[self library_table] reloadData];
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
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
