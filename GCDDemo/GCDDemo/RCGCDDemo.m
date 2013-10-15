//
//  RCGCDDemo.m
//  GCDDemo
//
//  Created by zepei xu on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RCGCDDemo.h"

@interface RCGCDDemo(Private)

@end

@implementation RCGCDDemo
@synthesize _stringProperty;
@synthesize _block;

- (void)dealloc
{
    self._stringProperty = nil;
    self._block = nil;
    
    [super dealloc];
}


#pragma mark - 演示基本的Inline Block、独立Block的用法，self和属性的操作
//独立的Block方法
typedef NSString* (^IndependentBlock)(NSString* str1,NSString* str2,id this);

IndependentBlock myIndependentBlock = ^NSString*(NSString* str1,NSString* str2,id this)
{
    //NSLog(@"self:%@",self); 在独立Block方法里，不能调用直接调用，需要通过参数传递过来
    
    if(this)
        NSLog(@"this:%@",this);

//在独立的Block方法中不能使用属性.的形式，需要用get和set方法来代替
//        this._stringProperty = @"Modified String Property in independent block";
    
    [this set_stringProperty:@"Modified String Property in independent block"];
    
    if([str1 length] && [str2 length])
        return [NSString stringWithFormat:@"%@%@",str1,str2];
    
    return nil;
};

- (void)simpleMethod
{
    NSUInteger outsideVariable = 10;
    
    __block NSUInteger outsideBlockVariable = 10;
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:@"obj1", @"obj2",nil];
    
    //Inline Block
    [array sortUsingComparator:^(id obj1, id obj2) {
        NSUInteger insideVariable = 20;
        
        outsideBlockVariable = 30;
        
        //outsideVariable = 10 + 10;//error
        NSLog(@"Outside Variable:%lu",(unsigned long)outsideVariable);//说明:在inline block里可以只读访问outsideVariable，而independent block则不行，除非加上__block关键字
        
        NSLog(@"Outside Block Variable:%lu",(unsigned long)outsideBlockVariable);
        
        
        NSLog(@"Inside Variable:%lu",(unsigned long)insideVariable);
        
        NSLog(@"self:%@",self);//在inline block里可以访问self，而在独立Block方法里，不能调用直接调用self，需要通过参数传递过来
        
        self._stringProperty = @"Modified String Property in inline block";
        NSLog(@"_stringProperty:%@",_stringProperty);//在inline block里可以使用self.方法，而在独立的Block方法中不能使用属性.的形式，需要用get和set方法来代替
        
        return NSOrderedSame;
    }];
    
    [array release];
    
    //独立typedef Block
    NSString* temp = myIndependentBlock(@"Hello,",@"Block!",self);
    NSLog(@"myIndependentBlock result:%@",temp);
    NSLog(@"_stringProperty:%@",_stringProperty);
    
    
    //独立Block
    NSString* (^AppendString)(NSString* str1, NSString* str2) =^NSString*(NSString* str1, NSString* str2)
    {
        return [NSString stringWithFormat:@"%@%@",str1,str2];
    };
    
    NSString* temp1 = AppendString(@"str1+",@"str2");
    NSLog(@"temp1:%@",temp1);
}

#pragma mark - Inline Block中变量的修改
typedef void(^BlockWithNoParams)(void);

- (void)scopeTest
{
    NSUInteger integerValue = 10;
    
    /*************** Definition of internal block object ***************/
    //特别注意:当inline block实现的时候，它会对integerValue保持一个只读的拷贝
    BlockWithNoParams myBlock = ^{
        NSLog(@"Integer value inside the block = %lu",
              (unsigned long)integerValue);
    };
    /*************** End definition of internal block object ***************/
    
    integerValue = 20;
    
    /* Call the block here after changing the value of the integerValue variable */
    myBlock();
    
    NSLog(@"Integer value outside the block = %lu", (unsigned long)integerValue);
    
    //所以你将看到，打印的结果是
    //Integer value inside the block = 10
    //Integer value outside the block = 20
    
    //如果想要修改Block中integerValue的值
    //需要声明为__block
}

