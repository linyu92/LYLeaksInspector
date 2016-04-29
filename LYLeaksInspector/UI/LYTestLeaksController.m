//
//  LYTestLeaksController.m
//  LeaksInspector
//
//  Created by linyu on 3/9/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "LYTestLeaksController.h"
#import "LYTestLeaksView.h"
@implementation LYTestLeaksController
{
    NSTimer *_timer;
}

- (void)dealloc{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    LYTestLeaksView *view = [[LYTestLeaksView alloc] init];
    [self.view addSubview:view];
//    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
//    [_timer fire];
//    
//    // This will create a retain cycle
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
//                                                      object:nil queue:[NSOperationQueue mainQueue]
//                                                  usingBlock:^(NSNotification *note) {
//                                                      [_timer invalidate];
//                                                  }];
}

@end
