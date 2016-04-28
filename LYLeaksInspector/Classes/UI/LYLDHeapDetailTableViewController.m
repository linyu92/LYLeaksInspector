//
//  LYLDHeapDetailTableViewController.m
//  LeaksInspector
//
//  Created by linyu on 3/8/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "LYLDHeapDetailTableViewController.h"

#import "LYLDResponderChainViewController.h"
#import "LYLDSnapshotViewController.h"
#import "LYLDPropertiesViewController.h"
#import "LYLDViewHierarchyController.h"
#import "LYLDViewLeakStackController.h"
#import "UIView+Recursive.h"
#import "LYHeapObjectEnumerator.h"


@interface LYLDHeapDetailTableViewController()
{
    UITextView *_headerTextView;
}

@end


@implementation LYLDHeapDetailTableViewController

#pragma mark - DataSource

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Object Inspector";

    [self setHeaderView];
    [self prepareDataSource];
}


- (void)prepareDataSource
{
    NSMutableArray *dataSource = [@[] mutableCopy];
    
    if ([self.referenClass isSubclassOfClass:[UIViewController class]]) {
        [dataSource addObject:kCellTitleResponderChain];
    }
    if ([self.referenClass isSubclassOfClass:[UIView class]] ||
        [self.referenClass isSubclassOfClass:[UIImage class]] ||
        [self.referenClass isSubclassOfClass:[UIViewController class]]) {
        [dataSource addObject:kCellTitleShow];
    }
    
    if ([self.referenClass isSubclassOfClass:[UIView class]] &&
        [self.inspectingObject subviews] != 0) {
        [dataSource addObject:kCellTitleSubviews];
    }else if([self.referenClass isSubclassOfClass:[UIViewController class]] &&
             [[self.inspectingObject view] subviews] != 0){
        [dataSource addObject:kCellTitleSubviews];
    }

    if ([self.referenClass superclass]) {
        [dataSource addObject:kCellTitleSuperClass];
    }
    
    if ([LYHeapObjectEnumerator isMayLeakObject:self.inspectingObject]) {
        [dataSource addObject:kCellTitleViewLeakStack];
    }
    
    [dataSource addObject:kCellTitleProperties];
    
    self.dataSource = dataSource;
    [self.tableView reloadData];
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


- (NSUInteger)inspectObjSubviewCount:(BOOL)recursive
{
    if ([self.referenClass isSubclassOfClass:[UIView class]]) {
        return [self.inspectingObject subviewsCount:recursive];
    }else if([self.referenClass isSubclassOfClass:[UIViewController class]]){
        return [[self.inspectingObject view] subviewsCount:recursive];
    }
    
    return 0;
}

#pragma mark - UITableview dataSource & Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLYLDTableViewCellIdentifier
                                                            forIndexPath:indexPath];
    
    NSString *item = self.dataSource[indexPath.row];
    if ([item isEqualToString:kCellTitleSubviews]) {
        NSString *detail = [NSString stringWithFormat:@"total:%lu --- subviews:%lu",[self inspectObjSubviewCount:YES],[self inspectObjSubviewCount:NO]];
        cell.detailTextLabel.text = detail;
    }else{
        cell.detailTextLabel.text = nil;
    }
    
    if ([item isEqualToString:kCellTitleViewLeakStack]) {
        cell.textLabel.textColor = [UIColor redColor];
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.textLabel.text = item;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *targetController = nil;
    NSString *item = self.dataSource[indexPath.row];
    if ([item isEqualToString:kCellTitleResponderChain]) {
        targetController = [[LYLDResponderChainViewController alloc] initWithObject:self.inspectingObject];
    }
    else if ([item isEqualToString:kCellTitleShow]) {
        targetController = [[LYLDSnapshotViewController alloc] initWithObject:self.inspectingObject];
    }
    else if ([item isEqualToString:kCellTitleProperties]) {
        targetController = [[LYLDPropertiesViewController alloc] initWithObject:self.inspectingObject Class:self.referenClass];
    }
    else if ([item isEqualToString:kCellTitleSuperClass]) {
        targetController = [[LYLDHeapDetailTableViewController alloc] initWithObject:self.inspectingObject Class:[self.referenClass superclass]];
    }
    else if([item isEqualToString:kCellTitleSubviews]){
        UIView *targetView = nil;
        if ([self.referenClass isSubclassOfClass:[UIView class]]) {
            targetView = self.inspectingObject;
        }else if([self.referenClass isSubclassOfClass:[UIViewController class]]){
            targetView = [self.inspectingObject view];
        }
        
        if (tableView) {
            targetController = [[LYLDViewHierarchyController alloc] initWithObject:targetView];
        }
    }
    else if ([item isEqualToString:kCellTitleViewLeakStack]) {
        targetController = [[LYLDViewLeakStackController alloc] initWithDataSource:[LYHeapObjectEnumerator heapStackForMayLeakObject:self.inspectingObject]];        
    }
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//        NSString *recursiveDesc = [self.inspectingObject performSelector:@selector(recursiveDescription)];
//        targetController = [[HINSPShowViewController alloc] initWithObject:recursiveDesc];
//        ((HINSPShowViewController *)targetController).shouldShowEditButton = NO;
//    } else if ([item isEqualToString:kCellTitleReferenceHistory]) {
//        targetController = [[HINSPRefHistoryTableViewController alloc] initWithObject:self.inspectingObject];
//    }
//#pragma clang diagnostic pop
    [self.navigationController pushViewController:targetController animated:YES];
}


@end
