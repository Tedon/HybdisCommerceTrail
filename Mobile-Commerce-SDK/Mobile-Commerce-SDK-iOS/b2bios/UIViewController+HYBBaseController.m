//
// UIViewController+HYBaseController.m
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


#import <MMDrawerController/MMDrawerController.h>
#import <BBBadgeBarButtonItem/BBBadgeBarButtonItem.h>
#import "UIViewController+HYBBaseController.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "HYBAppDelegate.h"
#import "UIViewController+MMDrawerController.h"
#import "HYBLoginViewController.h"
#import "HYBBarButtonItem.h"
#import "HYBDashboardController.h"
#import "HYBCatalogController.h"
#import "OLGhostAlertView.h"
#import "HYBCatalogMenuController.h"
#import "HYB2BService.h"
#import "HYBMainMenuController.h"
#import "HYBCategory.h"
#import "HYBProductDetailsController.h"
#import "HYBCartController.h"
#import "HYBCart.h"
#import "HYBCheckoutController.h"
#import "HYBOrderConfirmationController.h"

#define  MAX_WIDTH_LEFT_DRAWER     [[UIScreen  mainScreen]  bounds].size.width  *  0.3
#define  MAX_WIDTH_RIGHT_DRAWER    [[UIScreen  mainScreen]  bounds].size.width  *  0.8
#define  NAVBAR_GRID_SWITCH_TAG    11211211
#define  NAVBAR_LIST_SWITCH_TAG    11211212
#define  NAVBAR_SEARCH_SWITCH_TAG  11211213
#define  icon_height               45.f
#define  TAG_MASK_VIEW             9999999

@implementation UIViewController (HYBBaseController)

// properties on the controller category are done using 'Associated Objects'
@dynamic notifier, firstResponderOriginalValue;

- (MMDrawerController *)createDrawerWithCenter:(UINavigationController *)centerNavigationController
                                   leftSideBar:(UIViewController *)leftSideViewController
                                  rigthSideBar:(UIViewController *)rightSideViewController
                                openLeftDrawer:(BOOL)openLeftDrawer {
    
    MMDrawerController *drawerC = [[MMDrawerController alloc] initWithCenterViewController:centerNavigationController
                                                                  leftDrawerViewController:leftSideViewController
                                                                 rightDrawerViewController:rightSideViewController];
    
    [drawerC setShowsShadow:NO];
    [drawerC setShouldStretchDrawer:NO];
    [drawerC setCenterHiddenInteractionMode:MMDrawerOpenCenterInteractionModeNone];
    
    [drawerC setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeBezelPanningCenterView];//MMOpenDrawerGestureModePanningCenterView
    [drawerC setCloseDrawerGestureModeMask:(MMCloseDrawerGestureModePanningCenterView | MMCloseDrawerGestureModeTapCenterView | MMCloseDrawerGestureModeTapNavigationBar)];
    
    __weak typeof(drawerC) weakDrawerC = drawerC;
    
    [drawerC setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        MMDrawerControllerDrawerVisualStateBlock block = [[MMExampleDrawerVisualStateManager sharedManager] drawerVisualStateBlockForDrawerSide:drawerSide];
        if (block) {
            block(weakDrawerC, drawerSide, percentVisible);
        }
    }];
    
    [drawerC setMaximumLeftDrawerWidth:MAX_WIDTH_LEFT_DRAWER];
    [drawerC setMaximumRightDrawerWidth:MAX_WIDTH_RIGHT_DRAWER];
    
    [[[self getDelegate] mainNavigationController] pushViewController:drawerC animated:NO];
    
    if (openLeftDrawer) {
        [drawerC openDrawerSide:MMDrawerSideLeft animated:NO completion:nil];
    }
    
    [drawerC setGestureCompletionBlock:^(MMDrawerController *drawerController , UIGestureRecognizer *gesture) {
        
        if(drawerController.openSide == MMDrawerSideLeft){
            if([drawerController.leftDrawerViewController isKindOfClass:[HYBCatalogMenuController class]]) {
                [(HYBCatalogMenuController*)drawerController.leftDrawerViewController forceReload];
            }
        }
    }];
    
    return drawerC;
}

