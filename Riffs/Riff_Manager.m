//
//  Riff_Manager.m
//  Riffs
//
//  Created by James Snee on 27/05/2013.
//  Copyright (c) 2013 James Snee. All rights reserved.
//

#import "Riff_Manager.h"
#import "AppDelegate.h"
#import "Riff.h"

@implementation Riff_Manager

+ (BOOL) create_riff_with_title:(NSString *)clip_title key:(NSString *)key tags:(NSString *)tags and_link:(NSString *)link{
	AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication]delegate];
	NSManagedObjectContext *managed_context = [delegate managedObjectContext];
	if(!managed_context)
		NSLog(@"THERE'S NO MANAGED OBJECT CONTEXT");
	
	Riff *riff = [NSEntityDescription insertNewObjectForEntityForName:@"Riff" inManagedObjectContext:managed_context];
	[riff setName:clip_title];
	[riff setKey:key];
	[riff setTags:tags];
	[riff setLink:link];
	
	NSError *error;
	[managed_context save:&error];
	if(error){
		NSLog(@"ERROR: %@",[error description]);
	}
	
	return YES;
}

+ (NSArray *) get_all_riffs{
	AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managed_context = [delegate managedObjectContext];
	
	NSFetchRequest *fetch_req = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Riff" inManagedObjectContext:managed_context];
	[fetch_req setEntity:entity];
	
	NSError *error;
	NSArray *fetched = [managed_context executeFetchRequest:fetch_req error:&error];
	if(error){
		NSLog(@"ERROR: %@",[error description]);
	}else{
		return fetched;
	}
	
	return nil;
}

@end
