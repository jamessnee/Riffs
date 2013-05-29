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

@interface Library_VC ()

@property (strong, nonatomic) NSArray *all_riffs;

@end

@implementation Library_VC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Second", @"Second");
		self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSArray *fetched = [Riff_Manager get_all_riffs];
	[self setAll_riffs:fetched];
}

#pragma mark - UITableView Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString *identifier = @"RIFFS_LIBRARY";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if(!cell){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
	}
	Riff *curr_riff = [[self all_riffs] objectAtIndex:[indexPath row]];
	
	[[cell textLabel] setText:[curr_riff name]];
	[[cell detailTextLabel] setText:[curr_riff key]];
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [[self all_riffs] count];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
