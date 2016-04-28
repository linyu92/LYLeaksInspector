//
//  LYViewController.m
//  LYLeaksInspector
//
//  Created by levi92 on 04/26/2016.
//  Copyright (c) 2016 levi92. All rights reserved.
//

#import "LYViewController.h"
#import "LYTestLeaksController.h"
@interface LYViewController ()
- (IBAction)onButtonClick:(id)sender;

@end

@implementation LYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButtonClick:(id)sender {
    LYTestLeaksController *vc = [[LYTestLeaksController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
