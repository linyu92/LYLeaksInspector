//
//  NSObject+LeaksInspector.m
//  LyUtilities
//
//  Created by linyu on 3/7/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "NSObject+LeaksInspector.h"
#import "LYHeapObjectEnumerator.h"
#import <objc/runtime.h>
#import "LYNotificationMapper.h"


static const void *const kViewStackKey = &kViewStackKey;

#if LYLeaksDebugActive

@implementation NSObject (LeaksInspector)



- (BOOL)willDealloc {
    
    if ([LeaksInspectorWhiteListClass() containsObject:NSStringFromClass([self class])]) {
        return NO;
    }
    
    __weak id weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [weakSelf markNotDealloc];
        
    });
    
    return YES;
}

- (NSArray *)viewStack {
    NSArray *viewStack = objc_getAssociatedObject(self, kViewStackKey);
    if (viewStack) {
        return viewStack;
    }
    
    NSString *string = HeapObjectAddressPair(self);

    return @[ string ];
}

- (void)setViewStack:(NSArray *)viewStack {
    objc_setAssociatedObject(self, kViewStackKey, viewStack, OBJC_ASSOCIATION_COPY);
}


- (void)markNotDealloc {
//    NSString *message = [NSString stringWithFormat:@"viewStack: %@", [self viewStack]];
//    NSLog(@"%@", message);
    [LYHeapObjectEnumerator markMayLeakObjectWithHeapStack:[self viewStack]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLeaksInspectorWarnNotification object:nil];
}


@end

#endif
