//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Hung Mai on 15/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userInTheMiddleOfEnteringNumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;
@property (nonatomic, weak) GraphViewController<SplitViewBarButtonItemPresenter> *detailController;

- (void) updateInterfaceWithResult:(id)result;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize displayAll = _displayAll;
@synthesize equalSymbol = _equalSymbol;
//@synthesize displayVariables = _displayVariables;
@synthesize userInTheMiddleOfEnteringNumber = _userInTheMiddleOfEnteringNumber;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;
@synthesize detailController = _detailController;

// Getters and Setters
- (CalculatorBrain *) brain
{
    if (!_brain)
        _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (GraphViewController*) detailController
{
    if (!_detailController)
    {
        id detailVC = [self.splitViewController.viewControllers lastObject];
        if (![detailVC isMemberOfClass:[GraphViewController class]]) {
            detailVC = nil;
        }
        _detailController = detailVC;
    }
    return _detailController;
}

// Target Actions
- (IBAction)variablePressed:(UIButton *)sender {
    self.equalSymbol.text = @"";
    NSString *variableName = sender.currentTitle;
    [self.brain pushVariable:variableName];
    [self updateInterfaceWithResult:nil];
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    self.equalSymbol.text = @"";
    NSString *digit = sender.currentTitle;
    if (self.userInTheMiddleOfEnteringNumber) {
        [self updateInterfaceWithResult:[self.display.text stringByAppendingString:digit]];
    }
    else {
        [self updateInterfaceWithResult:digit];
        self.userInTheMiddleOfEnteringNumber = YES;
    }
}

- (IBAction)signPressed:(UIButton *)sender {
    if (self.userInTheMiddleOfEnteringNumber)
    {
        NSRange range = [self.display.text rangeOfString:@"-"];
        if (range.location == NSNotFound)
        {
            [self updateInterfaceWithResult:[NSString stringWithFormat:@"-%@",self.display.text]];
        }
        else
        {
            [self updateInterfaceWithResult:[self.display.text substringFromIndex: 1]];
        }
    }
    else
    {
        id result = [self.brain performOperation:sender.currentTitle
                                    usingVariableValues:self.testVariableValues];
        [self updateInterfaceWithResult:result];
    }
}

- (IBAction)backspacePressed:(UIButton *)sender {
    if (self.userInTheMiddleOfEnteringNumber == YES)
    {
        [self updateInterfaceWithResult:[self.display.text substringToIndex:([self.display.text length]-1)]];
        if ([self.display.text length] == 0)
        {
            self.userInTheMiddleOfEnteringNumber = NO;
            id result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
            [self updateInterfaceWithResult:result];
        }
    }
    else
    {
        [self.brain popTopItemOffStack];
        id result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
        [self updateInterfaceWithResult:result];
    }
}

- (IBAction)dotPressed {
    NSRange range = [self.display.text rangeOfString:@"."];
    if (range.location == NSNotFound)
    {
        [self updateInterfaceWithResult:[self.display.text stringByAppendingString:@"."]];
        self.userInTheMiddleOfEnteringNumber = YES;
    }
        
}

- (IBAction)enterPressed 
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userInTheMiddleOfEnteringNumber = NO;
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userInTheMiddleOfEnteringNumber)
        [self enterPressed];
    id result = [self.brain performOperation:sender.currentTitle
                                usingVariableValues:self.testVariableValues];
    [self updateInterfaceWithResult:result];
}

- (IBAction)clearPressed 
{
    [self.brain clearAll];
    [self updateInterfaceWithResult:@"0"];
}

- (IBAction)graphPressed 
{
    [self.detailController setProgram:self.brain.program];
}

//- (void) updateDisplayVariables
//{
//    self.displayVariables.text = @"";
//    NSSet *variableSet = [CalculatorBrain variablesUsedInProgram:self.brain.program];
//    for (id variable in variableSet)
//    {
//        id value = [self.testVariableValues objectForKey:variable];
//        if (value && [value isKindOfClass:[NSNumber class]])
//        {
//            self.displayVariables.text = [self.displayVariables.text stringByAppendingFormat:@"%@ = %@ ",variable,value];
//        }
//    }
//    
//}
//- (IBAction)testPressed:(UIButton *)sender 
//{
//    if ([sender.currentTitle isEqualToString:@"Test nil"])
//        self.testVariableValues = nil;
//    else if ([sender.currentTitle isEqualToString:@"Test 1"])
//    {
//        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   [NSNumber numberWithDouble:1],@"x", 
//                                   [NSNumber numberWithDouble:2],@"y",
//                                   [NSNumber numberWithDouble:3],@"z",
//                                   nil];
//    }
//    else if ([sender.currentTitle isEqualToString:@"Test 2"])
//    {
//        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   [NSNumber numberWithDouble:-1],@"x", 
//                                   [NSNumber numberWithDouble:-2],@"y",
//                                   [NSNumber numberWithDouble:-3],@"z",
//                                   nil];
//    }
//
//    [self updateDisplayVariables];
//    id result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
//    [self updateInterfaceWithResult:result];
//}

// Private methods
- (void) updateInterfaceWithResult:(id)result
{
    if ([result isKindOfClass:[NSNumber class]])
    {
        self.display.text = [NSString stringWithFormat:@"%@", result];    
        self.equalSymbol.text = @"=";
    }
    else if ([result isKindOfClass:[NSString class]])
    {
        self.display.text = result;
        self.equalSymbol.text = @"";
    }
    else
    {
         self.equalSymbol.text = @"";
    }
    self.displayAll.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

// UIViewController overridden methods
- (void) awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (void)viewDidUnload {
    [self setDisplayAll:nil];
    [self setEqualSymbol:nil];
    //[self setDisplayVariables:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{
    if ([segue.identifier isEqualToString:@"GraphSegue"]) {
        [segue.destinationViewController setProgram:self.brain.program];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

// UISplitViewControllerDelegate protocol
- (void) splitViewController:(UISplitViewController *)svc 
      willHideViewController:(UIViewController *)aViewController 
           withBarButtonItem:(UIBarButtonItem *)barButtonItem 
        forPopoverController:(UIPopoverController *)pc 
{
    barButtonItem.title = @"Calculator";    
    [self.detailController setSplitViewBarButtonItem:barButtonItem];
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem 
{
    [self.detailController setSplitViewBarButtonItem:nil];
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return self.detailController ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

@end
