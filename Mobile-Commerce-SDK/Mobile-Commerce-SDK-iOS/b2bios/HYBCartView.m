//
// HYBCartView.m
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

#import "HYBCartView.h"
#import "UIView+HYBBase.h"
#import "UILabel+HYBLabel.h"
#import "HYBCustButton.h"
#import "HYBButton.h"
#import "UIButton+HYBButton.h"


@interface HYBCartView ()

@property(nonatomic, strong) UIView        *buttonsPanel;
@property(nonatomic, strong) HYBButton     *continueShoppingButton;
@property(nonatomic, strong) HYBCustButton *checkoutButton;
@property(nonatomic, strong) UIView        *totalsPanel;
@property(nonatomic, strong) UIView        *totalsLabelsPanel;
@property(nonatomic, strong) UIView        *totalsNumbersPanel;
@property(nonatomic, strong) UIView        *itemsPanelHeader;

@end

@implementation HYBCartView

/**
 *  generate view layout
 */
- (void)addSubviews {
    self.buttonsPanel = [[UIView alloc] initWithStyleClassId:@"panel buttonsPanel"];
    self.continueShoppingButton = [[HYBButton alloc] initWithStyleClassId:@"continueShoppingButton alignRight"
                                                                    title:NSLocalizedString(@"cart_button_continueshopping", @"Continue Shopping")];

    self.continueShoppingButton.accessibilityIdentifier = @"ACCESS_CART_BUTTON_CONTINUE_SHOP";

    //TODO fix disabled state
    self.checkoutButton = [[HYBCustButton alloc] initWithStyleClassId:@"checkoutButton alignLeft enabled"
                                                                 text:NSLocalizedString(@"cart_button_checkout", @"Checkout")];
    self.checkoutButton.titleAlign = center;


    self.checkoutButton.accessibilityIdentifier = @"ACCESS_CART_BUTTON_CHECKOUT";
    
    [self.buttonsPanel addSubview:self.continueShoppingButton];
    [self.buttonsPanel addSubview:self.checkoutButton];
    [self addSubview:self.buttonsPanel];

    self.titleLabel = [[UILabel alloc] initWithStyleClassId:@"titleLabel alignLeft" text:NSLocalizedString(@"cart_label_title", nil)];
    
    self.titleLabel.accessibilityIdentifier = @"ACCESS_CART_TITLE";
    
    [self addSubview:self.titleLabel];

    self.totalsPanel = [[UIView alloc] initWithStyleClassId:@"panel totalsPanel"];

    // left side labels
    self.totalsLabelsPanel = [[UIView alloc] initWithStyleClassId:@"panel totalsLabelsPanel alignLeft"];
    
    [self.totalsPanel addSubview:self.totalsLabelsPanel];

    self.subtotalTitleLabel = [[UILabel alloc] initWithStyleClassId:@"textLabel alignLeft" text:@"Subtotal:"];
    self.subtotalTitleLabel.accessibilityIdentifier = @"ACCESS_CART_SUBTOTAL_TITLE";
    [self.totalsLabelsPanel addSubview:self.subtotalTitleLabel];
    
    self.savingsLabel = [[UILabel alloc] initWithStyleClassId:@"textLabel savingsLabel alignLeft" text:@"Savings:"];
    
    self.savingsLabel.accessibilityIdentifier = @"ACCESS_CART_SAVINGS_TITLE";
    
    [self.totalsLabelsPanel addSubview:self.savingsLabel];
    
    self.taxTitleLabel = [[UILabel alloc] initWithStyleClassId:@"textLabel alignLeft" text:@"Tax:"];
    self.taxTitleLabel.accessibilityIdentifier = @"ACCESS_CART_TAX_TITLE";
    
    [self.totalsLabelsPanel addSubview:self.taxTitleLabel];
    
    self.shippingLabel = [[UILabel alloc] initWithStyleClassId:@"textLabel alignLeft" text:@"Shipping:"];
    [self.totalsLabelsPanel addSubview:self.shippingLabel];
    
    self.cartTotalTitleLabel = [[UILabel alloc] initWithStyleClassId:@"textLabel cartTotalLabel alignLeft" text:NSLocalizedString(@"cart_label_total", nil)];
    
    self.cartTotalTitleLabel.accessibilityIdentifier = @"ACCESS_CART_TOTAL_TITLE";
    
    [self.totalsLabelsPanel addSubview:self.cartTotalTitleLabel];

    // right side labels
    self.totalsNumbersPanel = [[UIView alloc] initWithStyleClassId:@"panel totalsNumbersPanel alignRight"];
    [self.totalsPanel addSubview:self.totalsNumbersPanel];

    self.subTotalNumber = [[UILabel alloc] initWithStyleClassId:@"textLabel alignRight" text:@""];
    [self.totalsNumbersPanel addSubview:self.subTotalNumber];

     self.subTotalNumber.accessibilityIdentifier = @"ACCESS_CART_SUBTOTAL_AMT";
    
    self.savingsNumber = [[UILabel alloc] initWithStyleClassId:@"textLabel savingsNumber alignRight" text:@""];
    
     self.savingsNumber.accessibilityIdentifier = @"ACCESS_CART_SAVINGS_AMT";
    
    [self.totalsNumbersPanel addSubview:self.savingsNumber];

    self.taxNumber = [[UILabel alloc] initWithStyleClassId:@"textLabel alignRight" text:@""];
    
     self.taxNumber.accessibilityIdentifier = @"ACCESS_CART_TAX_AMT";
    
    [self.totalsNumbersPanel addSubview:self.taxNumber];

    self.shippingNumber = [[UILabel alloc] initWithStyleClassId:@"textLabel alignRight" text:@""];
    [self.totalsNumbersPanel addSubview:self.shippingNumber];

    
    self.cartTotalNumber = [[UILabel alloc] initWithStyleClassId:@"textLabel cartTotalNumber alignRight" text:@""];
    
     self.cartTotalNumber.accessibilityIdentifier = @"ACCESS_CART_TOTAL_AMT";
    
    [self.totalsNumbersPanel addSubview:self.cartTotalNumber];

    self.discountsMessage = [[UILabel alloc] initWithStyleClassId:@"textLabel discountsMessage alignRight" text:@""];
    
      self.discountsMessage.accessibilityIdentifier = @"ACCESS_CART_DISCOUNT_RECAP";
    
    [self.totalsNumbersPanel addSubview:self.discountsMessage];

    [self addSubview:self.totalsPanel];

    self.itemsPanelHeader = [[UIView alloc] initWithStyleClassId:@"panel itemsPanelHeader"];
    [self addSubview:self.itemsPanelHeader];

    UILabel *headerItemsLabel   = [[UILabel alloc] initWithStyleClassId:@"headerLabel items" text:@"ITEMS"];
    headerItemsLabel.accessibilityIdentifier = @"ACCESS_CART_HEADER_ITEMS_TITLE";
    
    UILabel *headerQtyLabel     = [[UILabel alloc] initWithStyleClassId:@"headerLabel qty"   text:@"QTY"];
    headerQtyLabel.accessibilityIdentifier = @"ACCESS_CART_HEADER_QTY_TITLE";
    
    UILabel *headerTotalLabel   = [[UILabel alloc] initWithStyleClassId:@"headerLabel total" text:@"TOTAL"];
    headerTotalLabel.accessibilityIdentifier = @"ACCESS_CART_HEADER_TOTAL_TITLE";
    
    [self.itemsPanelHeader addSubview:headerItemsLabel];
    [self.itemsPanelHeader addSubview:headerQtyLabel];
    [self.itemsPanelHeader addSubview:headerTotalLabel];

    self.itemsPanelInfoBox = [[UIView alloc] initWithStyleClassId:@"panel itemsPanelInfoBox"];
    [self addSubview:self.itemsPanelInfoBox];

   
    UIImageView *infoIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    infoIcon.cas_styleClass = @"infoIcon";
    [self.itemsPanelInfoBox addSubview:infoIcon];
    
    UILabel *infoLabel = [[UILabel alloc] initWithStyleClassId:@"textLabel infoLabel" text:@""];
    [self.itemsPanelInfoBox addSubview:infoLabel];
    
    
    // implement with gesture action
    //[self.itemsPanelInfoBox addSubview:[[UILabel alloc] initWithStyleClassId:@"textLabel hideInfoButton" text:@"Hide"]];
    
    self.batchToggleButton = [[HYBCustButton alloc] initWithStyleClassId:@"batchToggleButton alignRight"
                                                               text:NSLocalizedString(@"batch_toggle_button_edit", nil)];

    self.batchToggleButton.titleAlign = center;
    
    self.batchToggleButton.accessibilityIdentifier = @"ACCESS_CART_BUTTON_BATCH_REMOVE";

    // activate the batchToggleButton here, for now deactivated since separate task
    [self.itemsPanelInfoBox addSubview:self.batchToggleButton];
    
    self.itemsTable = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    self.itemsTable.cas_styleClass = @"itemsTable";

    [self addSubview:self.itemsTable];
    
    
    self.batchDeletePanel = [[UIView alloc] initWithStyleClassId:@"batchDeletePanel"];
    [self addSubview:self.batchDeletePanel];


    self.batchSelectButton = [[HYBCustButton alloc] initWithStyleClassId:@"batchSelectButton"
                                                               text:NSLocalizedString(@"batch_select_all_button", nil)];
    
    self.batchSelectButton.titleAlign = center;
    
    self.batchSelectButton.accessibilityIdentifier = @"ACCESS_CART_BUTTON_BATCH_SELECT_ALL";
    
    [self.batchDeletePanel addSubview:self.batchSelectButton];

    self.batchDeleteButton = [[HYBCustButton alloc] initWithStyleClassId:@"batchDeleteButton alignRight"
                                                               text:NSLocalizedString(@"batch_delete_button", nil)];
    
    self.batchDeleteButton.titleAlign = center;
    
    self.batchDeleteButton.accessibilityIdentifier = @"ACCESS_CART_BUTTON_BATCH_DELETE";
    
    [self.batchDeletePanel addSubview:self.batchDeleteButton];

}

