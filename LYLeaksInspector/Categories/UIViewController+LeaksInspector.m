//
//  UIViewController+LeaksInspector.m
//  LeaksInspector
//
//  Created by linyu on 3/9/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "UIViewController+LeaksInspector.h"
#import "UIView+LeaksInspector.h"
#import "NSObject+LeaksInspector.h"
#import <objc/runtime.h>
#import "LYLeaksInspector.h"
const void *const kHasBeenPoppedKey = &kHasBeenPoppedKey;

#if LYLeaksDebugActive

@implementation UIViewController (LeaksInspector)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SwizzleInstanceMethod([self class], @selector(viewDidDisappear:), @selector(swizzled_viewDidDisappear:));
        SwizzleInstanceMethod([self class], @selector(viewWillAppear:), @selector(swizzled_viewWillAppear:));
        SwizzleInstanceMethod([self class], @selector(dismissViewControllerAnimated:completion:), @selector(swizzled_dismissViewControllerAnimated:completion:));
    });
}

- (void)swizzled_viewDidDisappear:(BOOL)animated {
    [self swizzled_viewDidDisappear:animated];
    
    if ([LYLeaksInspector isActive]) {
        if ([objc_getAssociatedObject(self, kHasBeenPoppedKey) boolValue]) {
            [self willDealloc];
        }
    }
    
}

- (void)swizzled_viewWillAppear:(BOOL)animated {
    [self swizzled_viewWillAppear:animated];

    if ([LYLeaksInspector isActive]) {
        objc_setAssociatedObject(self, kHasBeenPoppedKey, @(NO), OBJC_ASSOCIATION_RETAIN);
    }
    
}

- (void)swizzled_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self swizzled_dismissViewControllerAnimated:flag completion:completion];
    
    if ([LYLeaksInspector isActive]) {
        UIViewController *dismissedViewController = self.presentedViewController;
        if (!dismissedViewController && self.presentingViewController) {
            dismissedViewController = self;
        }
        
        if (!dismissedViewController) return;
        
        [dismissedViewController willDealloc];
    }

}

- (BOOL)willDealloc {
    if (![LYLeaksInspector isActive] || ![super willDealloc]) {
        return NO;
    }
    
    NSArray *viewStack = [self viewStack];
    
    for (UIViewController *viewController in self.childViewControllers) {
        NSString *name = HeapObjectAddressPair(viewController);
        [viewController setViewStack:[viewStack arrayByAddingObject:name]];
        [viewController willDealloc];
    }
    
    UIViewController *presentedViewController = self.presentedViewController;
    if (presentedViewController) {
        NSString *name = HeapObjectAddressPair(presentedViewController);
        [presentedViewController setViewStack:[viewStack arrayByAddingObject:name]];
        [presentedViewController willDealloc];
    }

    if ([self isViewLoaded]) {
        NSString *name = HeapObjectAddressPair(self.view);
        [self.view setViewStack:[viewStack arrayByAddingObject:name]];
        [self.view willDealloc];
    }
    
    return YES;
}

@end

#endif

