//
//  NSNotificationCenter+ObserverInspector.m
//  LeaksInspector
//
//  Created by linyu on 3/12/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "NSNotificationCenter+ObserverInspect.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "LYNotificationMapper.h"
#import "LYLeaksInspector.h"

#if LYLeaksDebugActive

@implementation NSNotificationCenter (ObserverInspect)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SwizzleInstanceMethod([self class], @selector(addObserver:selector:name:object:), @selector(swizzled_addObserver:selector:name:object:));
        SwizzleInstanceMethod([self class], @selector(removeObserver:), @selector(swizzled_removeObserver:));
        SwizzleInstanceMethod([self class], @selector(removeObserver:name:object:), @selector(swizzled_removeObserver:name:object:));
    });
}

- (void)swizzled_addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject
{
    [self swizzled_addObserver:observer selector:aSelector name:aName object:anObject];

    if ([LYLeaksInspector isActive] && observer){
        extern const void *const kHasBeenObserver;

        objc_setAssociatedObject(observer, kHasBeenObserver, @(YES), OBJC_ASSOCIATION_RETAIN);
        [[LYNotificationMapper shared] addObserver:observer forName:aName];
    }
}

- (void)swizzled_removeObserver:(id)observer
{
    [self swizzled_removeObserver:observer];

    if ([LYLeaksInspector isActive] && observer){
//        if ([observer isKindOfClass:[PlaceholderTableView class]]) {
//            int pp = 0;
//        }
        [[LYNotificationMapper shared] removeObserver:observer];
    }
    
}

- (void)swizzled_removeObserver:(id)observer name:(NSString *)aName object:(id)anObject
{
    [self swizzled_removeObserver:observer name:aName object:anObject];
    
    if ([LYLeaksInspector isActive] && observer){
//        if ([observer isKindOfClass:[PlaceholderTableView class]]) {
//            int pp = 0;
//        }
        [[LYNotificationMapper shared] removeObserver:observer forName:aName];
    }
    
}

@end

#endif