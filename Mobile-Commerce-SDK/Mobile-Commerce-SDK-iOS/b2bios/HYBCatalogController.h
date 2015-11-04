//
// HYBCatalogController.h
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

#import <UIKit/UIKit.h>
#import "HYBViewController.h"

@class HYBCategory;
@class OLGhostAlertView;

@interface HYBCatalogController : HYBViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
}

@property(nonatomic, strong) NSArray  *products;
@property(nonatomic, strong) NSString *currentCategoryId;

@property(nonatomic) BOOL blockScroll;
@property(nonatomic) BOOL searchExpanded;
@property(nonatomic) BOOL loading;
@property(nonatomic) BOOL allItemsLoaded;

@property(nonatomic) int prevPage;

- (void)loadBaseProductsByCategoryId:(NSString *)categoryId;
- (void)loadProductsByCategoryId:(NSString *)categoryId;

- (void)clearQuery;
- (void)triggerSearch;

- (void)forceReload;
@end
