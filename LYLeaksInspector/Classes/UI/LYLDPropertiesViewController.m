//
//  LYLDPropertiesViewController.m
//  LeaksInspector
//
//  Created by linyu on 3/9/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "LYLDPropertiesViewController.h"
#import "LYLDHeapDetailTableViewController.h"
#import <objc/runtime.h>
#import "NSObject+MRCInstanceValue.h"

@interface LYLDPropertiesViewController()
{
    NSMutableArray *_ivalsObject;
}
@end

@implementation LYLDPropertiesViewController


#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepareDataSource];
}

#pragma mark - DataSources

- (void)prepareDataSource
{

    NSArray *properties = [self retrieveProperties];
    NSArray *ivals = [self retrieveIvars];
    
    self.dataSource = @[properties,ivals];
    [self.tableView reloadData];
}

- (NSArray *)retrieveProperties
{
    // Retrieve self's properties
    NSMutableOrderedSet *selProperties = [[NSMutableOrderedSet alloc] init];
    unsigned int mc = 0;
    objc_property_t *selflist = class_copyPropertyList(self.referenClass, &mc);
    for(int i = 0; i < mc; i++) {

        NSString *signature = [NSString stringWithUTF8String:property_getName(selflist[i])];
        if (signature) {
            [selProperties addObject:signature];
        }
    }
    NSArray *section = [[selProperties array] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

    free(selflist);
    
    return section;
}

- (NSArray *)retrieveIvars
{
    NSMutableOrderedSet *selfIvars = [[NSMutableOrderedSet alloc] init];
    unsigned int mc = 0;
    Ivar *selflist = class_copyIvarList(self.referenClass, &mc);
    // Retrieve self's methods
    for(int i = 0; i < mc; i++) {
        NSString *signature = [NSString stringWithUTF8String:ivar_getName(selflist[i])];
        if (signature) {
            [selfIvars addObject:signature];
        }
    }
    
    NSArray *section = [[selfIvars array] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    free(selflist);
    
    return section;
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
        return @"Properties";
    }else{
        return @"iVars";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLYLDTableViewCellIdentifier forIndexPath:indexPath];
    
    NSString *item = self.dataSource[indexPath.section][indexPath.row];
    cell.textLabel.text = item;
    
    if ([self.inspectingObject instanceVariableForKey:item]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *item = self.dataSource[indexPath.section][indexPath.row];

    id newInspectingObject = [self.inspectingObject instanceVariableForKey:item];

    if (newInspectingObject) {
        LYLDHeapDetailTableViewController *detailVC = nil;
        detailVC = [[LYLDHeapDetailTableViewController alloc] initWithObject:newInspectingObject];
        [self.navigationController pushViewController:detailVC animated:YES];
    } else {
        NSString *typeString = (indexPath.row == 0) ? @"Property" : @"iVar";
        NSString *message = [NSString stringWithFormat:@"%@ is nil",typeString];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"nil"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
