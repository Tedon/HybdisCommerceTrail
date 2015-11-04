//
// HYBMainMenuController.m
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


#import "HYBMainMenuController.h"
#import "HYBMainMenuView.h"
#import "HYB2BService.h"

#define NAVIGATE_TO_DASHBOARD   0
#define NAVIGATE_TO_ORDERS      1
#define NAVIGATE_TO_CATALOG     2
#define NAVIGATE_TO_ACCOUNT     3
#define NAVIGATE_TO_LOGOUT      4

@interface HYBMainMenuController ()

@end

@implementation HYBMainMenuController {
}

- (instancetype)initWithBackEndService:(id <HYBBackEndFacade>)backEndService {
    if (self = [super initWithBackEndService:backEndService]) {

    }
    return self;
}

- (void)loadView {
    [super loadView];

    if (!self.mainView) {
        self.mainView = [[HYBMainMenuView alloc] init];
        self.mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    self.view = self.mainView;

    [self.mainView registerForMenuTapAction:self withAction:@selector(menuOptionTapped:)];
}

- (void)menuOptionTapped:(id)sender {
    UITapGestureRecognizer *gestureRecognizer = (UITapGestureRecognizer *) sender;

    if (gestureRecognizer.view.tag == NAVIGATE_TO_DASHBOARD) {
        _mainView.closedMenu = YES;
        [self navigateToDashboard];
    }
    if (gestureRecognizer.view.tag == NAVIGATE_TO_CATALOG) {
        _mainView.closedMenu = NO;

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:STORAGE_CURRENTLY_SHOWN_CATEGORY_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self navigateToCatalogFromMainMenu];
    }
    if (gestureRecognizer.view.tag == NAVIGATE_TO_LOGOUT) {
        _mainView.closedMenu = YES;
        [self navigateToLogout];
    }
}

- (BOOL)isClosedMenu {
    return _mainView.closedMenu;
}
@end
