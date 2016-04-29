//
//  UIView+Recursive.h
//  LeaksInspector
//
//  Created by linyu on 3/9/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Recursive)

+ (void)listSubviewsOfView:(UIView *)view count:(NSUInteger *)count;

- (NSUInteger)subviewsCount:(BOOL)recursive;

- (NSArray *)subviewsWithoutLayoutSupport;

@end
