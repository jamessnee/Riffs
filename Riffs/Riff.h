//
//  Riff.h
//  Riffs
//
//  Created by James Snee on 29/05/2013.
//  Copyright (c) 2013 James Snee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Riff : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * catagory;

@end
