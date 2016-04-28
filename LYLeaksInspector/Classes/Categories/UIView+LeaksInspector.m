//
//  UIView+LeaksInspector.m
//  LeaksInspector
//
//  Created by linyu on 3/10/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "UIView+LeaksInspector.h"
#import "NSObject+LeaksInspector.h"
#import "UIView+Recursive.h"
#import "LYLeaksInspector.h"
#if LYLeaksDebugActive

@implementation UIView (LeaksInspector)

- (BOOL)willDealloc {
    if (![LYLeaksInspector isActive] || ![super willDealloc]) {
        return NO;
    }
    
    NSArray *viewStack = [self viewStack];
    
    for (UIView *view in self.subviewsWithoutLayoutSupport) {
        NSString *name = HeapObjectAddressPair(view);
        [view setViewStack:[viewStack arrayByAddingObject:name]];
        [view willDealloc];
    }
    
    return YES;
}


@end

#endif
