//
// HYBCheckoutController.m
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

#import "HYBCheckoutController.h"
#import "HYBCheckoutView.h"
#import "HYBCart.h"
#import "HYBWebviewController.h"
#import "HYBCostCenter.h"
#import "HYBAddress.h"
#import "HYBDeliveryMode.h"
#import "UIColor+HexString.h"
#import "HYBOrder.h"
#import "HYBActivityIndicator.h"
#import "HYBButton.h"
#import "HYBConstants.h"

@interface HYBCheckoutController ()

@property(nonatomic) HYBCheckoutView *mainView;

@property(nonatomic) NSArray         *costCenters;
@property(nonatomic) NSArray         *deliveryAddresses;
@property(nonatomic) NSArray         *deliveryModes;

@property(nonatomic) HYBCart         *currentCart;
@property(nonatomic) HYBCostCenter   *selectedCostCenter;

@property(nonatomic) HYBDeliveryMode *mode;

@property(nonatomic) UILabel         *cancelPickerLabel;
@property(nonatomic) BOOL            cartSelectionsLoaded;

@end

@implementation HYBCheckoutController 

@synthesize optionsArray, mainPickerView;

- (instancetype)initWithBackEndService:(id <HYBBackEndFacade>)b2bService {
    
    if (self = [super initWithBackEndService:b2bService]) {
        self.costCenters        = [NSArray array];
        self.deliveryAddresses  = [NSArray array];
        self.deliveryModes      = [NSArray array];
    }
    return self;
}

#pragma mark - General UI Buildup

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setOptionsArray:[NSArray array]];
  
    // observe cart changes to react in own view
    [self registerForCartChangeNotifications:@selector(loadCurrentCart) senderObject:self.b2bService];

    //buttons interactions

    [self.mainView.paymentAccount addTarget:self action:@selector(checkoutPaymentAccountTap)];

     self.mainView.paymentAccount.accessibilityIdentifier = @"ACCESS_CHECKOUT_PAYMENT_ACCOUNT";
    
    self.mainView.paymentPONumberField.delegate = self;

    self.mainView.paymentPONumberField.accessibilityIdentifier = @"ACCESS_CHECKOUT_PAYMENT_PO_NUMBER_FIELD";
    self.mainView.paymentPONumberField.accessibilityLabel = NSLocalizedString(@"payment_po_number_optional", nil);
    
    [self.mainView.paymentQuestionMarkButton addTarget:self
                                                action:@selector(checkoutPaymentQuestionMarkTap)
                                      forControlEvents:UIControlEventTouchUpInside];

      self.mainView.paymentQuestionMarkButton.accessibilityIdentifier = @"ACCESS_CHECKOUT_PAYMENT_QUESTION_BUTTON";
    
    [self.mainView.costCenterButton addTarget:self
                                       action:@selector(checkoutCostCenterTap)];
    
    self.mainView.costCenterButton.accessibilityIdentifier = @"ACCESS_CHECKOUT_COST_CENTER";

    [self.mainView.deliveryAddressButton addTarget:self
                                            action:@selector(checkoutDeliveryAddressTap)];

      self.mainView.deliveryAddressButton.accessibilityIdentifier = @"ACCESS_CHECKOUT_DELIVERY_ADDRESS";
    
    [self.mainView.deliveryMethodButton addTarget:self
                                           action:@selector(checkoutDeliveryMethodTap)];

     self.mainView.deliveryMethodButton.accessibilityIdentifier = @"ACCESS_CHECKOUT_DELIVERY_METHOD";
    
    //checkbox
    [self.mainView.agreementButton setBackgroundColor:[UIColor lightGrayColor]];
    termsAndConditionsAccepted = NO;
    
    [self.mainView.agreementButton addTarget:self
                                      action:@selector(checkoutAgreementCheckboxTap)
                            forControlEvents:UIControlEventTouchUpInside];


     self.mainView.agreementButton.accessibilityIdentifier = @"ACCESS_CHECKOUT_AGREEMENT_CHECKBOX";
    
    [self.mainView.agreementIntroLabel setUserInteractionEnabled:YES];

    UITapGestureRecognizer *tapIntroRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkoutAgreementCheckboxTap)];
    tapIntroRecognizer.numberOfTapsRequired = 1;
    tapIntroRecognizer.delegate = self;
    [self.mainView.agreementIntroLabel addGestureRecognizer:tapIntroRecognizer];

       self.mainView.agreementIntroLabel.accessibilityIdentifier = @"ACCESS_CHECKOUT_AGREEMENT_INTRO_LABEL";
    
    [self.mainView.agreementLinkLabel setUserInteractionEnabled:YES];

     self.mainView.agreementLinkLabel.accessibilityIdentifier = @"ACCESS_CHECKOUT_AGREEMENT_LINK_LABEL";
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkoutAgreementTCTap)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.delegate = self;
    [self.mainView.agreementLinkLabel addGestureRecognizer:tapRecognizer];

    [self.mainView.orderButton
            addTarget:self
               action:@selector(orderButtonTap)
     forControlEvents:UIControlEventTouchUpInside];

    self.mainView.orderButton.accessibilityIdentifier = @"ACCESS_CHECKOUT_ORDER_BUTTON";
    [self.mainView.orderButton setEnabled:YES];
    
    [self loadCurrentCart];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //prepare picker
    [self setMainPickerView:[[UIPickerView alloc] init]];
    [mainPickerView setDataSource:self];
    [mainPickerView setDelegate:self];

    UITapGestureRecognizer *pickerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(pickerTapped)];
    [mainPickerView addGestureRecognizer:pickerTapRecognizer];
    pickerTapRecognizer.delegate = self;

    //mask tap dismiss pickers
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePicker)];
    [self.mainView.maskView addGestureRecognizer:tapRecognizer];
    
    //tap invite
    [self setCancelPickerLabel:[[UILabel alloc] init]];
    [self.cancelPickerLabel setText:NSLocalizedString(@"cancel", @"")];
    [self.cancelPickerLabel setTextAlignment:NSTextAlignmentCenter];
    [self.cancelPickerLabel sizeToFit];
    [self.cancelPickerLabel setFrame:CGRectInset(self.cancelPickerLabel.frame, -20, -10)];
    [self.cancelPickerLabel setBackgroundColor:[UIColor colorWithHexString:@"#fad712"]];
}

