//
// HYBCartItemCellView.m
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

#import "HYBCartItemCellView.h"
#import "UIColor+HexString.h"
#import "CASToken.h"
#import "HYBCartItem.h"

@interface HYBCartItemCellView ()
@end

@implementation HYBCartItemCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        CGFloat centerZoneWidth  = 280.f;
        CGFloat centerZoneOrigin = 110.f;
        CGFloat lineHeight       = 20.f;
        
        self.productDetailsTapArea       = [[UIView alloc] initWithFrame:CGRectMake(0, 0, centerZoneWidth, 75)];
        
        self.productImage                = [[UIImageView alloc] initWithFrame:CGRectMake(lineHeight, 2.5, lineHeight*3.5, lineHeight*3.5)];
        
        self.productNameLabel            = [[UILabel alloc] initWithFrame:CGRectMake(centerZoneOrigin, 15, centerZoneWidth, lineHeight)];
        self.productNameLabel.font       = [UIFont systemFontOfSize:17.0];
        
        self.productPriceLabel           = [[UILabel alloc] initWithFrame:CGRectMake(centerZoneOrigin, lineHeight*2, centerZoneWidth, lineHeight)];
        self.productPriceLabel.font      = [UIFont systemFontOfSize:13.0];

        self.productPromoLabel           = [[UILabel alloc] initWithFrame:CGRectMake(centerZoneOrigin, lineHeight*3.5, centerZoneWidth*2, lineHeight)];
        self.productPromoLabel.font      = [UIFont systemFontOfSize:13.0];
        self.productPromoLabel.textColor = [UIColor colorWithHexString:@"#009933"];
        
        self.itemsInputTextfield               = [[UITextField alloc] initWithFrame:CGRectMake(400, lineHeight, lineHeight*2.5, lineHeight*1.5)];
        self.itemsInputTextfield.textAlignment = NSTextAlignmentRight;
        self.itemsInputTextfield.keyboardType  = UIKeyboardTypeNumberPad;
        self.itemsInputTextfield.borderStyle   = UITextBorderStyleRoundedRect;
        
        self.totalPriceLabel      = [[UILabel alloc] initWithFrame:CGRectMake(490, lineHeight+5, 100, lineHeight)];
        self.totalPriceLabel.font = [UIFont systemFontOfSize:17.0];
        
        //pile up
        [self.contentView addSubview:self.productDetailsTapArea];
        
        [self.contentView addSubview:self.productImage];
        
        [self.contentView addSubview:self.productNameLabel];
        [self.contentView addSubview:self.productPriceLabel];
        [self.contentView addSubview:self.productPromoLabel];
        
        [self.contentView addSubview:self.itemsInputTextfield];
        
        [self.contentView addSubview:self.totalPriceLabel];
    }
    
    return self;
}

- (void)loadWithItem:(HYBCartItem *)item withProductImage:(UIImage *)itemImage {
    
    self.productCode    = [item valueForKeyPath:@"product.code"];
    [self.productNameLabel    setText:[item valueForKeyPath:@"product.name"]];
    
    NSString *promoline = [item valueForKeyPath:@"discountMessage"];
    if (promoline) {
        [self.productPromoLabel   setText:promoline];
    } else {
        [self.productPromoLabel   setText:@""];
    }
    
    [self.productPriceLabel   setText:[item valueForKeyPath:@"basePriceFormattedValue"]];
    [self.totalPriceLabel     setText:[item valueForKeyPath:@"totalPriceFormattedValue"]];
    
    [self.itemsInputTextfield setText:[[item valueForKeyPath:@"quantity"] stringValue]];
    self.cartItemPosition = [item valueForKeyPath:@"entryNumber"];

    if (itemImage) {
        self.productImage.image = itemImage;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (selected && !self.isEditing ) {
        return;
    }
    [super setSelected:selected animated:animated];
    [self setNeedsDisplay];
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    // Make an empty UIView with the boundaries of myself
    UIView *highlight = [[UIView alloc] initWithFrame:self.frame];
    
    // Set the background color
    highlight.backgroundColor = [UIColor clearColor];
    
    // Set the UIView as my backgroundview when selected
    self.selectedBackgroundView = highlight;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
}

@end