- (void)navigateToDashboard {
    HYBDashboardController *center = [[HYBDashboardController alloc] initWithBackEndService:[self backEndService]];
    [self renderCenter:center];
}

- (void)navigateToLogout {
    [[self backEndService] logoutCurrentUser];
    [[[self getDelegate] mainNavigationController] popToRootViewControllerAnimated:NO];
}

- (void)navigateToCatalogFromMainMenu {
    [self navigateToCatalogAndToggleRightDrawer:NO triggerSearch:NO fromMainMenu:YES];
}

- (void)navigateToCatalogAndToggleRightDrawer:(BOOL)toggleRightDrawer triggerSearch:(BOOL)triggerSearch {
    [self navigateToCatalogAndToggleRightDrawer:toggleRightDrawer triggerSearch:triggerSearch fromMainMenu:NO];
}

- (void)navigateToCatalogAndToggleRightDrawer:(BOOL)toggleRightDrawer triggerSearch:(BOOL)triggerSearch fromMainMenu:(BOOL)fromMain {
    DDLogDebug(@"Navigating to catalog controller ...");
    
    HYBCatalogController *center = nil;
    HYBCatalogMenuController *left = nil;
    
    if ([self isCatalogControllerShown] && !fromMain) {
        center = (HYBCatalogController *)       [self currentCenter];
        left   = (HYBCatalogMenuController *)   [self currentLeftSide];
        [left forceReload];
    } else {
        center = [[HYBCatalogController alloc] initWithBackEndService:[self backEndService]];
        
        HYBCatalogMenuController *left = [[HYBCatalogMenuController alloc] initWithBackEndService:[self backEndService]];
        HYBCartController *right = [[HYBCartController alloc] initWithBackEndService:[self backEndService]];
        [self renderCenter:center withLefSide:left withRightSide:right];
    }
    
    if (triggerSearch) {
        [center triggerSearch];
    }
    
    [center forceReload];
    
    if (toggleRightDrawer) {
        [self toggleRightDrawer];
    }
}

- (void)openCategoryInCatalog:(HYBCategory *)category {
    NSAssert(category != nil, @"Category must be present");
    DDLogDebug(@"Opening the category %@ inside the content area.", category);
    
    HYBCatalogController *center;
    
    if ([self isCatalogControllerShown]) {
        DDLogDebug(@"Prensent catalog controller was found and will be reused.");
        center = (HYBCatalogController *) [self currentCenter];
    } else {
        center = [[HYBCatalogController alloc] initWithBackEndService:[self backEndService]];
    }
    
    [center loadBaseProductsByCategoryId:category.id];
    [center clearQuery];
    
    [self renderCenter:center];
}

- (UIViewController *)currentCenter {
    UINavigationController *centerNav = (UINavigationController *) [self.mm_drawerController centerViewController];
    return [[centerNav viewControllers] lastObject];
}

- (UIViewController *)currentLeftSide {
    return [self.mm_drawerController leftDrawerViewController];
}

- (UIViewController *)currentRightSide {
    return [self.mm_drawerController rightDrawerViewController];
}

- (void)leftDrawerButtonPress:(id)sender {
    
    id left = [self currentLeftSide];
    
    if([left isKindOfClass:[HYBCatalogMenuController class]]) {
        [(HYBCatalogMenuController *)left forceReload];
    }
    
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)cartIconTapped {
    [[[[self.mm_drawerController centerViewController] view] findFirstResponder] resignFirstResponder];
    
    [self toggleRightDrawer];
    
    [[self backEndService] retrieveCurrentCartAndExecute:^(HYBCart *cart, NSError *error) {
        if (error) {
            DDLogError(@"Cart could not be updated, reason: %@", error.localizedDescription);
        } else {
            if (cart) {
                DDLogInfo(@"Cart updated from back end.");
            } else {
                DDLogError(@"Cart could not be updated, the cart does not exist, check back end functionality.");
            }
        }
    }];
}

- (void)searchIconTapped {
    [[[[self.mm_drawerController centerViewController] view] findFirstResponder] resignFirstResponder];
    BOOL toggleRightDrawer = [self.mm_drawerController openSide] == MMDrawerSideRight;
    [self navigateToCatalogAndToggleRightDrawer:toggleRightDrawer triggerSearch:YES];
    [self updateSearchIconState];
}

