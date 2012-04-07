//
//  GraphViewController.h
//  Calculator
//
//  Created by Hung Mai on 22/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface GraphViewController : UIViewController <SplitViewBarButtonItemPresenter>

@property (nonatomic,strong) id program; //model here

@end
