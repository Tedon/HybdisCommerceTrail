//
// HYBCollectionViewCell.m
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

#import "HYBCollectionViewCell.h"

@implementation HYBCollectionViewCell

- (id)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {

        CGFloat cellWidth = frame.size.width;
        CGFloat cellHeight = frame.size.height;
        CGFloat marge = cellWidth * .1;
        CGFloat imageBorder = frame.size.width - marge;
        CGFloat infoPanelHeight = cellHeight - imageBorder - marge / 2;

        //product image
        self.productImageView = [[UIImageView alloc] initWithFrame:CGRectMake(marge, marge, imageBorder - marge * 2, imageBorder - marge * 2)];
        self.productImageView.contentMode = UIViewContentModeScaleAspectFit;

        //info panel
        self.productInfoPanel = [[UIImageView alloc] initWithFrame:CGRectMake(marge / 2, marge / 2 + imageBorder, imageBorder, infoPanelHeight)];
        self.productInfoPanel.backgroundColor = [UIColor whiteColor];

        //product name
        self.productNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(marge / 4, marge / 4, imageBorder - marge / 2, infoPanelHeight / 3)];
        self.productNameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.f];
        self.productNameLabel.text = @"product name";

        //product code
        self.productCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(marge / 4, marge / 6 + infoPanelHeight / 3, imageBorder - marge / 2, infoPanelHeight / 3)];
        self.productCodeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
        self.productCodeLabel.text = @"product code";

        //product price
        self.productPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(marge / 4, infoPanelHeight / 2 + marge / 4, imageBorder - marge / 2, infoPanelHeight / 3)];
        self.productPriceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.f];
        self.productPriceLabel.text = @"product price";
        self.productPriceLabel.textAlignment = NSTextAlignmentRight;

        //pile up
        [self addSubview:self.productImageView];
        [self addSubview:self.productInfoPanel];

        [self.productInfoPanel addSubview:self.productNameLabel];
        [self.productInfoPanel addSubview:self.productCodeLabel];
        [self.productInfoPanel addSubview:self.productPriceLabel];
    }

    return self;
}

@end