- (void)updateSearchIconState {
    
    for (UIBarButtonItem *barButtonItem in [[self.currentCenter navigationItem] rightBarButtonItems]) {
        UIView *customView = [barButtonItem customView];
        
        if (customView && [customView tag] == NAVBAR_SEARCH_SWITCH_TAG) {
            if ([self isCatalogControllerShown]) {
                
                HYBCatalogController *catalogController = (HYBCatalogController *) self.currentCenter;
                
                // a specific active search icon can be provided in the future and replaced here
                NSString *iconName = catalogController.searchExpanded ? @"B2BIcon_search_on.png": @"B2BIcon_search.png";
                
                UIView *searchIconSwitch = [self createIconView:icon_height
                                                           icon:iconName
                                                       accessId:@"ACCESS_TOPNAV_BUTTON_SEARCH_SWITCH"];
                
                NSString *styleClass = catalogController.searchExpanded ? @"navbarSearchActive": @"navbarSearchInActive";
                customView.cas_styleClass = styleClass;
                
                [customView removeAllSubViews];
                [customView addSubview:searchIconSwitch];
            }
        }
    }
}

- (BOOL)isCatalogControllerShown {
    UIViewController *currentCenter = self.currentCenter;
    return [currentCenter isKindOfClass:[HYBCatalogController class]];
}

- (BOOL)checkDetailPageDismiss {
    if ([[self currentCenter] isKindOfClass:[HYBProductDetailsController class]]) {
        [[[self currentCenter] navigationController] popViewControllerAnimated:NO];
        return YES;
    }
    
    return NO;
}

- (void)gridIconTapped {
    [self switchToGridLayout:YES];
}

- (void)listIconTapped {
    [self switchToGridLayout:NO];
}

- (void)switchToGridLayout:(BOOL)useGridLayout {
    [[self getDelegate] setIsGridView:useGridLayout];
    [self checkDetailPageDismiss];
    [self didSelectListOrGridLayout];
}

- (void)didSelectListOrGridLayout {
    [[[[self currentCenter] view] findFirstResponder] resignFirstResponder];
    
    BOOL toggleRightDrawer = NO;
    if ([self.mm_drawerController openSide] == MMDrawerSideRight) toggleRightDrawer = YES;
    
    [self navigateToCatalogAndToggleRightDrawer:toggleRightDrawer triggerSearch:NO];
    
    [self updateGridSwitchButton];
}

- (void)navigateToMainMenu {
    
    id center = nil;
    
    if ([self isCatalogControllerShown]) {
        center = (HYBCatalogController *) [self currentCenter];
        [center forceReload];
    } else {
        center  = (HYBDashboardController*)[[HYBDashboardController alloc]   initWithBackEndService:[self backEndService]];
    }
    
    HYBMainMenuController *left     = [[HYBMainMenuController alloc]    initWithBackEndService:[self backEndService]];
    HYBCartController *right        = [[HYBCartController alloc]        initWithBackEndService:[self backEndService]];
    
    [self renderCenter:center withLefSide:left withRightSide:right openLeftDrawer:YES];
}

- (void)navigateToDetailControllerWithProduct:(NSString *)code toggleDrawer:(BOOL)toggleDrawer {
    
    HYBProductDetailsController *detailViewController = [[HYBProductDetailsController alloc] initWithBackEndService:[self backEndService] productId:code];
    
    //check if center is already a detail view
    
    id centerViewController = [(UINavigationController *) self.mm_drawerController.centerViewController topViewController];
    
    UINavigationController *centerNav = [self createNavControllerWithRoot:detailViewController];
    [self addNavigationItems:detailViewController navBar:centerNav.navigationBar];

    BOOL isDetailVC = ([centerViewController isKindOfClass:[HYBProductDetailsController class]]);

    if (toggleDrawer) {
        //animate close
        [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight
                                          animated:YES
                                        completion:^(BOOL done) {
                                            [self handleCenterIfIsDetailVC:isDetailVC withViewControllerWith:detailViewController];
                                        }];
    } else {
        //direct swap
        [self handleCenterIfIsDetailVC:isDetailVC withViewControllerWith:detailViewController];
    }
    
}

