//
// HYBCatalogMenuView.m
// [y] hybris Platform
//
// Copyright (c) 2000-2014 hybris AG
// All rights reserved.
//
// This software is the confidential and proprietary information of hybris
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with hybris.
//
#import <ClassyLiveLayout/SHPAbstractView.h>
#import "HYBCatalogMenuView.h"
#import "UIView+HYBBase.h"
#import "HYBCatalogView.h"
#import "HYBCustButton.h"


@implementation HYBCatalogMenuView

/**
 *  generate view layout
 */
- (void)addSubviews {
    
    UIView *spacer = [[UIView alloc] initWithStyleClassId:@"catalogMenuSpacer"];
    [self addSubview:spacer];
    
    self.categoriesTable = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    [self.categoriesTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    self.categoriesTable.accessibilityIdentifier = @"ACCESS_CATALOGMENU";
    self.categoriesTable.allowsMultipleSelection = NO;
    self.categoriesTable.cas_styleClass = @"freesize";
    [self.categoriesTable registerClass:[UITableViewCell class] forCellReuseIdentifier:CATEGORIES_MENU_CELL_ID];
    self.categoriesTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self addSubview:self.categoriesTable];
}

- (void)defineLayout {
    [self layoutSubviewsVertically];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end