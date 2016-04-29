//
//  LYLDSnapshotViewController.m
//  LeaksInspector
//
//  Created by linyu on 3/8/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "LYLDSnapshotViewController.h"

@interface LYLDSnapshotViewController () <UIScrollViewDelegate>

@end

@implementation LYLDSnapshotViewController

{
    UITextView *_textView;
    UIScrollView *_scrollView;
    UIImageView *__weak _imageView;
}


#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.userInteractionEnabled = NO;
    self.tableView.tableHeaderView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self handleClassType];
}

- (void)handleClassType {
    UIImage *screenshot = nil;
    id _objectToInspect = self.inspectingObject;
    
    if ([_objectToInspect isKindOfClass:[UIImage class]]) {
        screenshot = _objectToInspect;
    } else if ([_objectToInspect isKindOfClass:[UIView class]]) {
        screenshot = [self screenshotOfView:_objectToInspect];
    } else if ([_objectToInspect isKindOfClass:[UIViewController class]] &&
               [_objectToInspect isViewLoaded]) {
        screenshot = [self screenshotOfView:[_objectToInspect view]];
    } else if ([_objectToInspect isKindOfClass:[NSString class]] ||
               [_objectToInspect isKindOfClass:[NSAttributedString class]]) {
        UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _textView = textView;
        [self.view addSubview:textView];
        
        if ([_objectToInspect isKindOfClass:[NSString class]]) {
            textView.text = _objectToInspect;
        } else if ([_objectToInspect isKindOfClass:[NSAttributedString class]]) {
            textView.attributedText = _objectToInspect;
        }
    }
    
    if (screenshot) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:screenshot];
        CGSize size = screenshot.size;
        imageView.bounds = CGRectMake(0.0,0.0,size.width,size.height);
        [_scrollView addSubview:imageView];
        _scrollView.contentSize = CGSizeMake(screenshot.size.width, screenshot.size.height);
        _imageView = imageView;
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomInOrOut:)];
        gesture.numberOfTapsRequired = 2;
        [imageView addGestureRecognizer:gesture];
        imageView.userInteractionEnabled = YES;
        [self setZoomScaleAnimated:NO];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self setZoomScaleAnimated:YES];
}

- (void)setZoomScaleAnimated:(BOOL)animated
{
    if (!_scrollView.isZooming) {
        CGFloat scale = 1.0;
        if (_imageView.image.size.width > _scrollView.bounds.size.width) {
            scale = _scrollView.bounds.size.width / _imageView.image.size.width;
            _scrollView.minimumZoomScale = scale;
            [_scrollView setZoomScale:scale animated:animated];
        }
    }
}


#pragma mark - Zoom

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)zoomInOrOut:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (_scrollView.zoomScale == _scrollView.minimumZoomScale) {
            [_scrollView setZoomScale:1.0 animated:YES];
        } else {
            [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
        }
    }
}

#pragma mark - Helper

- (UIImage *)screenshotOfView:(UIView *)view
{
    CALayer *layer = [view layer];
    CGRect bounds = layer.bounds;
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    [layer renderInContext:context];
    CGContextRestoreGState(context);
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}


@end
