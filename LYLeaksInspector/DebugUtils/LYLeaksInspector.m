//
//  LeaksInpectorDebug.m
//  LeaksInspector
//
//  Created by linyu on 3/8/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "LYLeaksInspector.h"
#import "NSObject+MRCDeallocInspect.h"
#import "LYHeapObjectEnumerator.h"
#import "LYLDHeapStackTableViewController.h"
#import "LYLeaksDebugWindow.h"
#import "LYLDWindowController.h"
#import "LYNotificationMapper.h"
#import <UIKit/UIKit.h>




static LYLeaksInspector *g_twDebug = nil;

@interface LYLeaksInspector()
{
    LYLeaksDebugWindow *_window;
    UIViewController *_rootViewController;
}
@end

@implementation LYLeaksInspector

- (instancetype)init
{
    self = [super init];
    if (self) {
        CGRect rect = [UIScreen mainScreen].bounds;
        LYLeaksDebugWindow *window = [[LYLeaksDebugWindow alloc] initWithFrame:rect];
        window.windowLevel = UIWindowLevelStatusBar + 50;
        [window setHidden:NO];
        [window.presentButton addTarget:self action:@selector(onPresentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _window = window;
        
        LYLDWindowController *rootViewController = [[LYLDWindowController alloc] init];
        rootViewController.view.alpha = 0.0;
        _rootViewController = rootViewController;
        _window.rootViewController = rootViewController;
    }
    return self;
}

- (void)onPresentButtonClick:(UIButton *)sender
{
    NSArray *livings = [[LYHeapObjectEnumerator livingsVCHeapStack] allObjects];
    NSArray *leaksObj = [[LYHeapObjectEnumerator leakObjAddressPairs] allObjects];
    NSArray *leaksNotify = [[LYNotificationMapper shared] allLeakNotifications];;
    LYLDHeapStackTableViewController *controller = [self heapStackControllerWithLivingVC:livings leaksObj:leaksObj leaksNotify:leaksNotify];
    controller.title = @"Heap";
}

- (LYLDHeapStackTableViewController *)heapStackControllerWithLivingVC:(NSArray *)livings leaksObj:(NSArray *)leaksobj leaksNotify:(NSArray *)leaksnotify
{
    NSArray *dataSource = @[leaksobj,leaksnotify,livings];
    LYLDHeapStackTableViewController *tv = [[LYLDHeapStackTableViewController alloc] initWithDataSource:dataSource];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tv];
    [_rootViewController presentViewController:navController animated:YES completion:nil];
    
    return tv;
}

+ (void)addLeaksWhiteClass:(NSString *)classname
{
    AddLeaksInspectorWhiteListClass(classname);
}

+ (void)active
{
#if LYLeaksDebugActive
    [LYHeapObjectEnumerator updateRegisteredClasses];        
    g_twDebug = [[LYLeaksInspector alloc] init];
#endif
}

+ (BOOL)isActive
{
    if (g_twDebug) {
        return YES;
    }else{
        return NO;
    }
}
@end
