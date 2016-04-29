//
//  LYLDTableViewCell.m
//  LeaksInspector
//
//  Created by linyu on 3/8/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "LYLDTableViewCell.h"

NSString *const kLYLDTableViewCellIdentifier = @"LYLDTableViewCellIdentifier";

@implementation LYLDTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.font = [UIFont systemFontOfSize:12];
        self.detailTextLabel.font = [UIFont systemFontOfSize:10];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
