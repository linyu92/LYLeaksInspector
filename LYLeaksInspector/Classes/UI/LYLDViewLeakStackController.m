//
//  LYLDViewStackController.m
//  ourtimes
//
//  Created by linyu on 3/11/16.
//  Copyright © 2016 YY. All rights reserved.
//

#import "LYLDViewLeakStackController.h"
#import "LYHeapObjectEnumerator.h"


@implementation LYLDViewLeakStackController


#pragma mark - Init

- (instancetype)initWithObject:(id)object
{
    self = [super initWithObject:object];
    if (self) {
        
        self.title = @"Leaks Stack";
        
    }
    return self;
}

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

    
    if ([LYHeapObjectEnumerator objectForAddressPair:content] == nil) {
        cell.detailTextLabel.text = @"dealloc";
        cell.detailTextLabel.textColor = [UIColor redColor];
    }else{
        cell.detailTextLabel.text = @"alive";
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }

    cell.textLabel.text = content;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}


@end
