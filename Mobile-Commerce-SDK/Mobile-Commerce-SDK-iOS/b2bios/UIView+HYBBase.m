//
// UIView+HYBBase.m
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
#import "UIView+HYBBase.h"
#import "NSString+HYStringUtils.h"
#import "UIView+ClassyLayoutProperties.h"
#import "NSArray+MASAdditions.h"
#import "View+MASShorthandAdditions.h"
#import "UIView+CASAdditions.h"


@implementation UIView (HYBBase)

- (instancetype)initScrollViewWithStyleClassId:(NSString *)styleClass {
    self = [[UIScrollView alloc] init];
    if (self) {
        self.cas_styleClass = styleClass;
    }
    return self;
}

- (instancetype)initWithStyleClassId:(NSString *)styleClass {
    self = [[UIView alloc] init];
    if (self) {
        self.cas_styleClass = styleClass;
    }
    return self;
}

- (void)layoutVertically:(NSArray *)viewsToLayout onParent:(UIView *)parent {
    for (int j = 0; j < viewsToLayout.count; j++) {

        UIView *currentView = [viewsToLayout objectAtIndex:j];

        BOOL firstElement = j == 0;
        if ([currentView.cas_styleClass contains:@"freesize"]) {
            // no concrete size is given

            BOOL middleElement = j > 0 && j < viewsToLayout.count - 1;
            BOOL lastElement = j == viewsToLayout.count - 1;

            if (firstElement) {
                // we layout the first relative to the super view
                [currentView mas_updateConstraintsWithTopMarginRelativeToSuperview];
                if (viewsToLayout.count > 1) {
                    // the there is more than one element we create a margin relative to the following element
                    UIView *nextView = [viewsToLayout objectAtIndex:(j + 1)];
                    [currentView mas_updateConstraintsWithBottomMarginRelativeTo:nextView.mas_top];
                }
            }
            if (middleElement) {
                // any element in between has margin to predecessor and follower
                UIView *previousView = [viewsToLayout objectAtIndex:(j - 1)];
                UIView *nextView = [viewsToLayout objectAtIndex:(j + 1)];
                [currentView mas_updateConstraintsWithTopMarginRelativeTo:previousView.mas_bottom];
                [currentView mas_updateConstraintsWithBottomMarginRelativeTo:nextView.mas_top];
            }
            if (lastElement) {
                if (viewsToLayout.count > 1) {
                    // the last element if there was more then on in the whole list, has margin to predecessor
                    UIView *previousView = [viewsToLayout objectAtIndex:(j - 1)];
                    [currentView mas_updateConstraintsWithTopMarginRelativeTo:previousView.mas_bottom];
                }
                // at the end we have bottom margin to the parent view
                [currentView mas_updateConstraintsWithBottomMarginRelativeToSuperview];
            }

            // the position on the X axis is always determined to the parent, so we create left and right margins
            [currentView mas_updateConstraintsWithLeftMarginRelativeToSuperview];
            [currentView mas_updateConstraintsWithRightMarginRelativeToSuperview];
        } else {
            // concrete size are given
            [currentView mas_updateConstraintsWidthFromStylesheet];
            [currentView mas_updateConstraintsHeightFromStylesheet];

            // we only layout depending on top margin
            if (firstElement) {
                [currentView mas_updateConstraintsWithTopMarginRelativeToSuperview];
            } else {
                UIView *previousView = [viewsToLayout objectAtIndex:(j - 1)];
                [currentView mas_updateConstraintsWithTopMarginRelativeTo:previousView.mas_bottom];
            }

            // vertical orientation or X-position alignment
            if ([currentView.cas_styleClass contains:@"alignLeft"]) {
                [currentView mas_updateConstraintsWithLeftMarginRelativeTo:parent];
            } else if ([currentView.cas_styleClass contains:@"alignRight"]) {
                [currentView mas_updateConstraintsWithRightMarginRelativeTo:parent];
            } else {
                // default case is a centered layout
                [currentView mas_updateConstraintsCenterX];
            }
        }
    }
}

- (void)layoutHorizontally:(NSArray *)viewsToLayout onParent:(UIView *)parent {

    for (int j = 0; j < viewsToLayout.count; j++) {

        UIView *currentView = [viewsToLayout objectAtIndex:j];
        BOOL firstElement = j == 0;

        if([currentView.cas_styleClass contains:@"freesize"]){
            // no concrete size is given

            BOOL middleElement = j > 0 && j < viewsToLayout.count - 1;
            BOOL lastElement = j == viewsToLayout.count - 1;

            if (firstElement) {
                // we layout the first relative to the super view
                [currentView mas_updateConstraintsWithLeftMarginRelativeTo:parent];
                if (viewsToLayout.count > 1) {
                    // the there is more than one element we create a margin relative to the following element
                    UIView *nextView = [viewsToLayout objectAtIndex:(j + 1)];
                    [currentView mas_updateConstraintsWithRightMarginRelativeTo:nextView.mas_left];
                }
            }
            if (middleElement) {
                // any element in between has margin to predecessor and follower
                UIView *previousView = [viewsToLayout objectAtIndex:(j - 1)];
                UIView *nextView = [viewsToLayout objectAtIndex:(j + 1)];

                [currentView mas_updateConstraintsWithLeftMarginRelativeTo:previousView.mas_right];
                [currentView mas_updateConstraintsWithRightMarginRelativeTo:nextView.mas_left];
            }
            if (lastElement) {
                if (viewsToLayout.count > 1) {
                    // the last element if there was more then on in the whole list, has margin to predecessor
                    UIView *previousView = [viewsToLayout objectAtIndex:(j - 1)];
                    [currentView mas_updateConstraintsWithLeftMarginRelativeTo:previousView.mas_right];
                }
                // at the end we have bottom margin to the parent view
                [currentView mas_updateConstraintsWithRightMarginRelativeTo:parent];
            }

            // the position on the X axis is always determined to the parent, so we create left and right margins
            [currentView mas_updateConstraintsWithTopMarginRelativeTo:parent];
            [currentView mas_updateConstraintsWithBottomMarginRelativeTo:parent];

        } else {
            [currentView mas_updateConstraintsWidthFromStylesheet];
            [currentView mas_updateConstraintsHeightFromStylesheet];

            // Y - position
            if ([currentView.cas_styleClass contains:@"alignTop"]) {
                [currentView mas_updateConstraintsWithTopMarginRelativeTo:parent];
            } else if ([currentView.cas_styleClass contains:@"alignBottom"]) {
                [currentView mas_updateConstraintsWithBottomMarginRelativeTo:parent];
            } else {
                // default case is a centered layout
                [currentView mas_updateConstraintsCenterY];
            }

            // X - position
            if (firstElement) {
                [currentView mas_updateConstraintsWithLeftMarginRelativeTo:parent];
            } else {
                UIView *previousView = [viewsToLayout objectAtIndex:(j - 1)];
                [currentView mas_updateConstraintsWithLeftMarginRelativeTo:previousView.mas_right];
            }
        }
    }
}

- (void)replaceStyle:(NSString *)styleToReplace withStyle:(NSString *)replaceWithStyle {
    [self cas_removeStyleClass:styleToReplace];
    [self cas_addStyleClass:replaceWithStyle];
}

- (void)layoutSubviewsVertically {
    [self layoutVertically:self.subviews onParent:self];
}

- (void)layoutSubviewsHorizontally {
    [self layoutHorizontally:self.subviews onParent:self];
}

- (void)removeAllSubViews {
    [self.subviews bk_each:^(UIView *subview) {
        [subview removeFromSuperview];
    }];
}
@end