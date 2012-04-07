//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Hung Mai on 15/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController <UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *display;

@property (weak, nonatomic) IBOutlet UILabel *displayAll;

@property (weak, nonatomic) IBOutlet UILabel *equalSymbol;

@end
