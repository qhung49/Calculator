//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Hung Mai on 15/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack
{
    if (_programStack == nil)
        _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (id) program
{
    return [self.programStack copy]; // don't return an internal data structure
}

- (void) pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void) pushVariable:(NSString *)variableName
{
    CalculatorVariable *variable = [[CalculatorVariable alloc] init];
    variable.name = [variableName copy];
    [self.programStack addObject:variable];
}


- (id) performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

- (id) performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)variableValues
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program usingVariableValues:variableValues];
}

- (void) clearAll
{
    [self.programStack removeAllObjects];
}

+ (NSSet *)variablesUsedInProgram:(id)program 
{
    NSMutableSet *result = [[NSMutableSet alloc] init];
    if ([program isKindOfClass:[NSArray class]])
    {
        for (id item in program)
            if ([item isKindOfClass:[CalculatorVariable class]])
                [result addObject:[item description]];
    }
    return result;
}

+ (BOOL) isMultiOOperation: (NSString *)operation
{
    if ([operation isEqualToString:@"+"] || 
        [operation isEqualToString:@"*"] || 
        [operation isEqualToString:@"/"] || 
        [operation isEqualToString:@"-"] )
        return YES;
    else
        return NO;
}

+ (BOOL) isSingleOOperation: (NSString *)operation
{
    if ([operation isEqualToString:@"sin"] || 
        [operation isEqualToString:@"cos"] || 
        [operation isEqualToString:@"√"] )
        return YES;
    else
        return NO;
}

+ (BOOL) isNoOOperation: (NSString *)operation
{
    if ([operation isEqualToString:@"π"])
        return YES;
    else
        return NO;
}

+ (id) popOperandOffStack:(NSMutableArray *)stack
{
    // note cases that stack is nil and topOfStack is some random object
    double result = 0;
    
    id topOfStack = [stack lastObject]; // topOfStack could be either operation or operand
    if (topOfStack)
        [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        if ([CalculatorBrain isMultiOOperation:operation])
        {
            id o1 = [self popOperandOffStack:stack];
            id o2 = [self popOperandOffStack:stack];
            if (![o1 isKindOfClass:[NSNumber class]] || ![o2 isKindOfClass:[NSNumber class]])
                return @"One of the operand is not a number";
            if ([operation isEqualToString:@"+"])
                result = [o1 doubleValue] + [o2 doubleValue];
            else if ([@"*" isEqualToString:operation])
                result = [o1 doubleValue] * [o2 doubleValue];        
            else if ([@"/" isEqualToString:operation])
            {
                if ([o1 doubleValue]!=0) // avoid division by zero
                    result = [o2 doubleValue] / [o1 doubleValue];
                else
                    return @"Division by zero";
            }
            else if ([@"-" isEqualToString:operation])
                result = [o2 doubleValue] / [o1 doubleValue];
        }
        else if ([CalculatorBrain isSingleOOperation:operation])
        {
            id o1 = [self popOperandOffStack:stack];
            if (![o1 isKindOfClass:[NSNumber class]])
                return @"The operand is not a number";
            if ([operation isEqualToString:@"sin"])
                result = sin([o1 doubleValue]);
            else if ([operation isEqualToString:@"cos"])
                result = cos([o1 doubleValue]);
            else if ([operation isEqualToString:@"√"]) {
                if ([o1 doubleValue]>=0)
                result = sqrt([o1 doubleValue]);
                else
                    return @"Negative number for square root.";
            }
            else if ([operation isEqualToString:@"+/-"])
                result = -[o1 doubleValue];
        }
        else if ([CalculatorBrain isNoOOperation:operation])
        {
            if ([operation isEqualToString:@"π"])
                result = 3.14;
        }
        else 
            return @"Unsupported operation";
    
    }
    
    return [NSNumber numberWithDouble:result];
}

+ (id) runProgram:(id)program
{
    /*
     NSMutableArray *stack;
     if ([program isKindOfClass:[NSArray class]])
     {
     stack = [program mutableCopy];
     }
     return [self popOperandOffStack:stack];
     */
    return [self runProgram:program usingVariableValues:nil];
}

+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    for (int i=0; i<[stack count]; i++)
        if ([[stack objectAtIndex:i] isKindOfClass:[CalculatorVariable class]])
        {
            CalculatorVariable *variable = (CalculatorVariable *) [stack objectAtIndex:i];
            id value = [variableValues objectForKey:variable.name];
            if ([value isKindOfClass:[NSNumber class]])
                [stack replaceObjectAtIndex:i withObject:value];
            else
                [stack replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:0]];
        }
    return [self popOperandOffStack:stack];
}

- (void) popTopItemOffStack
{
    [self.programStack removeLastObject];
}

+ (NSString *) descriptionOfTopOfStack:(NSMutableArray *)stack
{
    // note cases that stack is nil and topOfStack is some random object
    NSString * result = @"";
    
    id topOfStack = [stack lastObject]; // topOfStack could be either operation or operand
    if (topOfStack)
        [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack description];
    }
    else if ([topOfStack isKindOfClass:[NSString class]]) //operation
    {
        NSString *operation = topOfStack;
        if ([self isNoOOperation:operation])
            result = [topOfStack description];
        else if ([self isSingleOOperation:operation])
            result = [NSString stringWithFormat:@"%@(%@)",[topOfStack description],[self descriptionOfTopOfStack:stack]];
        else if ([self isMultiOOperation:operation])
        {
            NSString *temp = [self descriptionOfTopOfStack:stack]; 
            result = [NSString stringWithFormat:@"(%@ %@ %@)",
                        [self descriptionOfTopOfStack:stack], 
                        operation, 
                        temp];
        }
    }
    else if ([topOfStack isKindOfClass:[CalculatorVariable class]])
    {
        result = [topOfStack description];
    }
    
    return result;
    return @"";
}

+ (NSString *) descriptionOfProgram:(id)program
{
    NSString *result = @"";
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    while ([stack count]>0)
    {
        result = [result stringByAppendingString:[self descriptionOfTopOfStack:stack]];
        if ([stack count]>0)
            result = [result stringByAppendingString:@", "]; 
    }
    return result;
}

+ (NSString *) descriptionOfLastProgram:(id)program
{
    NSString *result = @"";
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    return [result stringByAppendingString:[self descriptionOfTopOfStack:stack]];
}

@end
