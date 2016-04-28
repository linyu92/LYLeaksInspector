//
//  LYLDViewHierarchyController.m
//  LeaksInspector
//
//  Created by linyu on 3/9/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "LYLDViewHierarchyController.h"
#import "LYLDSnapshotViewController.h"
#import "LYLDPropertiesViewController.h"
#import "LYLDHeapDetailTableViewController.h"

@interface LYLDViewHierarchyController()
{
    UITextView *_headerTextView;
}
@end

@implementation LYLDViewHierarchyController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Object Inspector";
    
    [self setHeaderView];
    [self prepareDataSource];
}


- (void)prepareDataSource
{
    NSMutableArray *detailSection = [@[] mutableCopy];
    [detailSection addObject:kCellTitleShow];
    [detailSection addObject:kCellTitleSuperClass];
    [detailSection addObject:kCellTitleProperties];

    NSArray *subview = [self.inspectingObject subviewsWithoutLayoutSupport];;
    
    self.dataSource = @[detailSection,subview];
    [self.tableView reloadData];
    //
}


- (void)setHeaderView
{
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    _headerTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, width, kLYLDTableHeaderViewHeight)];
    _headerTextView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.7];
    _headerTextView.textAlignment = NSTextAlignmentCenter;
    self.tableView.tableHeaderView = _headerTextView;
    
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendFormat:@"Referen Class:%@\n\n",NSStringFromClass(self.referenClass)];
    [string appendString:[self.inspectingObject description]];
    _headerTextView.text = string;
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
        return @"Details";
    }else{
        return @"Subviews";
    }
}
#pragma mark - UITableview dataSource & Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLYLDTableViewCellIdentifier
                                                            forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        NSString *item = self.dataSource[indexPath.section][indexPath.row];
        cell.textLabel.text = item;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        UIView *view = self.dataSource[indexPath.section][indexPath.row];
        
        NSString *detail = [NSString stringWithFormat:@"total:%lu --- subviews:%lu",[view subviewsCount:YES],[view subviewsCount:NO]];
        cell.detailTextLabel.text = detail;
        cell.textLabel.text = NSStringFromClass([view class]);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *targetController = nil;;

    if (indexPath.section == 0) {
        NSString *item = self.dataSource[indexPath.section][indexPath.row];
        if ([item isEqualToString:kCellTitleShow]) {
            targetController = [[LYLDSnapshotViewController alloc] initWithObject:self.inspectingObject];
        }
        else if ([item isEqualToString:kCellTitleProperties]) {
            targetController = [[LYLDPropertiesViewController alloc] initWithObject:self.inspectingObject Class:self.referenClass];
        }
        else if ([item isEqualToString:kCellTitleSuperClass]) {
            targetController = [[LYLDHeapDetailTableViewController alloc] initWithObject:self.inspectingObject Class:[self.referenClass superclass]];
        }
    }else{
        UIView *targetView = self.dataSource[indexPath.section][indexPath.row];
        targetController = [[LYLDViewHierarchyController alloc] initWithObject:targetView];
    }
    [self.navigationController pushViewController:targetController animated:YES];
 }


@end