- (void)test
{
    NSString* str3 = @"abc";
    
    NSString* (^myBlock)(NSString*, NSString*) = ^NSString*(NSString* str1,NSString* str2)
    {
        str1 = @"hi";
        NSLog(@"%@",str3);
        return str2;
    };
    
    myBlock(@"1",@"2");
}

#pragma mark - Block间的调用及Block属性
void (^firstIndependentBlock)(NSString* str1) = ^(NSString* str1)
{
    if([str1 length])
        NSLog(@"firstIndependentBlock:%@",str1);
};

void (^secondIndependentBlock)(NSString* str1) = ^(NSString* str1)
{
    if([str1 length])
        firstIndependentBlock(str1);
};

void (^thirdIndependentBlock)(NSString* str1) = ^(NSString* str1)
{
    if([str1 length])
        NSLog(@"thirdIndependentBlock:%@",str1);
};

- (void)invokeBlockFromAnotherBlock
{
    secondIndependentBlock(@"invokeBlockFromAnotherBlock");
    
    //block 属性
    self._block = thirdIndependentBlock;
    _block(@"Cool!");
}

#pragma mark -  UI-Related UI相关dispatch_get_main_queue执行

- (void)dispathMainQueue
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^(void)
                   {
                       NSLog(@"Current thread = %@", [NSThread currentThread]); NSLog(@"Main thread = %@", [NSThread mainThread]);
                       
                       UIAlertView* temp = [[UIAlertView alloc] initWithTitle:@"测试" message:@"Hi,GCD" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                       [temp show];
                       [temp release];
                   });
}

- (void)dispathConcurrentQueue
{
    void (^printFrom1To1000)(void) = ^(void){
        NSUInteger counter = 0;
        for (counter = 1; counter <= 1000; counter++)
        {
            NSLog(@"Counter = %lu - Thread = %@", (unsigned long)counter,
                  [NSThread currentThread]);
        }
    };
        
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(concurrentQueue, printFrom1To1000);
    dispatch_sync(concurrentQueue, printFrom1To1000);
    dispatch_async(concurrentQueue, printFrom1To1000);
}

- (void)test2
{
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    dispatch_queue_t serial_queue = dispatch_queue_create("my_serial_queue", NULL);
    dispatch_queue_t concurrent_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    typedef void (^MyBlock)();
    
    MyBlock block1 = ^{
        for(int i = 0; i < 100; i++)
        {
            NSLog(@"from block1: %d", i);
        }
    };
    
    MyBlock block2 = ^{
        for(int i = 0; i < 100; i++)
        {
            NSLog(@"from block2: %d", i);
        }
    };
    
    //block中包含异步方法
    MyBlock block3 = ^{

        [self performSelectorInBackground:@selector(method:) withObject:nil];
    };
    
    //block1执行完以后，执行block2
    //dispatch_async(serial_queue,block1);
    //dispatch_async(serial_queue,block2);
    
    //block3与block1交叉执行
    //dispatch_async(serial_queue,block3);
    //dispatch_async(serial_queue,block1);
    
    //block1执行完以后，执行block2
    //dispatch_sync(serial_queue,block1);
    //dispatch_sync(serial_queue,block2);
    
    //block3与block1交叉执行
    //dispatch_sync(serial_queue,block3);
    //dispatch_sync(serial_queue,block1);
    
    //block1与block2交叉执行
    //dispatch_async(concurrent_queue,block1);
    //dispatch_async(concurrent_queue,block2);
    
    //block1执行完以后，执行block2
    //dispatch_sync(concurrent_queue,block1);
    //dispatch_sync(concurrent_queue,block2);
    
    //block3与block1交叉执行
    //dispatch_sync(concurrent_queue,block3);
    //dispatch_sync(concurrent_queue,block1);
    
    dispatch_release(serial_queue);
}

- (void)method:(id)argument
{
    @autoreleasepool {
        for(int i = 0; i < 100; i++)
        {
            NSLog(@"from block3: %d", i);
        }
    }

}

@end
