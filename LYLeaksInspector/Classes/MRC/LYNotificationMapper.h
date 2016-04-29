//
//  LYNotificationInspector.h
//  LeaksInspector
//
//  Created by linyu on 3/12/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * LYKey_ObjectAddress;
extern NSString * LYKey_Notifications;

@interface LYNotificationMapper : NSObject

+ (LYNotificationMapper *)shared;

- (void)addObserver:(NSObject *)observer forName:(NSString *)aName;
- (void)removeObserver:(NSObject *)observer forName:(NSString *)aName;
- (void)removeObserver:(NSObject *)observer;

- (void)inspectObserverWithObjAddrPair:(NSString *)objAddr;

- (NSArray *)allLeakNotifications;

- (void)clearAllLeakNotifications;

@end
