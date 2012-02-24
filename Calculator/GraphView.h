//
//  GraphView.h
//  Calculator
//
//  Created by Hung Mai on 22/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDataSource <NSObject>

- (double) yCoordinateWithX: (double)x;

@end

@interface GraphView : UIView

@property (nonatomic,weak) IBOutlet id <GraphViewDataSource> dataSource;

@property (nonatomic) CGPoint origin;

@property (nonatomic) CGFloat scale;

@end
