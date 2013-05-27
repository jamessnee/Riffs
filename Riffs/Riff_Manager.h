//
//  Riff_Manager.h
//  Riffs
//
//  Created by James Snee on 27/05/2013.
//  Copyright (c) 2013 James Snee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Riff_Manager : NSObject

+ (BOOL) create_riff_with_title:(NSString *)clip_title key:(NSString *)key tags:(NSString *)tags and_link:(NSString *)link;
+ (NSArray *) get_all_riffs;

@end
