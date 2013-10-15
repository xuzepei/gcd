//
//  RCGCDDemo.h
//  GCDDemo
//
//  Created by zepei xu on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^RCBlock)(NSString* str1);

@interface RCGCDDemo : NSObject

@property(nonatomic,retain)NSString* _stringProperty;
@property(nonatomic,copy)RCBlock _block;

- (void)simpleMethod;
- (void)scopeTest;
- (void)invokeBlockFromAnotherBlock;
- (void)test2;

@end
