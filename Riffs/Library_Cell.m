//
//  Library_Cell.m
//  Riffs
//
//  Created by James Snee on 29/05/2013.
//  Copyright (c) 2013 James Snee. All rights reserved.
//

#import "Library_Cell.h"

@implementation Library_Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
