//
//  LeaksDebugWidget.m
//  LeaksInspector
//
//  Created by linyu on 3/8/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "LYLeaksDebugWindow.h"

static const CGFloat kContentViewWidth = 44;
static const CGFloat kContentViewHeight = 44;




@interface LYLeaksDebugWindow()
{
    UIView *_contentView;
    UIPanGestureRecognizer *_panGesture;
}
@end

@implementation LYLeaksDebugWindow

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self doInitSubViews];
        [self doRegisterNotifications];
    }
    return self;
}

- (void)doInitSubViews
{
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, kContentViewWidth, kContentViewHeight)];
    [self addSubview:_contentView];
    
    CGRect rect = CGRectInset(_contentView.bounds, 4, 4);
    _presentButton = [[UIButton alloc] initWithFrame:rect];
    _presentButton.backgroundColor = [UIColor whiteColor];
    _presentButton.layer.cornerRadius = 4;
    _presentButton.layer.masksToBounds = YES;
    _presentButton.alpha = 0.5;
    [_contentView addSubview:_presentButton];
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
    [_contentView addGestureRecognizer:_panGesture];
}

- (void)doRegisterNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onkLeaksInspectorWarnNotification:) name:kLeaksInspectorWarnNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onkLeaksWarnClearNotification:) name:kLeaksWarnClearNotification object:nil];
}

- (void)onkLeaksInspectorWarnNotification:(NSNotification *)notification
{
    _presentButton.backgroundColor = [UIColor redColor];
}

- (void)onkLeaksWarnClearNotification:(NSNotification *)notification
{
    _presentButton.backgroundColor = [UIColor whiteColor];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL allowTouch = NO;
    if (CGRectContainsPoint(_contentView.frame, point)) {
        allowTouch = YES;
    }
    if (self.rootViewController.presentedViewController) {
        allowTouch = YES;
    }
    return allowTouch;
}

-(void)dragging:(UIPanGestureRecognizer *)gesture
{
    static CGPoint g_beginPos;
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        //NSLog(@"Received a pan gesture");
        g_beginPos = [gesture locationInView:gesture.view];
    }else if(gesture.state == UIGestureRecognizerStateChanged){
        CGPoint newCoord = [gesture locationInView:gesture.view];
        float dX = newCoord.x-g_beginPos.x;
        float dY = newCoord.y-g_beginPos.y;
        gesture.view.frame = CGRectMake(gesture.view.frame.origin.x+dX, gesture.view.frame.origin.y+dY, gesture.view.frame.size.width, gesture.view.frame.size.height);
    }else if(gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateCancelled){
        CGPoint newCoord = gesture.view.frame.origin;
        CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds);
        
        CGFloat left = newCoord.x;
        CGFloat right = width - newCoord.x;
        CGFloat up = newCoord.y;
        CGFloat down = height - newCoord.y;
        
        CGFloat min = MIN(MIN(left, right), MIN(up,down));
        if (min == left) {
            newCoord.x = 0;
        }else if(min == right){
            newCoord.x = width - _contentView.frame.size.width;
        }else if(min == up){
            newCoord.y = 0;
        }else{
            newCoord.y = height - _contentView.frame.size.height;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            gesture.view.frame = CGRectMake(newCoord.x, newCoord.y, gesture.view.frame.size.width, gesture.view.frame.size.height);
        }];
    }
    
}

@end
