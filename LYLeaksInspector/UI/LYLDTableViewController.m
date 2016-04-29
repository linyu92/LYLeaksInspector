//
//  LeaksTableViewController.m
//  LeaksInspector
//
//  Created by linyu on 3/8/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "LYLDTableViewController.h"
#import "LYHeapObjectEnumerator.h"

CGFloat const kLYLDTableHeaderViewHeight = 100;


NSString *const kCellTitleShow = @"Show";
NSString *const kCellTitleResponderChain = @"Responder Chain";
NSString *const kCellTitleProperties = @"Properties";
NSString *const kCellTitleSuperClass = @"SuperClass";
NSString *const kCellTitleSubviews = @"Subviews";
NSString *const kCellTitleViewLeakStack = @"ViewLeakStack";

@interface LYLDTableViewController () <UISearchBarDelegate>

@end

@implementation LYLDTableViewController
{
    NSArray *_originalDataSource;
    UIActivityIndicatorView *_loadingSpinner;
    BOOL _isSearching;
}

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (instancetype)initWithPointerString:(NSString *)pointer
{
    id object = [LYHeapObjectEnumerator objectForPointer:pointer];
    return [self initWithObject:object Class:[object class]];
}

- (instancetype)initWithObject:(id)object
{
    return [self initWithObject:object Class:[object class]];
}

- (instancetype)initWithObject:(id)object Class:(Class)classname
{
    self = [self init];
    if (self) {
        self.inspectingObject = object;
        _referenClass = classname;
    }
    return self;
}

- (instancetype)initWithDataSource:(NSArray *)dataSource
{
    self = [self init];
    if (self) {
        // Retrieve a real object from the pointer
        self.dataSource = dataSource;
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupSearchBar];
    [self.tableView registerClass:[LYLDTableViewCell class] forCellReuseIdentifier:kLYLDTableViewCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_isSearching) {
        [self.tableView.tableHeaderView becomeFirstResponder];
    }
}

- (void)setupSearchBar
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    CGRect frame = searchBar.frame;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = 44.0f;
    searchBar.frame = frame;
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
    
    _loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_loadingSpinner hidesWhenStopped];
    _loadingSpinner.frame = CGRectMake(11, 11, 20, 20);
    [self.tableView.tableHeaderView addSubview:_loadingSpinner];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYLDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLYLDTableViewCellIdentifier forIndexPath:indexPath];
    
    NSString *value = self.dataSource[indexPath.row];
    cell.detailTextLabel.text = value;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - SeachBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if ([searchBar.text length] == 0 && !_isSearching) {
        [searchBar setShowsCancelButton:YES animated:YES];
        _dataSourceUnfiltered = self.dataSource;
        _isSearching = YES;
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if ([searchBar.text length] == 0) {
        [searchBar setShowsCancelButton:NO animated:YES];
        self.dataSource = _dataSourceUnfiltered;
        [self.tableView reloadData];
        _isSearching = NO;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.text = nil;
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.tableView.tableHeaderView bringSubviewToFront:_loadingSpinner];
    [_loadingSpinner startAnimating];
    NSMutableArray *serps = [self.dataSourceUnfiltered mutableCopy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",
                                  searchText];
        [serps filterUsingPredicate:predicate];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dataSource = serps;
            [self.tableView reloadData];
            [_loadingSpinner stopAnimating];
        });
    });
}


@end
