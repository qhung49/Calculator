//
//  GraphViewController.h
//  Calculator
//
//  Created by Hung Mai on 22/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *displayProgram;

@property (nonatomic,strong) id program; //model here

@end
