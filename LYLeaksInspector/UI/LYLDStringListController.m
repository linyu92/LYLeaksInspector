//
//  LYLDStringListController.m
//  ourtimes
//
//  Created by linyu on 3/14/16.
//  Copyright © 2016 YY. All rights reserved.
//

#import "LYLDStringListController.h"

@implementation LYLDStringListController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = nil;
}


#pragma mark - UITableView dataSource & Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLYLDTableViewCellIdentifier
                                                            forIndexPath:indexPath];
    
    NSString *content = self.dataSource[indexPath.row];

    cell.textLabel.textColor = [UIColor redColor];
    cell.textLabel.text = content;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
