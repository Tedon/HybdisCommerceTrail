//
// HYBCatalogView.m
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

#import <BlocksKit/NSArray+BlocksKit.h>
#import "HYBCatalogView.h"
#import "UIView+HYBBase.h"
#import "UIView+CASAdditions.h"
#import "HYBConstants.h"
#import "HYBCustButton.h"
#import "UILabel+HYBLabel.h"
#import "HYBCollectionViewCell.h"
#import "UIView+ClassyLayoutProperties.h"

@interface HYBCatalogView ()

@property(nonatomic) UIView *searchPanel;
@property(nonatomic) UIView *searchResultPanel;
@property(nonatomic) UIView *didYouMeanPanel;

@end

@implementation HYBCatalogView

/**
 *  generate view layout
 */
- (void)addSubviews {
    self.searchPanel = [[UIView alloc] initWithStyleClassId:@"search"];

    // search field panel
    self.searchField = [[UITextField alloc] init];
    self.searchField.cas_styleClass = @"searchField";
    [self.searchField setPlaceholder:NSLocalizedString(@"catalog_view_searchfield_placeholder", @"Search Products")];
    [self.searchField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.searchField setReturnKeyType:UIReturnKeySearch];
    self.searchField.borderStyle = UITextBorderStyleRoundedRect;
    self.searchField.accessibilityIdentifier = @"ACCESS_CONTENT_CATALOG_SEARCH_FIELD";

    [self.searchPanel addSubview:self.searchField];
    [self addSubview:self.searchPanel];

    // search result panel
    self.searchResultPanel = [[UIView alloc] initWithStyleClassId:@"searchResultPanel"];
    self.searchResultLeft = [[UILabel alloc] initWithStyleClassId:@"searchResultLeft" text:@""];
    self.searchResultLeft.accessibilityIdentifier = @"ACCESS_CONTENT_CATALOG_SEARCH_RESULTS_HEADER_LEFT";
    self.searchResultRight = [[UILabel alloc] initWithStyleClassId:@"searchResultRight" text:@""];
    self.searchResultRight.accessibilityIdentifier = @"ACCESS_CONTENT_CATALOG_SEARCH_RESULTS_HEADER_RIGHT";
    self.searchResultPanel.accessibilityIdentifier = @"ACCESS_CONTENT_CATALOG_SEARCH_RESULTS_HEADER";
    [self.searchResultRight setTextAlignment:NSTextAlignmentRight];
    [self.searchResultPanel addSubview:self.searchResultLeft];
    [self.searchResultPanel addSubview:self.searchResultRight];

    [self addSubview:self.searchResultPanel];

    // did you mean panel
    self.didYouMeanPanel = [[UIView alloc] initWithStyleClassId:@"didYouMeanPanel"];
    self.didYouMeanLabel = [[HYBCustButton alloc] initWithStyleClassId:@"didYouMeanLabel" text:@""];
    self.didYouMeanPanel.accessibilityIdentifier = @"ACCESS_CONTENT_CATALOG_SEARCH_DID_YOU_MEAN";
    [self.didYouMeanPanel addSubview:self.didYouMeanLabel];
    [self addSubview:self.didYouMeanPanel];

    //tableView
    self.productsTable = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    self.productsTable.accessibilityIdentifier = @"ACCESS_CONTENT_CATALOG_SEARCH_RESULTS_TABLE";
    self.productsTable.cas_styleClass = @"productsTable swapExpanded";
    UINib *cellFromNib = [UINib nibWithNibName:@"HYBListViewCell" bundle:[NSBundle mainBundle]];
    [self.productsTable registerNib:cellFromNib forCellReuseIdentifier:@"HYBListViewCellID"];
    [self addSubview:self.productsTable];

    //grid view
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(246, 300);
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;

    self.productsGrid = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.productsGrid.cas_styleClass = @"productsGrid swapCollapsed";
    [self.productsGrid registerClass:[HYBCollectionViewCell class] forCellWithReuseIdentifier:@"collectionViewCellId"];
    [self addSubview:self.productsGrid];
}

- (void)defineLayout {
}

- (void)updateConstraints {
    [super updateConstraints];
    [self.searchPanel layoutSubviewsHorizontally];
    [self.searchResultPanel layoutSubviewsHorizontally];
    [self.didYouMeanPanel layoutSubviewsHorizontally];
    [self layoutSubviewsVertically];

    if (self.initialTableHeight == nil) {
        self.initialTableHeight = [NSNumber numberWithFloat:self.productsTable.cas_sizeHeight];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)expandSearch {
    [self modifyViewStyles:self.searchPanel addStyle:@"expanded" removeStyle:@"collapsed"];
}

- (void)expandSearchResult {
    [self modifyViewStyles:self.searchResultPanel addStyle:@"expanded" removeStyle:@"collapsed"];
}

- (void)expandDidYouMean {
    [self modifyViewStyles:self.didYouMeanPanel addStyle:@"expanded" removeStyle:@"collapsed"];
}

- (void)collapseSearch {
    [self modifyViewStyles:self.searchPanel addStyle:@"collapsed" removeStyle:@"expanded"];
}

- (void)collapseSearchResult {
    [self modifyViewStyles:self.searchResultPanel addStyle:@"collapsed" removeStyle:@"expanded"];
}

- (void)collapseDidYouMean {
    [self modifyViewStyles:self.didYouMeanPanel addStyle:@"collapsed" removeStyle:@"expanded"];
}

- (void)modifyViewStyles:(UIView *)viewToModify addStyle:(NSString *)addStyle removeStyle:(NSString *)removeStyle {

    [UIView animateWithDuration:defaultAnimationDuration animations:^{

        [[viewToModify subviews] bk_each:^(UIView *subview) {
            [subview cas_addStyleClass:addStyle];
            [subview cas_removeStyleClass:removeStyle];
        }];

        [viewToModify cas_addStyleClass:addStyle];
        [viewToModify cas_removeStyleClass:removeStyle];

    } completion:^(BOOL finished) {
        [self updateConstraints];
        CGRect newFrame = self.productsTable.frame;
        newFrame.size.height = self.initialTableHeight.floatValue - self.searchPanel.bounds.size.height - self.searchResultPanel.bounds.size.height - self.didYouMeanPanel.bounds.size.height;
        self.productsTable.frame = newFrame;
        DDLogDebug(@"Table height is %f", self.productsTable.frame.size.height);
    }];
}

- (void)setResultsLabelWithOriginalQuery:(NSString *)originalQuery foundResultsNumber:(int)resultsNumber {
    [self.searchResultLeft setText:[NSString stringWithFormat:@"Searched '%@'", originalQuery]];
    [self.searchResultRight setText:[NSString stringWithFormat:@"%d Results", resultsNumber]];
}

- (void)setSpellingLabelWithSuggestion:(NSString *)suggestion {
    NSString *suggestionLabelText = [NSString stringWithFormat:@"Did you mean '%@' ?", suggestion];
    [self.didYouMeanLabel setText:suggestionLabelText];
}

- (void)closeAllSearchPanels {
    [self.searchField resignFirstResponder];
    [self collapseSearch];
    [self collapseSearchResult];
    [self collapseDidYouMean];
}
@end