- (void)defineLayout {
    [self.buttonsPanel        layoutSubviewsHorizontally];
    [self.checkoutButton      layoutSubviewsHorizontally];
    [self.totalsLabelsPanel   layoutSubviewsVertically];
    [self.totalsNumbersPanel  layoutSubviewsVertically];
    [self.totalsPanel         layoutSubviewsHorizontally];
    [self.itemsPanelHeader    layoutSubviewsHorizontally];
    [self.itemsPanelInfoBox   layoutSubviewsHorizontally];
    [self.batchDeletePanel    layoutSubviewsHorizontally];

    [self layoutSubviewsVertically];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setCartToEmpty {
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setText:NSLocalizedString(@"cart_label_your_cart_is_empty", nil)];
    [self.checkoutButton setEnabled:NO];
    [self.itemsPanelInfoBox setHidden:YES];
    [self.itemsPanelHeader setHidden:YES];
}

- (void)setCartToNotEmpty {
    [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.titleLabel setText:NSLocalizedString(@"cart_label_title", nil)];
    [self.checkoutButton setEnabled:YES];
    [self.itemsPanelInfoBox setHidden:NO];
    [self.itemsPanelHeader setHidden:NO];
}

-(void)hideCart:(BOOL)hide {
    [self.cartTotalTitleLabel  setHidden:hide];

    [self.cartTotalLabel       setHidden:hide];
    [self.cartTotalNumber       setHidden:hide];

    [self.subtotalTitleLabel   setHidden:hide];
    [self.subTotalNumber       setHidden:hide];

    [self.taxTitleLabel        setHidden:hide];
    [self.taxNumber            setHidden:hide];

    [self.shippingLabel        setHidden:hide];
    [self.shippingNumber       setHidden:hide];

    [self.discountsMessage     setHidden:hide];
    [self.savingsLabel         setHidden:hide];
    [self.savingsNumber        setHidden:hide];
}
@end