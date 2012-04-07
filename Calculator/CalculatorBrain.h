//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Hung Mai on 15/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalculatorVariable.h"

@interface CalculatorBrain : NSObject

- (void) pushOperand: (double)operand;

- (void) pushVariable: (NSString *)variableName;

- (id) performOperation: (NSString *)operation;

- (id) performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)variableValues;

- (void) clearAll;

- (void) popTopItemOffStack;

@property(nonatomic, readonly) id program;

+ (id)runProgram:(id)program;

+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;

+ (NSString *)descriptionOfProgram: (id)program;

+ (NSString *)descriptionOfLastProgram: (id)program;

+ (NSSet *)variablesUsedInProgram:(id)program;

@end
