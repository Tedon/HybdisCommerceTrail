//
// HYBMainMenuView.m
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

#import <Classy/CASStyleableItem.h>
#import <BlocksKit/NSArray+BlocksKit.h>
#import <ClassyLiveLayout/SHPAbstractView.h>
#import "HYBMainMenuView.h"
#import "UIView+HYBBase.h"
#import "UILabel+HYBLabel.h"
#import "HYBCustButton.h"


@implementation HYBMainMenuView {
    NSMutableArray *_menuOptions;
}

/**
 *  generate view layout
 */
- (void)addSubviews {

    NSArray *sideBarNavigation = @[
            NSLocalizedString(@"sidebar_dashboard", @"Sidebar navigation item"),
            NSLocalizedString(@"sidebar_orders", @"Orders navigation item"),
            NSLocalizedString(@"sidebar_catalog", @"Catalog navigation Item"),
            NSLocalizedString(@"sidebar_account", @"Account navigation item"),
           [NSLocalizedString(@"sidebar_logout", @"Logout navigation item") uppercaseString]
    ];

    NSArray *sideBarImages = @[
            @"B2BIcon_dashboard.png",
            @"B2BIcon_orders.png",
            @"B2BIcon_catalog.png",
            @"B2BIcon_account.png",
            @"B2BIcon_logout.png",
    ];

    NSArray *accessIds = @[
            @"ACCESS_MAIN_MENU_ITEM_DASHBOARD",
            @"ACCESS_MAIN_MENU_ITEM_ORDERS",
            @"ACCESS_MAIN_MENU_ITEM_CATALOG",
            @"ACCESS_MAIN_MENU_ITEM_ACCOUNT",
            @"ACCESS_MAIN_MENU_ITEM_LOGOUT",
    ];

    _menuOptions = [[NSMutableArray alloc] initWithCapacity:sideBarNavigation.count];

    for (int i = 0; i < sideBarNavigation.count; ++i) {

        UIView *menuOptionView = [[UIView alloc] initWithStyleClassId:@"menuOption"];

        NSString *specificStyle = [NSString stringWithFormat:@"option_%d", i];
        [menuOptionView cas_addStyleClass:specificStyle];
        menuOptionView.tag = i;
        menuOptionView.accessibilityIdentifier = [accessIds objectAtIndex:i];
        menuOptionView.userInteractionEnabled = YES;

        UIImage *image = [UIImage imageNamed:[sideBarImages objectAtIndex:i]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [menuOptionView addSubview:imageView];

        UILabel *label = [[UILabel alloc] initWithStyleClassId:@"" text:[sideBarNavigation objectAtIndex:i]];
        [menuOptionView addSubview:label];
        
        [_menuOptions addObject:menuOptionView];
        [self addSubview:menuOptionView];
        
        if (i < sideBarNavigation.count-1) {
            UIView *borderView = [[UIView alloc] initWithStyleClassId:@"menuOptionBorder"];
            borderView.alpha = .25;
            [self addSubview:borderView];
        }
    }

    self.closedMenu = NO;
    self.cas_styleClass = @"freesize";
    self.accessibilityIdentifier = @"ACCESS_MAIN_MENU";
}

- (void)defineLayout {
    for (int i = 0; i < _menuOptions.count; i++) {
        UIView *view = [_menuOptions objectAtIndex:i];
        if (i == _menuOptions.count - 1) {
            // horizontal layout for the logout menu item
            [view layoutSubviewsHorizontally];
        } else {
            [view layoutSubviewsHorizontally];
        }
    }
    [self layoutSubviewsVertically];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)registerForMenuTapAction:(id)target withAction:(SEL)action {
    [_menuOptions bk_each:^(UIView *option) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target
                                                                                        action:action];
        [option addGestureRecognizer:tapRecognizer];
    }];
}
@end