- (void)handleCenterIfIsDetailVC:(BOOL)isDetailVC withViewControllerWith:(id)viewController {
    if (isDetailVC) {
        [self replaceCenterTopViewControllerWith:viewController];
    } else {
        [(UINavigationController *) self.mm_drawerController.centerViewController pushViewController:viewController animated:NO];
    }
}

- (void)replaceCenterTopViewControllerWith:(id)viewController {
    NSMutableArray *vcs = [[(UINavigationController *) self.mm_drawerController.centerViewController viewControllers] mutableCopy];
    
    [vcs removeObject:[vcs lastObject]];
    [vcs addObject:viewController];
    
    [(UINavigationController *) self.mm_drawerController.centerViewController setViewControllers:vcs animated:NO];
}

- (void)navigateToCheckout {
    HYBCheckoutController *center = [[HYBCheckoutController alloc] initWithBackEndService:[self backEndService]];
    
    [self renderWithTwoDrawersAndCenter:center];
    [self toggleRightDrawer];
}

- (void)navigateToOrderConfirmationWithOrder:(HYBOrder *)order {
    HYBOrderConfirmationController *center = [[HYBOrderConfirmationController alloc] initWithBackEndService:[self backEndService] andOrder:order];
    [self renderWithTwoDrawersAndCenter:center];
}

- (void)renderWithTwoDrawersAndCenter:(UIViewController *)center {
    HYBCatalogMenuController *left = [[HYBCatalogMenuController alloc] initWithBackEndService:[self backEndService]];
    HYBCartController *right = [[HYBCartController alloc] initWithBackEndService:[self backEndService]];
    [self renderCenter:center withLefSide:left withRightSide:right];
}

#pragma mark Navigation Helpers

- (void)toggleRightDrawer {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (void)renderCenter:(UIViewController *)center
         withLefSide:(UIViewController *)leftSide
       withRightSide:(UIViewController *)rightSide {
    
    [self renderCenter:center withLefSide:leftSide withRightSide:rightSide openLeftDrawer:NO];
}

- (void)renderCenter:(UIViewController *)center
         withLefSide:(UIViewController *)leftSide
       withRightSide:(UIViewController *)rightSide
      openLeftDrawer:(BOOL)openLeftDrawer {
    
    UINavigationController *centerNav = [self createNavControllerWithRoot:center];
    
    BOOL useGridSwitch = [center isKindOfClass:[HYBCatalogController class]];
    [self addNavigationItems:center navBar:centerNav.navigationBar useGridSwitch:useGridSwitch];
    
    if ([self mm_drawerController] == nil) {
        [self createDrawerWithCenter:centerNav leftSideBar:leftSide rigthSideBar:rightSide openLeftDrawer:openLeftDrawer];
    }
    
    [self.mm_drawerController setShouldStretchDrawer:NO];
    
    [self.mm_drawerController setMaximumRightDrawerWidth:MAX_WIDTH_RIGHT_DRAWER];
    [self.mm_drawerController setMaximumLeftDrawerWidth:MAX_WIDTH_LEFT_DRAWER];
    
    BOOL closeAnimation = [(HYBCatalogMenuController *) leftSide isClosedMenu];
    
    [self.mm_drawerController setCenterViewController:centerNav withCloseAnimation:closeAnimation completion:nil];
    [self.mm_drawerController setLeftDrawerViewController:leftSide];
    
}

- (void)prepareToPresentDrawer:(MMDrawerSide)drawer animated:(BOOL)animated {
    
    id left = [self currentLeftSide];
    
    if([left isKindOfClass:[HYBCatalogMenuController class]]) {
        [(HYBCatalogMenuController *)left forceReload];
    }
}

- (UINavigationController *)createNavControllerWithRoot:(UIViewController *)center {
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:center];
    
    navController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    return navController;
}

- (void)renderCenter:(UIViewController *)center {
    UINavigationController *nav = [self createNavControllerWithRoot:center];
    
    BOOL useGridSwitch = [center isKindOfClass:[HYBCatalogController class]];
    [self addNavigationItems:center navBar:nav.navigationBar useGridSwitch:useGridSwitch];
    
    BOOL shouldCloseMenu = [(HYBCartController *) [self currentLeftSide] isClosedMenu];
    [self.mm_drawerController setCenterViewController:nav withCloseAnimation:shouldCloseMenu completion:nil];
}