- (void)reloadChildDropdowns {

    int selectedIndex = pickersSelections[selectedPicker];

    switch (selectedPicker) {
        case costCenterPicker:
            [self selectCostCenterAtIndex:selectedIndex cart:self.currentCart];
            break;

        case deliveryAddressPicker:
            [self selectDeliveryAddressAtIndex:selectedIndex cart:self.currentCart];
            break;

        case deliveryMethodPicker:
            [self selectDeliveryModeAtIndex:selectedIndex cart:self.currentCart];
            break;

        default:
            break;
    }

}


#pragma mark alertview delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex != buttonIndex) {
        HYBWebviewController *webviewController = [[HYBWebviewController alloc] initWithLink:@"http://www.storefront.com"];
        
        self.navigationItem.backBarButtonItem.accessibilityLabel = @"ACCESS_TOPNAV_BUTTON_BACK";
        
        [self.navigationController pushViewController:webviewController animated:YES];
    }
}

#pragma mark buttons actions

- (void)checkoutPaymentAccountTap {
    DDLogInfo(@"a hit checkoutAccountPaymentTap");
}

- (void)checkoutPaymentQuestionMarkTap {
    DDLogInfo(@"a hit checkoutPaymentQuestionMarkTap");

    NSString *tip = [NSString stringWithFormat:NSLocalizedString(@"payment_account_tip", nil), @"www.storefront.com"];

    NSString *cancelButtonTitle = NSLocalizedString(@"payment_account_tip_cancel", nil);
    NSString *openButtonTitle = NSLocalizedString(@"payment_account_tip_open_url", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"payment_tip", nil)
                                                    message:tip
                                                   delegate:self
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:openButtonTitle,nil];
    
    alert.accessibilityIdentifier = @"ACCESS_CHECKOUT_PAYMENT_QUESTION_DIALOG";
    
    [alert show];
    
    

}



//hardcoded until new ui is validated
- (void)checkoutCostCenterTap {
    actionCenter = CGPointMake(self.mainView.center.x, 363);

    [self setOptionsArray:[self selectCostCenterArray]];
    mainPickerView.accessibilityIdentifier = @"ACCESS_PICKER_COST_CENTER";
    [self showPicker:costCenterPicker];
}

