//
//  LeaksTableViewController.h
//  LeaksInspector
//
//  Created by linyu on 3/8/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYLDTableViewCell.h"
#import "UIView+Recursive.h"

extern CGFloat const kLYLDTableHeaderViewHeight;

extern NSString *const kCellTitleShow;
extern NSString *const kCellTitleResponderChain;
extern NSString *const kCellTitleProperties;
extern NSString *const kCellTitleSuperClass;
extern NSString *const kCellTitleSubviews;
extern NSString *const kCellTitleViewLeakStack;

@interface LYLDTableViewController : UITableViewController

@property (nonatomic, readonly) Class referenClass;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, readonly) NSArray *dataSourceUnfiltered;
@property (nonatomic, strong) id inspectingObject;

- (instancetype)initWithObject:(id)object;
- (instancetype)initWithObject:(id)object Class:(Class)classname;

- (instancetype)initWithPointerString:(NSString *)pointer;
- (instancetype)initWithDataSource:(NSArray *)dataSource;

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar;
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;

@end
