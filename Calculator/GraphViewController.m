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
#import "ProgramTableViewController.h"

@interface GraphViewController() <GraphViewDataSource,ProgramTableViewControllerDelegate>

@property (nonatomic,weak) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *programDescription;
@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;


- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem;

@end

@implementation GraphViewController

@synthesize program = _program;
@synthesize graphView = _graphView;
@synthesize toolbar = _toolbar;
@synthesize programDescription = _programDescription;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

// Getters and seters
- (void) setProgram:(id)program
{
     _program = program;
    [self.graphView setNeedsDisplay];
    self.title = [CalculatorBrain descriptionOfLastProgram:self.program];
    self.programDescription.title = self.title;
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

- (void) setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem)
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
}

// Target Actions
- (IBAction)addToFavorites:(UIButton *)sender 
{
    NSMutableArray* favorites = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Favorites"] mutableCopy];
    if (!favorites) favorites = [NSMutableArray array];
    [favorites addObject: self.program];
    [[NSUserDefaults standardUserDefaults] setObject:favorites forKey:@"Favorites"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// SplitViewBarButtonItemPresenter protocol
- (void) handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

// GraphViewDataSource protocol
- (double) yCoordinateWithX:(double)x
{
    NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:x],@"x",nil];
    id y = [CalculatorBrain runProgram:self.program usingVariableValues:values];
    if ([y isKindOfClass:[NSNumber class]])
    {
        return [y doubleValue];
    }
    else
        return 0;
}

// UISplitViewControllerDelegate protocol
- (void) splitViewController:(UISplitViewController *)svc 
      willHideViewController:(UIViewController *)aViewController 
           withBarButtonItem:(UIBarButtonItem *)barButtonItem 
        forPopoverController:(UIPopoverController *)pc 
{
    barButtonItem.title = @"Calculator";    
    self.splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem 
{
    self.splitViewBarButtonItem = nil;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

// UINavigationController overridden methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Favorites"])
    {
        NSArray* programs = [[NSUserDefaults standardUserDefaults] objectForKey:@"Favorites"];
        [segue.destinationViewController setPrograms :programs];
        [segue.destinationViewController setDelegate:self];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
    // prevents slide to right opening master controller (iOS 5.1)
    self.splitViewController.presentsWithGesture = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self handleSplitViewBarButtonItem:self.splitViewBarButtonItem];
}

- (void)viewDidUnload {
    [self setToolbar:nil];
    [self setProgramDescription:nil];
    [self setSplitViewBarButtonItem:nil];
    [super viewDidUnload];
}

- (void)programTableViewController:(ProgramTableViewController *)sender choseProgram:(id)program
{
    self.program = program;
}

@end