- (void)checkoutDeliveryAddressTap {
    actionCenter = CGPointMake(self.mainView.center.x, 501);

    [self setOptionsArray:[self selectDeliveryAddressArray]];
    mainPickerView.accessibilityIdentifier = @"ACCESS_PICKER_DELIVERY_ADDRESS";
    [self showPicker:deliveryAddressPicker];
}

- (void)checkoutDeliveryMethodTap {
    actionCenter = CGPointMake(self.mainView.center.x, 590);

    [self setOptionsArray:[self selectDeliveryMethodArray]];
    mainPickerView.accessibilityIdentifier = @"ACCESS_PICKER_DELIVERY_METHOD";
    [self showPicker:deliveryMethodPicker];
}

- (void)checkoutAgreementCheckboxTap {
    [self toggleAggreementCheckbox];
}

- (void)checkoutAgreementTCTap {
    HYBWebviewController *webviewController = [[HYBWebviewController alloc] initWithLink:@"http://www.hybris.com"];
    
    self.navigationItem.backBarButtonItem.accessibilityLabel = @"ACCESS_TOPNAV_BUTTON_BACK";
    
    [self.navigationController pushViewController:webviewController animated:YES];
}

- (void)orderButtonTap {
    DDLogDebug(@"Starting order placement ...");

    if (self.currentCart && termsAndConditionsAccepted) {
        
        [HYBActivityIndicator show];
        
        [self.b2bService placeOrderWithCart:self.currentCart andExecute:^(HYBOrder *order, NSError *error) {
            
            [HYBActivityIndicator hide];
            
            if (error) {
                [self showNotifyMessage:[NSString stringWithFormat:@"Error during order placement, reason: %@", [error localizedDescription]]];
            } else {
                [self refreshCartFromServer];
                [self navigateToOrderConfirmationWithOrder:order];
            }
        }];
    } else {
        [self agreementPanelHilight:YES];
    }
}

- (void)refreshCartFromServer {
    [self.b2bService retrieveCurrentCartAndExecute:^(HYBCart *cart, NSError *error) {
        [self loadCurrentCart];
    }];
}

#pragma mark checkbox management

- (void)agreementPanelHilight:(BOOL)hilite {
    if (hilite) {
        self.mainView.agreementConfirmationLabel.hidden = NO;
        self.mainView.agreementPanel.cas_styleClass = @"agreementLabel hilite";
    } else {
        self.mainView.agreementConfirmationLabel.hidden = YES;
        self.mainView.agreementPanel.cas_styleClass = @"agreementLabel lolite";
    }
}

- (void)toggleAggreementCheckbox {

    if ([[self.mainView.agreementButton titleForState:UIControlStateNormal] compare:@" "] == NSOrderedSame) {
        [self.mainView.agreementButton setTitle:@"x" forState:UIControlStateNormal];
        [self.mainView.agreementButton setBackgroundColor:[UIColor greenColor]];
        termsAndConditionsAccepted = YES;

        [self agreementPanelHilight:NO];

    } else {
        [self.mainView.agreementButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.mainView.agreementButton setTitle:@" " forState:UIControlStateNormal];
        termsAndConditionsAccepted = NO;
    }

    [self.mainView.agreementPanel setNeedsDisplay];
}

#pragma mark pickerview management

- (NSArray *)selectCostCenterArray {

    NSMutableArray *tempArray = [NSMutableArray array];

    for (HYBCostCenter *costCenter in self.costCenters) {
        [tempArray addObject:costCenter.name];
    }

    return [NSArray arrayWithArray:tempArray];
}

- (NSArray *)selectDeliveryAddressArray {

    int currentCostCenterIdx = pickersSelections[costCenterPicker];

    HYBCostCenter *costCenter = self.costCenters[currentCostCenterIdx];
    if (!costCenter) return nil;

    NSMutableArray *tempArray = [NSMutableArray array];

    for (HYBAddress *address in costCenter.addresses) {
        [tempArray addObject:address.formattedAddress];
    }

    return [NSArray arrayWithArray:tempArray];
}

- (NSArray *)selectDeliveryMethodArray {

    NSMutableArray *tempArray = [NSMutableArray array];

    for (HYBDeliveryMode *deliveryMode in self.deliveryModes) {
        [tempArray addObject:deliveryMode.name];
    }

    return [NSArray arrayWithArray:tempArray];
}

