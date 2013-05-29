//
//  SecondViewController.h
//  Riffs
//
//  Created by James Snee on 27/05/2013.
//  Copyright (c) 2013 James Snee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Library_VC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *library_table;

@end
