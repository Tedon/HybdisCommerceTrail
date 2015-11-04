//
// HYBCatalogView.h
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
#import <ClassyLiveLayout/SHPAbstractView.h>

@class HYBCustButton;


@interface HYBCatalogView : SHPAbstractView

@property(nonatomic) UITableView      *productsTable;
@property(nonatomic) UICollectionView *productsGrid;
@property(nonatomic) UITextField      *searchField;
@property(nonatomic) HYBCustButton    *didYouMeanLabel;
@property(nonatomic) UILabel          *searchResultLeft;
@property(nonatomic) UILabel          *searchResultRight;
@property(nonatomic) NSNumber         *initialTableHeight;

- (void)collapseSearch;

- (void)expandSearch;

- (void)collapseSearchResult;

- (void)setResultsLabelWithOriginalQuery:(NSString *)originalQuery foundResultsNumber:(int)resultsNumber;

- (void)setSpellingLabelWithSuggestion:(NSString *)suggestion;

- (void)expandSearchResult;

- (void)expandDidYouMean;

- (void)collapseDidYouMean;

- (void)closeAllSearchPanels;
@end