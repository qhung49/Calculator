//
//  GraphView.m
//  Calculator
//
//  Created by Hung Mai on 22/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@interface GraphView()

@property (nonatomic) CGSize oldBoundsSize;

- (void) setup;

@end

@implementation GraphView

@synthesize dataSource = _dataSource;
@synthesize origin = _origin;
@synthesize scale = _scale;
@synthesize oldBoundsSize = _oldBoundsSize;

#define DEFAULT_SCALE 0.9
#define TEXT_MARGIN_IN_AXE 50

- (CGFloat)scale
{
    return (_scale) ? _scale : DEFAULT_SCALE; // don't allow zero scale
}

- (void)setScale:(CGFloat)scale
{
    if (scale != _scale)
    {
        _scale = scale;
        [self setNeedsDisplay];
    }
}

- (void) setOrigin:(CGPoint)origin 
{
    _origin = origin;
    [self setNeedsDisplay];
}

- (void) setup
{
    self.origin = CGPointMake(0.0+TEXT_MARGIN_IN_AXE, self.bounds.size.height-TEXT_MARGIN_IN_AXE);
    self.scale = DEFAULT_SCALE;
    self.oldBoundsSize = self.bounds.size;
}

- (void) awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged ||
        gesture.state == UIGestureRecognizerStateEnded) {
        self.scale *= gesture.scale;
        gesture.scale = 1; //reset scale back to 1. We use relative scale
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    // smooth panning
    if (gesture.state == UIGestureRecognizerStateChanged ||
        gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [gesture translationInView:self];
        self.origin = CGPointMake(self.origin.x+translation.x, self.origin.y+translation.y);
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (void)tapTriple:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        self.origin = [gesture locationInView:self];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (self.oldBoundsSize.height != self.bounds.size.height) {
        _origin.y = self.bounds.size.height-TEXT_MARGIN_IN_AXE;
        self.oldBoundsSize = self.bounds.size;
    }
    
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:self.origin scale:1/self.scale];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetLineWidth(context, 5.0);
    //[[UIColor blueColor] setStroke];
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.origin.x, self.origin.y);
    for (CGFloat x=self.origin.x;x<self.bounds.size.width;x += 1/[self contentScaleFactor])
    {
        double xProgram = (x-self.origin.x)*[self contentScaleFactor]*self.scale;
        double yProgram = [self.dataSource yCoordinateWithX:xProgram];
        CGFloat y = self.origin.y - yProgram/[self contentScaleFactor]/self.scale;
        if (y>=0 && y<=self.bounds.size.height)
        {
            //draw here
            CGContextAddLineToPoint(context, x, y);
            CGContextMoveToPoint(context, x, y);
        }
    }
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}

@end