- (void)addNavigationItems:(id)controller navBar:(UINavigationBar *)navBar {
    [self addNavigationItems:controller navBar:navBar useGridSwitch:NO];
}

- (void)addNavigationItems:(id)controller navBar:(UINavigationBar *)navBar useGridSwitch:(BOOL)useGridSwitch {
    
    NSMutableArray *rightIconsHolder = [[NSMutableArray alloc] init];
    
    UIView *navbarCart = [self createIconView:icon_height icon:@"B2BIcon_cart.png" accessId:@"navbarCart"];
    navbarCart.accessibilityIdentifier = @"ACCESS_TOPNAV_BUTTON_CART";
    
    HYBBarButtonItem *barButton = [[HYBBarButtonItem alloc] initWithCustomView:navbarCart];
    barButton.shouldAnimateBadge = YES;
    barButton.shouldHideBadgeAtZero = YES;
    
    HYBCart *cart = [[self backEndService] currentCartFromCache];
    if (cart) {
        barButton.badgeValue = [cart.totalUnitCount stringValue];
    }
    
    UITapGestureRecognizer *cartIconTapped = [[UITapGestureRecognizer alloc] initWithTarget:controller
                                                                                     action:@selector(cartIconTapped)];
    [navbarCart addGestureRecognizer:cartIconTapped];
    
    
    [rightIconsHolder addObject:barButton];
    
    //search
    
    UIView *navbarSearch = [self createIconView:icon_height icon:@"B2BIcon_search.png" accessId:@"navbarSearch"];
    navbarSearch.accessibilityIdentifier = @"ACCESS_TOPNAV_BUTTON_SEARCH";
    navbarSearch.tag = NAVBAR_SEARCH_SWITCH_TAG;
    
    [rightIconsHolder addObject:[[UIBarButtonItem alloc] initWithCustomView:navbarSearch]];
    
    UITapGestureRecognizer *searchIconTapped = [[UITapGestureRecognizer alloc] initWithTarget:controller
                                                                                       action:@selector(searchIconTapped)];
    [navbarSearch addGestureRecognizer:searchIconTapped];
    
    if(useGridSwitch) {
        BOOL localIsGridView = [(HYBAppDelegate *) [[UIApplication sharedApplication] delegate] isGridView];
        
        //grid icon
        
        NSString *gridIconName = @"ic_subnav_grid_grey.png";
        if(localIsGridView)gridIconName = @"ic_subnav_grid_white.png";
        
        UIView *navbarGridSwitch = [self createIconView:icon_height icon:gridIconName accessId:@"navbarGridSwitch"];
        navbarGridSwitch.accessibilityIdentifier = @"ACCESS_TOPNAV_BUTTON_GRID_SWITCH";
        [navbarGridSwitch setTag:NAVBAR_GRID_SWITCH_TAG];
        
        [rightIconsHolder addObject:[[UIBarButtonItem alloc] initWithCustomView:navbarGridSwitch]];
        
        UITapGestureRecognizer *gridIconTapped = [[UITapGestureRecognizer alloc] initWithTarget:controller
                                                                                         action:@selector(gridIconTapped)];
        [navbarGridSwitch addGestureRecognizer:gridIconTapped];
        
        //list icon
        
        NSString *listIconName = @"ic_subnav_list_white.png";
        if(localIsGridView)listIconName = @"ic_subnav_list_grey.png";
        
        UIView *navbarListSwitch = [self createIconView:icon_height icon:listIconName accessId:@"navbarListSwitch"];
        navbarListSwitch.accessibilityIdentifier = @"ACCESS_TOPNAV_BUTTON_LIST_SWITCH";
        [navbarListSwitch setTag:NAVBAR_LIST_SWITCH_TAG];
        
        [rightIconsHolder addObject:[[UIBarButtonItem alloc] initWithCustomView:navbarListSwitch]];
        
        UITapGestureRecognizer *listIconTapped = [[UITapGestureRecognizer alloc] initWithTarget:controller
                                                                                         action:@selector(listIconTapped)];
        [navbarListSwitch addGestureRecognizer:listIconTapped];
        
    }
    
    //pile up
    [[(UIViewController *) controller navigationItem] setRightBarButtonItems:rightIconsHolder];
    
    UIImageView *navbarMenu = [[UIImageView alloc] initWithImage:[self hambugerButtonImage]];
    navbarMenu.accessibilityIdentifier = @"ACCESS_TOPNAV_BUTTON_MENU";
    
    UIBarButtonItem *hamburgerButton = [[UIBarButtonItem alloc] initWithCustomView:navbarMenu];
    hamburgerButton.cas_styleClass = @"hamburgerButton";
    hamburgerButton.style = UIBarButtonItemStylePlain;
    
    UITapGestureRecognizer *openMenuGesture = [[UITapGestureRecognizer alloc] initWithTarget:controller
                                                                                      action:@selector(leftDrawerButtonPress:)];
    [navbarMenu addGestureRecognizer:openMenuGesture];
    
    UIImageView *logoView = [self createImageView:@"Logo.png" height:icon_height width:135];
    UIView *navbarLogo = [[UIView alloc] initWithFrame:logoView.bounds];
    navbarLogo.cas_styleClass = @"barIconPanel";
    navbarLogo.accessibilityIdentifier = @"ACCESS_TOPNAV_IMAGE";
    [navbarLogo addSubview:logoView];
    
    UIBarButtonItem *logoButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navbarLogo];
    
    NSMutableArray *leftIconsHolder = [[NSMutableArray alloc] init];
    [leftIconsHolder addObject:hamburgerButton];
    [leftIconsHolder addObject:logoButtonItem];
    
    [[(UIViewController *) controller navigationItem] setLeftBarButtonItems:leftIconsHolder];
    
    [self updateCart];
    
}

