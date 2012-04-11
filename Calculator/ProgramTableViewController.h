//
//  ProgramTableViewController.h
//  Calculator
//
//  Created by Hung Mai on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProgramTableViewController;

@protocol ProgramTableViewControllerDelegate <NSObject>

@optional
- (void) programTableViewController:(ProgramTableViewController*)sender choseProgram:(id)program;

@end

@interface ProgramTableViewController : UITableViewController

@property (nonatomic,strong) NSArray* programs;
@property (nonatomic,weak) id<ProgramTableViewControllerDelegate> delegate;

@end
