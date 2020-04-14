//
//  KCUtils_EventBus.m
//  KX3
//
//  Created by peng zhi on 12-8-20.
//  Copyright (c) 2012年 kaixin001. All rights reserved.
//

#import "KCUtils_EventBus.h"
#import "KCUtils_Time.h"
#define Notification [NSNotificationCenter defaultCenter]
//异步消息队列
#define AsyncNotification 0

//统计执行时间
#ifdef DEBUG
#define COMPUTE_PROCESSTIME 1
#else
#define COMPUTE_PROCESSTIME 0
#endif
@interface KCUtils_EventBus()
{
    NSMutableDictionary * _listenlist;
    NSMutableDictionary * _eventslist;
    
}

- (void)_addEventListener:(NSString *)eventType target:(id)target callBack:(SEL)callBack;
- (void)_dispatchEvent:(NSString *)eventType params:(id)params;
- (void)__dispatchEvent:(NSString *)eventType params:(id)params;
- (void)_removeEventListener:(NSString *)eventType target:(id)target callBack:(SEL)callBack;
- (void)_removeEventListenerWithTarget:(id)target;

@end
@implementation KCUtils_EventBus
static KCUtils_EventBus * _instances = nil;

+ (KCUtils_EventBus *)sharedBus
{
    if (_instances == nil) {
        _instances = [[KCUtils_EventBus alloc]init];
    }
    return _instances;
}

+ (void)addEventListener:(NSString *)eventType target:(id)target callBack:(SEL)callBack
{
    
    [[KCUtils_EventBus sharedBus]_removeEventListener:eventType target:target callBack:callBack];
    [[KCUtils_EventBus sharedBus]_addEventListener:eventType target:target callBack:callBack];
}


+ (void)removeEventListener:(NSString *)eventType target:(id)target callBack:(SEL)callBack
{
    [[KCUtils_EventBus sharedBus]_removeEventListener:eventType target:target callBack:callBack];
}



+ (void)removeEventListenerWithTarget:(id)target
{
    
    [[KCUtils_EventBus sharedBus]_removeEventListenerWithTarget:target];
}



+ (void)dispatchEvent:(NSString *)eventType params:(id)params
{
    [[KCUtils_EventBus sharedBus]_dispatchEvent:eventType params:params];
}




- (id)init
{
    if ((self = [super init])) {
        _listenlist = [[NSMutableDictionary alloc]init];
        _eventslist = [[NSMutableDictionary alloc]init];
    }
    return self;
}


- (void)_addEventListener:(NSString *)eventType target:(id)target callBack:(SEL)callBack
{
    [Notification addObserver:target selector:callBack name:eventType object:nil];
    
    
}
- (void)_removeEventListener:(NSString *)eventType target:(id)target callBack:(SEL)callBack
{
    [Notification removeObserver:target name:eventType object:nil];
    
    
    //    NSMutableDictionary * mtargetlist = [_eventslist valueForKey:eventType];
    
}
- (void)_removeEventListenerWithTarget:(id)target
{
    
    [Notification removeObserver:target];
}
- (void)_dispatchEvent:(NSString *)eventType params:(id)params
{
    
    if ( [NSThread isMainThread]) {
        
        [self __dispatchEvent:eventType params:params];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self __dispatchEvent:eventType params:params];
        });
    }
    
}
- (void)__dispatchEvent:(NSString *)eventType params:(id)params
{
#if COMPUTE_PROCESSTIME
    NSTimeInterval processstart = [KCUtils_Time getCurrentTime];
#endif
    
#if AsyncNotification
    NSNotification * notify = [NSNotification notificationWithName:eventType object:params];
    [[NSNotificationQueue defaultQueue]enqueueNotification:notify postingStyle:NSPostASAP coalesceMask:NSNotificationNoCoalescing forModes:nil]; 
#else
    [Notification postNotificationName:eventType object:params];
#endif
    
#if COMPUTE_PROCESSTIME
    NSTimeInterval processend = [KCUtils_Time getCurrentTime];
    if (processend - processstart >0.1f) {
       // DDLogInfo(@"event type['%@'] process too slow[%f]!",eventType,(processend - processstart));
    }
#endif
    
}

@end
