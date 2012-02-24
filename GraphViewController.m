//
//  GraphViewController.m
//  Calculator
//
//  Created by Hung Mai on 22/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorBrain.h"
#import "GraphView.h"

@interface GraphViewController() <GraphViewDataSource>

@property (nonatomic,weak) IBOutlet GraphView *graphView;

@end

@implementation GraphViewController

@synthesize displayProgram = _displayProgram;
@synthesize program = _program;
@synthesize graphView = _graphView;

- (void) setProgram:(id)program
{
     _program = program;
    [self.graphView setNeedsDisplay];
}

- (void) setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tapTriple:)];
    tapgr.numberOfTapsRequired = 3;
    tapgr.numberOfTouchesRequired = 1;
    [self.graphView addGestureRecognizer:tapgr];
    UIPanGestureRecognizer *pangr = [[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)];
    [self.graphView addGestureRecognizer:pangr];
    
    self.graphView.dataSource = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (double) yCoordinateWithX:(double)x
{
    self.displayProgram.text = [CalculatorBrain descriptionOfProgram:self.program];
    NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:x],@"x",nil];
    id y = [CalculatorBrain runProgram:self.program usingVariableValues:values];
    if ([y isKindOfClass:[NSNumber class]])
    {
        return [y doubleValue];
    }
    else
        return 0;
}

- (void)viewDidUnload {
    [self setDisplayProgram:nil];
    [super viewDidUnload];
}

@end
