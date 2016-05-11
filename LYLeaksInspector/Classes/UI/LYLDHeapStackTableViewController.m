//
//  LYLDHeapStackTableViewController.m
//  LeaksInspector
//
//  Created by linyu on 3/8/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "LYLDHeapStackTableViewController.h"
#import "LYLDHeapDetailTableViewController.h"
#import "LYHeapObjectEnumerator.h"
#import "LYNotificationMapper.h"
#import "LYLDTableViewCell.h"
#import "LYLDStringListController.h"

@implementation LYLDHeapStackTableViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Close"
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(closeButton:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Clean"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(cleanButton:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

#pragma mark - Actions

- (void)closeButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cleanButton:(id)sender
{
    [LYHeapObjectEnumerator cleanMayLeaks];
    [[LYNotificationMapper shared] clearAllLeakNotifications];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLeaksWarnClearNotification object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView dataSource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionDataSource = self.dataSource[section];
    return [sectionDataSource count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"View Leaks";
    }else if(section == 1){
        return @"Notification Leaks";
    }else{
        return @"Alive ViewControllers";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLYLDTableViewCellIdentifier
                                                            forIndexPath:indexPath];
    
    id cellValue = self.dataSource[indexPath.section][indexPath.row];
    
    if (indexPath.section == 1) {
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.text = [self textValueForCellObj:cellValue];
    }else{
        if ([LYHeapObjectEnumerator isMayLeakObjectWithAddressPair:cellValue]) {
            cell.textLabel.textColor = [UIColor redColor];
        }else{
            cell.textLabel.textColor = [UIColor blackColor];
        }
        cell.textLabel.text = [self textValueForCellObj:cellValue];
        
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        id cellValue = self.dataSource[indexPath.section][indexPath.row];
        if ([cellValue isKindOfClass:[NSDictionary class]]) {
            NSSet *set = [cellValue objectForKey:LYKey_Notifications];
            LYLDStringListController *vc = [[LYLDStringListController alloc] initWithDataSource:[set allObjects]];
            vc.title = @"Notificaions";
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
        NSString *cellValue = self.dataSource[indexPath.section][indexPath.row];
        NSString *pointerValue = [self pointerStringFromAddressPair:cellValue];
        LYLDHeapDetailTableViewController *detailVC = nil;
        detailVC = [[LYLDHeapDetailTableViewController alloc] initWithPointerString:pointerValue];
        if (detailVC == nil) {
            UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"object has been release!" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertview show];
        }else{
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }
}


#pragma mark - Helper

- (NSString *)textValueForCellObj:(id)cellObj
{
    if ([cellObj isKindOfClass:[NSString class]]) {
        return cellObj;
    }else if([cellObj isKindOfClass:[NSDictionary class]]){
        return [cellObj objectForKey:LYKey_ObjectAddress];
    }else{
        return @"";
    }
}

- (NSString *)pointerStringFromAddressPair:(id)pair
{
    if ([pair isKindOfClass:[NSString class]]) {
        NSArray *components = [pair componentsSeparatedByString:@": "];
        
        return [components lastObject];
    }
    return nil;
}



@end
