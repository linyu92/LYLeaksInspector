//
//  NSObject+ObserverInspector.m
//  LeaksInspector
//
//  Created by linyu on 3/13/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "NSObject+MRCDeallocInspect.h"
#import "LYNotificationMapper.h"
#import "LYHeapObjectEnumerator.h"
#import <objc/runtime.h>



const void *const kHasBeenObserver = &kHasBeenObserver;

#if LYLeaksDebugActive

@implementation NSObject (MRCDeallocInspect)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SwizzleInstanceMethod([self class], @selector(dealloc), @selector(swizzled_dealloc));
    });
}


- (void)swizzled_dealloc{
    if ([objc_getAssociatedObject(self, kHasBeenObserver) boolValue]) {
        NSString *pair = HeapObjectAddressPair(self);
        [self swizzled_dealloc];
        [[LYNotificationMapper shared ]inspectObserverWithObjAddrPair:pair];
    }else{
        [self swizzled_dealloc];
    }
    
    
}


@end

#endif