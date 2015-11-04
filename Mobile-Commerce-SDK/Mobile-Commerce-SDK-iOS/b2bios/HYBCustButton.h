//
// HYBCustButton.h
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
#import "UIView+HYBBase.h"
#import "UIView+CASAdditions.h"


@interface HYBCustButton : UIView <UIGestureRecognizerDelegate>

enum titleAlignType {left,center,right};

@property(nonatomic, strong) UILabel *label;
@property(nonatomic) NSInteger titleAlign;

- (id)initWithStyleClassId:(NSString *)styleClass text:(NSString *)text;
- (void)addTarget:(id)aTarget action:(SEL)anAction;
- (void)setText:(NSString*)aText;

- (void)setEnabled:(BOOL)b;
@end