- (int)preSelectedDeliveryMethod {
    
    NSString *currentDeliveryMode = self.currentCart.deliveryCode;
    
    if(currentDeliveryMode) {
        for (HYBDeliveryMode *deliveryMode in self.deliveryModes) {
            if([currentDeliveryMode isEqualToString:deliveryMode.code]) {
                self.mode = deliveryMode;
                return (int)[self.deliveryModes indexOfObject:self.mode];
                break;
            }
        }
    }
    
    return 0;
}

- (void)showPicker:(int)pickerType {

    if (!optionsArray || [optionsArray count] <= 0) return; //no data to display : bail out

    [self.mainView addSubview:self.mainView.maskView];
    self.mainView.maskView.hidden = NO;
    self.mainView.maskView.alpha = 0;

    selectedPicker = pickerType;
    int preselectedRow = pickersSelections[selectedPicker];

    [mainPickerView reloadAllComponents];
    [mainPickerView selectRow:preselectedRow inComponent:0 animated:NO];

    [self.mainView addSubview:mainPickerView];
   
    [self.mainView addSubview:self.cancelPickerLabel];

    [mainPickerView setCenter:actionCenter];
    [self.cancelPickerLabel setCenter:CGPointMake(mainPickerView.center.x, mainPickerView.center.y+mainPickerView.bounds.size.height/3*2)];

    mainPickerView.alpha = 0.0;
    self.cancelPickerLabel.alpha = 0.0;

    [UIView animateWithDuration:defaultAnimationDuration
                     animations:^{
                         self.mainView.maskView.alpha = .8;
                         mainPickerView.alpha = 1.0;
                         self.cancelPickerLabel.alpha = 1.0;
                     }];

}

- (void)hidePicker {

    [UIView animateWithDuration:defaultAnimationDuration
                     animations:^{
                         mainPickerView.alpha = 0.0;
                         self.mainView.maskView.alpha = 0.0;
                         self.cancelPickerLabel.alpha = 0.0;
                     }
                     completion:^(BOOL done) {
                         [self.mainView.maskView removeFromSuperview];
                         [mainPickerView removeFromSuperview];
                         [self.cancelPickerLabel removeFromSuperview];
                     }];
}

- (void)processPickerSelection:(NSInteger)row {

    if (selectedPicker >= 0) {
        pickersSelections[selectedPicker] = (int)row;
    }

    [self reloadChildDropdowns];

    [self hidePicker];
}

- (void)pickerTapped {
    [self hidePicker];
}

#pragma mark gesture Recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // return
    return true;
}

#pragma mark pickerview delegate


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [optionsArray count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *pickerLabel = (UILabel *)view;
    
    if (pickerLabel == nil) {
        pickerLabel = [UILabel new];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    pickerLabel.text = [optionsArray objectAtIndex:row];
    
    [pickerLabel sizeToFit];
    
    pickerLabel.accessibilityIdentifier = [NSString stringWithFormat:@"ACCESS_PICKER_ROW_%ld",(long)row];
    
    return pickerLabel;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self processPickerSelection:row];
}

#pragma mark textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

#pragma mark - Loading the shown product

- (void)loadView {
    [super loadView];
    if (!self.mainView) {
        self.mainView = [[HYBCheckoutView alloc] init];
    }
    self.view = self.mainView;
}

- (void)loadCurrentCart {
    
    HYBCart *loadCart = [self.b2bService currentCartFromCache];
    if (loadCart) {
        [self setCurrentCart:loadCart];

        if (!self.cartSelectionsLoaded) {
            [self preloadCartSelections:self.currentCart];
            self.cartSelectionsLoaded = YES;
        }

        //order summary
        if ([self.currentCart isEmpty]) {
            [self.mainView.orderSummaryView.itemCount setText:NSLocalizedString(@"cart_label_your_cart_is_empty", nil)];
        } else {
            NSString *totalLabel = [NSString stringWithFormat:NSLocalizedString(@"xx_items", nil), self.currentCart.totalUnitCount];
            [self.mainView.orderSummaryView.itemCount setText:totalLabel];
        }

        [self.mainView.orderSummaryView.subtotalValue setText:self.currentCart.subTotalFormatted];
        [self.mainView.orderSummaryView.taxValue setText:self.currentCart.totalTaxFormatted];
        [self.mainView.orderSummaryView.shippingValue setText:self.mode.formattedValue];
        [self.mainView.orderSummaryView.orderTotalValue setText:self.currentCart.totalPriceFormatted];

        if (self.currentCart.orderDiscounts.intValue > 0) {
            [self.mainView.orderSummaryView.savingsValue setText:self.currentCart.orderDiscountsFormattedValue];
            [self.mainView.orderSummaryView.savingsRecapTitle setText:self.currentCart.orderDiscountsMessage];

            [self.mainView.orderSummaryView.savingsRecapPanel setHidden:NO];
            [self.mainView.orderSummaryView.savingsPanel setHidden:NO];
        } else {
            [self.mainView.orderSummaryView.savingsRecapPanel setHidden:YES];
            [self.mainView.orderSummaryView.savingsPanel setHidden:YES];
        }

    }
    else {
        DDLogInfo(@"No cart is present in the user cache, a cart should have been created at the login.");
    }
}

