//
// UIViewController+HYBaseController.h
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

#import <Foundation/Foundation.h>

@class MMDrawerController;
@class HYBAppDelegate;
@class HYBLoginViewController;
@class HYBDashboardController;
@class HYBCategory;
@class OLGhostAlertView;
@class HYBBarButtonItem;
@class HYBOrder;

@interface UIViewController (HYBBaseController)

@property(nonatomic, strong) NSString *firstResponderOriginalValue;

@property OLGhostAlertView *notifier;

#pragma mark navigation
- (void)navigateToCatalogFromMainMenu;

- (void)navigateToCatalogAndToggleRightDrawer:(BOOL)toggleRightDrawer triggerSearch:(BOOL)triggerSearch;

- (void)navigateToCatalogAndToggleRightDrawer:(BOOL)toggleRightDrawer triggerSearch:(BOOL)triggerSearch fromMainMenu:(BOOL)fromMain;

- (void)navigateToDetailControllerWithProduct:(NSString *)code toggleDrawer:(BOOL)toggleDrawer;

- (void)navigateToCheckout;

- (void)navigateToOrderConfirmationWithOrder:(HYBOrder *)order;

- (void)navigateToLogout;

- (void)navigateToMainMenu;

- (void)navigateToDashboard;

- (void)openCategoryInCatalog:(HYBCategory *)category;

#pragma mark cart management
- (void)updateCart;

- (void)registerForCartChangeNotifications:(SEL)methodToCall senderObject:(id)senderObject;

- (void)observeCartUpdatesAndShowInHeader;

- (void)cartIconTapped;

#pragma mark minor functions
- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title cancelButtonText:(NSString *)cancelButtonText;

- (void)leftDrawerButtonPress:(id)sender;

- (void)showNotifyMessage:(NSString *)msg;

- (HYBAppDelegate *)getDelegate;

- (void)keyboardDidShow:(NSNotification *)notification;

- (void)keyboardDidHide:(NSNotification *)notification;

- (void)updateSearchIconState;

@end