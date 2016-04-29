//
//  UIView+Recursive.m
//  LeaksInspector
//
//  Created by linyu on 3/9/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "UIView+Recursive.h"

@implementation UIView (Recursive)

- (NSArray *)subviewsWithoutLayoutSupport
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIView class]] &&
            [subview conformsToProtocol:@protocol(UILayoutSupport)] == NO) {
            [array addObject:subview];
        }
    }
    return array;
}

- (NSUInteger)subviewsCount:(BOOL)recursive{
    if (recursive) {
        NSUInteger count = 0;
        [UIView listSubviewsOfView:self count:&count];
        return count;
    }else{
        NSUInteger count = 0;
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UIView class]] &&
                [subview conformsToProtocol:@protocol(UILayoutSupport)] == NO) {
                count++;
            }
        }
        return count;
    }
}

+ (void)listSubviewsOfView:(UIView *)view count:(NSUInteger *)count
{
    NSArray *subviews = [view subviews];

    if ([subviews count] == 0) return; // COUNT CHECK
    
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[UIView class]] &&
            [subview conformsToProtocol:@protocol(UILayoutSupport)] == NO) {
            *count = *count + 1;
            [self listSubviewsOfView:subview count:count];
        }
    }
}



@end
