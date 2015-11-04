//
// HYBCustButton.m
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

#import "HYBCustButton.h"
#import "UIView+HYBBase.h"
#import "UILabel+HYBLabel.h"

@implementation HYBCustButton

- (instancetype)initWithStyleClassId:(NSString *)styleClass text:(NSString *)text {
    self = [super init];
    if (self) {
        self.titleAlign = left;
        self.clipsToBounds = YES;
        self.cas_styleClass = styleClass;

        self.label = [[UILabel alloc] initWithStyleClassId:@"buttonLabel" text:text];
        [self.label sizeToFit];

        [self addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.label sizeToFit];

    switch (self.titleAlign) {
        case left: {
            CGPoint aCenter = CGPointMake(self.label.bounds.size.width / 2 + self.bounds.size.height / 4, self.bounds.size.height / 2);
            self.label.center = aCenter;
        }
            break;

        case center: {
            CGPoint aCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
            self.label.center = aCenter;
        }
            break;

        case right: {
            CGPoint aCenter = CGPointMake(self.label.bounds.size.width - (self.label.bounds.size.width / 2 + self.bounds.size.height / 4), self.bounds.size.height / 2);
            self.label.center = aCenter;
        }
            break;

        default:
            break;
    }
}

- (void)addTarget:(id)aTarget action:(SEL)anAction {

    self.userInteractionEnabled = YES;

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:aTarget
                                                                                    action:anAction];
    [self addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;
}

- (void)setText:(NSString *)aText {
    self.label.text = aText;
    [self layoutSubviews];
}

- (void)setEnabled:(BOOL)b {
    if(b){
        [self replaceStyle:@"disabled" withStyle:@"enable"];
        self.userInteractionEnabled = YES;
    } else {
        [self replaceStyle:@"enable" withStyle:@"disabled"];
        self.userInteractionEnabled = NO;
    }
}
@end