- (void)updateGridSwitchButton {
    
    BOOL localIsGridView = [(HYBAppDelegate *)[[UIApplication sharedApplication] delegate] isGridView];
    
    for (UIBarButtonItem *barButtonItem in [[[self currentCenter] navigationItem] rightBarButtonItems]) {
        UIView *customView = [barButtonItem customView];
        
        NSString *iconName = nil;
        UIView *iconView = nil;
        
        if (customView && [customView tag] == NAVBAR_GRID_SWITCH_TAG) {
            iconName = @"ic_subnav_grid_grey.png";
            if(localIsGridView)iconName = @"ic_subnav_grid_white.png";
            
            iconView = [self createIconView:icon_height icon:iconName accessId:@"navbarGridSwitch"];
            iconView.accessibilityIdentifier = @"ACCESS_TOPNAV_BUTTON_GRID_SWITCH";
            iconView.tag = NAVBAR_GRID_SWITCH_TAG;
            
        } else if (customView && [customView tag] == NAVBAR_LIST_SWITCH_TAG) {            
            iconName = @"ic_subnav_list_white.png";
            if(localIsGridView)iconName = @"ic_subnav_list_grey.png";
            
            iconView = [self createIconView:icon_height icon:iconName accessId:@"navbarGridSwitch"];
            iconView.accessibilityIdentifier = @"ACCESS_TOPNAV_BUTTON_LIST_SWITCH";
            iconView.tag = NAVBAR_LIST_SWITCH_TAG;
        }
        
        if(iconView) {
            [customView removeAllSubViews];
            [customView addSubview:iconView];
        }
    }
}

- (void)updateCart {
    NSArray *rightButtons = [[[self currentCenter] navigationItem] rightBarButtonItems];
    HYBCart *cart = [[self backEndService] currentCartFromCache];
    if (rightButtons && cart) {
        HYBBarButtonItem *barButton = [rightButtons firstObject];
        barButton.badgeValue = [cart.totalUnitCount stringValue];
    } else {
        DDLogError(@"Attention: Cart not updated since bar button items not found. Controller navigation must be wrong.");
    }
}

- (void)registerForCartChangeNotifications:(SEL)methodToCall senderObject:(id)senderObject {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:methodToCall
                                                 name:NOTIFICATION_CART_UPDATED
                                               object:senderObject];
}

