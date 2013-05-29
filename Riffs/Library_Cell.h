//
//  Library_Cell.h
//  Riffs
//
//  Created by James Snee on 29/05/2013.
//  Copyright (c) 2013 James Snee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Library_Cell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *background_image;
@property (strong, nonatomic) IBOutlet UILabel *main_title;
@property (strong, nonatomic) IBOutlet UILabel *sub_title_1;
@property (strong, nonatomic) IBOutlet UILabel *sub_title_2;

@end