- (void)preloadCartSelections:(HYBCart *)currentCart {
    selectedPicker = -1;
    
    __weak typeof(self) weakSelf = self;
    
    [self.b2bService setPaymentType:CART_PAYMENTTYPE_ACCOUNT
                         onCartWithCode:currentCart.code
                                execute:^(HYBCart *cart, NSError *msg) {
                                    
                                    [weakSelf.mainView.paymentAccount setText:cart.paymentDisplayName];
                                    
                                    [weakSelf.b2bService costCentersForCurrentStoreAndExecute:^(NSArray *costCenters, NSError *error) {
                                        weakSelf.costCenters = costCenters;
                                        [weakSelf selectCostCenterAtIndex:0 cart:cart];
                                    }];
                                }];
}

- (void)selectCostCenterAtIndex:(int)costcenterIndex cart:(HYBCart *)cart {

    self.selectedCostCenter = [self.costCenters objectAtIndex:costcenterIndex];
    pickersSelections[costCenterPicker] = costcenterIndex;

    __weak typeof(self) weakSelf = self;
    
    [self.b2bService setCostCenterWithCode:self.selectedCostCenter.code
                                onCartWithCode:cart.code andExecute:^(HYBCart *cart, NSError *error) {
                                    [weakSelf.mainView.costCenterButton setText:weakSelf.selectedCostCenter.name];
                                    weakSelf.deliveryAddresses = weakSelf.selectedCostCenter.addresses;
                                    [weakSelf selectDeliveryAddressAtIndex:0 cart:cart];
                                }];
}

- (void)selectDeliveryAddressAtIndex:(int)deliveryAddressIndex cart:(HYBCart *)cart {
    HYBAddress *selectedAddress = [self.deliveryAddresses objectAtIndex:deliveryAddressIndex];
    pickersSelections[deliveryAddressPicker] = deliveryAddressIndex;
    
    __weak typeof(self) weakSelf = self;
    
    [self.b2bService setDeliveryAddressWithCode:selectedAddress.id onCartWithCode:cart.code andExecute:^(HYBCart *cart, NSError *error) {
        
        [weakSelf.mainView.deliveryAddressButton setText:selectedAddress.formattedAddress];
        
        [weakSelf.b2bService getDeliveryModesForCart:cart.code andExecute:^(NSArray *modes, NSError *error) {
            
            weakSelf.deliveryModes = modes;
            
            int deliveryModeIndex = [weakSelf preSelectedDeliveryMethod];
            
            [weakSelf selectDeliveryModeAtIndex:deliveryModeIndex cart:cart];
        }];
    }];
}

- (void)selectDeliveryModeAtIndex:(int)deliveryModeIndex cart:(HYBCart *)cart {
    self.mode = [self.deliveryModes objectAtIndex:deliveryModeIndex];
    pickersSelections[deliveryMethodPicker] = deliveryModeIndex;

    __weak typeof(self) weakSelf = self;
    
    [self.b2bService setDeliveryModeWithCode:self.mode.code onCartWithCode:cart.code andExecute:^(HYBCart *cart, NSError *error) {
        NSString *fullInfo = [NSString stringWithFormat:@"%@ - %@",weakSelf.mode.name,weakSelf.mode.formattedValue];
        [weakSelf.mainView.deliveryMethodButton setText:fullInfo];
        [weakSelf.mainView.orderSummaryView.shippingValue setText:weakSelf.mode.formattedValue];
        
        [weakSelf refreshCartFromServer];
    }];
}

@end