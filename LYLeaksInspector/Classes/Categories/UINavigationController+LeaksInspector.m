//
//  UINavigationController+LeaksInspector.m
//  LeaksInspector
//
//  Created by linyu on 3/9/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "UINavigationController+LeaksInspector.h"
#import "NSObject+LeaksInspector.h"
#import "UIViewController+LeaksInspector.h"
#import <objc/runtime.h>
#import "LYLeaksInspector.h"

#if LYLeaksDebugActive

@implementation UINavigationController (LeaksInspector)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SwizzleInstanceMethod([self class], @selector(pushViewController:animated:), @selector(swizzled_pushViewController:animated:));
        SwizzleInstanceMethod([self class], @selector(popViewControllerAnimated:), @selector(swizzled_popViewControllerAnimated:));
        SwizzleInstanceMethod([self class], @selector(popToViewController:animated:), @selector(swizzled_popToViewController:animated:));
        SwizzleInstanceMethod([self class], @selector(popToRootViewControllerAnimated:), @selector(swizzled_popToRootViewControllerAnimated:));
    });
}

- (void)swizzled_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self swizzled_pushViewController:viewController animated:animated];
}

- (UIViewController *)swizzled_popViewControllerAnimated:(BOOL)animated {
    UIViewController *poppedViewController = [self swizzled_popViewControllerAnimated:animated];

    if ([LYLeaksInspector isActive] && poppedViewController) {
        objc_setAssociatedObject(poppedViewController, kHasBeenPoppedKey, @(YES), OBJC_ASSOCIATION_RETAIN);
    }
    
    return poppedViewController;
}
//
- (NSArray<UIViewController *> *)swizzled_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray<UIViewController *> *poppedViewControllers = [self swizzled_popToViewController:viewController animated:animated];
    
    if ([LYLeaksInspector isActive]) {
        for (UIViewController *viewController in poppedViewControllers) {
            [viewController willDealloc];
        }
    }

    return poppedViewControllers;
}
//
- (NSArray<UIViewController *> *)swizzled_popToRootViewControllerAnimated:(BOOL)animated {
    NSArray<UIViewController *> *poppedViewControllers = [self swizzled_popToRootViewControllerAnimated:animated];

    if ([LYLeaksInspector isActive]) {
        for (UIViewController *viewController in poppedViewControllers) {
            [viewController willDealloc];
        }
    }

    return poppedViewControllers;
}
//
- (BOOL)willDealloc {    
    if (![LYLeaksInspector isActive] || ![super willDealloc]) {
        return NO;
    }

    NSArray *viewStack = [self viewStack];

    for (UIViewController *viewController in self.viewControllers) {
        NSString *name = HeapObjectAddressPair(viewController);
        viewStack = [viewStack arrayByAddingObject:name];
        [viewController setViewStack:viewStack];
        [viewController willDealloc];
    }
    
    return YES;
}


@end

#endif
