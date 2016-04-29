//
//  LYTestLeaksView.m
//  LeaksInspector
//
//  Created by linyu on 3/10/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "LYTestLeaksView.h"

@implementation LYTestLeaksView
{
    NSTimer *_timer;    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (id)init{
    self = [super init];
    if (self) {
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        [_timer fire];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTest:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTest2:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
    }
    return self;
}

- (void)onTest:(NSNotification *)notification
{

}

- (void)onTest2:(NSNotification *)notification
{

}

- (void)timerFired:(NSTimer *)timer
{

}

@end
