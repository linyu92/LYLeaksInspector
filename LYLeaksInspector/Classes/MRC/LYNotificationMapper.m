//
//  LYNotificationInspector.m
//  LeaksInspector
//
//  Created by linyu on 3/12/16.
//  Copyright © 2016 linyu. All rights reserved.
//


#import "LYNotificationMapper.h"
#import "LYHeapObjectEnumerator.h"

NSString * LYKey_ObjectAddress = @"ObjectAddress";
NSString * LYKey_Notifications = @"Notifications";

@interface LYNotificationMapper ()
{
    NSMutableDictionary *_observerMap;
    NSMutableArray *_leakNotifications;
}
@end

@implementation LYNotificationMapper

static LYNotificationMapper *g_NotifiInspector;

+ (LYNotificationMapper *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_NotifiInspector = [[LYNotificationMapper alloc] init];
    });
    return g_NotifiInspector;
}

- (id)init
{
    self = [super init];
    if (self) {
        _observerMap = [[NSMutableDictionary alloc] init];
        _leakNotifications = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addObserver:(NSObject *)observer forName:(NSString *)aName
{
    NSString *pair = HeapObjectAddressPair(observer);
    
    NSMutableSet *valueset = [_observerMap objectForKey:pair];
    if (!valueset){
        valueset = [[NSMutableSet alloc] init];
    }
    [valueset addObject:aName];
    
    [_observerMap setObject:valueset forKey:pair];
}

- (void)removeObserver:(NSObject *)observer forName:(NSString *)aName
{
    if (aName.length == 0) {
        return;
    }
    
    NSString *pair = HeapObjectAddressPair(observer);
    
    NSMutableSet *valueset = [_observerMap objectForKey:pair];
    
    if (valueset) {
        [valueset removeObject:aName];
        
        if (valueset.count == 0){
            [_observerMap removeObjectForKey:pair];
        }
    }
}

- (void)removeObserver:(NSObject *)observer
{
    NSString *pair = HeapObjectAddressPair(observer);
    
    [_observerMap removeObjectForKey:pair];
}

- (void)inspectObserverWithObjAddrPair:(NSString *)objAddr
{
    if (![_observerMap objectForKey:objAddr]) {
        return;
    }
    
    NSArray * notificaitons = [[_observerMap objectForKey:objAddr] allObjects];
    NSDictionary *dict = @{LYKey_ObjectAddress:objAddr,
                           LYKey_Notifications:notificaitons};
    [_leakNotifications addObject:dict];
    
    [_observerMap removeObjectForKey:objAddr];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLeaksInspectorWarnNotification object:nil];
}

- (NSArray *)allLeakNotifications;
{
    return [_leakNotifications copy];
}

- (void)clearAllLeakNotifications
{
    [_leakNotifications removeAllObjects];
}
@end
