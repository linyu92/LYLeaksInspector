//
//  LYLDResponderChainViewController.m
//  LeaksInspector
//
//  Created by linyu on 3/8/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "LYLDResponderChainViewController.h"
#import "LYLDHeapDetailTableViewController.h"
#import "NSObject+MRCDeallocInspect.h"

@implementation LYLDResponderChainViewController

#pragma mark - Init

- (instancetype)initWithObject:(id)object
{
    self = [super initWithObject:object];
    if (self) {
        
        self.title = @"Responder Chain";
        
        NSMutableArray *responders = [NSMutableArray array];
        [responders addObject:object];
        id tryResponder = [object nextResponder];
        while (tryResponder) {
            [responders addObject:tryResponder];
            tryResponder = [tryResponder nextResponder];
        }
        
        self.dataSource = responders;
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[LYLDTableViewCell class] forCellReuseIdentifier:kLYLDTableViewCellIdentifier];
    self.tableView.tableHeaderView = nil;
}


#pragma mark - UITableView dataSource & Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLYLDTableViewCellIdentifier
                                                            forIndexPath:indexPath];
    
    id object = self.dataSource[indexPath.row];
    
    NSString *content = HeapObjectAddressPair(object);
    
    cell.textLabel.text = content;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = self.dataSource[indexPath.row];
    LYLDHeapDetailTableViewController *detailVC = [[LYLDHeapDetailTableViewController alloc]
                                                         initWithObject:object];
    [self.navigationController pushViewController:detailVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
