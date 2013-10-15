//
//  main.m
//  GCDDemo
//
//  Created by zepei xu on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RCAppDelegate.h"

typedef void (^workBlk_t) (int i);

void repeat(int n, workBlk_t aBlock)
{
    for(int i = 0; i < n; i++)
    {
        aBlock(i);
    }
}

int main(int argc, char *argv[])
{
    @autoreleasepool {
        
//        printf("Hello world!\n");
        
//        workBlk_t w = ^(int i){
//            printf("repeat:%d\n",i);
//        };
//        
//        repeat(5, w);
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([RCAppDelegate class]));
    }
}