- (void)observeCartUpdatesAndShowInHeader {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCart)
                                                 name:NOTIFICATION_CART_UPDATED
                                               object:[self backEndService]];
}

- (UIView *)createIconView:(int)height icon:(NSString *)icon accessId:(NSString *)accessId {
    UIImageView *imageView = [self createImageView:icon height:height width:height];
    UIView *iconPanel = [[UIView alloc] initWithFrame:imageView.bounds];
    iconPanel.cas_styleClass = @"barIconPanel";
    iconPanel.accessibilityIdentifier = accessId;
    [iconPanel addSubview:imageView];
    return iconPanel;
}

- (UIImage *)hambugerButtonImage {
    
    static UIImage *drawerButtonImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(26, 26), NO, 0);
        
        //// Color Declarations
        UIColor *fillColor = [UIColor whiteColor];
        
        //// Frames
        CGRect frame = CGRectMake(0, 0, 26, 26);
        
        //// Bottom Bar Drawing
        UIBezierPath *bottomBarPath = [UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 16) * 0.50000 + 0.5), CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 1) * 0.72000 + 0.5), 16, 1)];
        [fillColor setFill];
        [bottomBarPath fill];
        
        
        //// Middle Bar Drawing
        UIBezierPath *middleBarPath = [UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 16) * 0.50000 + 0.5), CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 1) * 0.48000 + 0.5), 16, 1)];
        [fillColor setFill];
        [middleBarPath fill];
        
        
        //// Top Bar Drawing
        UIBezierPath *topBarPath = [UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 16) * 0.50000 + 0.5), CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 1) * 0.24000 + 0.5), 16, 1)];
        [fillColor setFill];
        [topBarPath fill];
        
        drawerButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    });
    
    return drawerButtonImage;
}

- (UIImageView *)createImageView:(NSString *)imageName height:(int)height width:(int)width {
    UIImageView *imageHolder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageHolder.cas_styleClass = @"navBarIcon";
    CGRect newFrame = [imageHolder frame];
    newFrame.size.height = height;
    newFrame.size.width = width;
    imageHolder.frame = newFrame;
    imageHolder.contentMode = UIViewContentModeScaleAspectFit;
    
    return imageHolder;
}

#pragma mark User Notifications and Alerts

- (OLGhostAlertView *)createUserNotifier {
    OLGhostAlertView *notifier = [[OLGhostAlertView alloc] init];
    notifier.timeout = 3;
    notifier.style = OLGhostAlertViewStyleDark;
    notifier.position = OLGhostAlertViewPositionCenter;
    
    int count = 0;
    
    for (UIView *view in [notifier subviews]) {
        view.accessibilityIdentifier = [NSString stringWithFormat:@"ACCESS_NOTIFIER_%d", count++];
    }
    
    return notifier;
}

- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title cancelButtonText:(NSString *)cancelButtonText {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:cancelButtonText
                                          otherButtonTitles:nil];
    
    alert.accessibilityIdentifier = @"MESSAGE_POPUP_WINDOW";
    
    [alert show];
}

- (void)showNotifyMessage:(NSString *)msg {
    if (!self.notifier) {
        self.notifier = [self createUserNotifier];
    }
    if (![self.notifier isVisible]) {
        self.notifier.title = msg;
        [self.notifier show];
    }
}

#pragma keyboard monitor

- (void)keyboardDidShow:(NSNotification *)notification {
    UIButton *button = [[UIButton alloc] init];
    
    CGRect rect = self.view.bounds;
    
    button.frame = rect;
    button.backgroundColor = [UIColor clearColor];
    button.tag = TAG_MASK_VIEW;
    UIView *currentResponer = [self.view findFirstResponder];
    [button addTarget:currentResponer action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view insertSubview:button belowSubview:currentResponer];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    [[self.view viewWithTag:TAG_MASK_VIEW] removeFromSuperview];
}


#pragma mark Basic Services
- (id <HYBBackEndFacade>)backEndService {
    return [[self getDelegate] backEndService];
}

- (HYBAppDelegate *)getDelegate {
    return (HYBAppDelegate *) [[UIApplication sharedApplication] delegate];
}
@end