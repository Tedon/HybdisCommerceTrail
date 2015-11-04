//
// HYBProductDetailsController.m
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


#import "HYBProductDetailsController.h"
#import "HYBProductDetailsView.h"
#import "HYBButton.h"
#import "HYBCart.h"
#import "NSObject+HYBAdditionalMethods.h"

@interface HYBProductDetailsController ()
@end

@implementation HYBProductDetailsController {
    HYBProductDetailsView *_mainView;
    CGPoint originCenter;
}

- (instancetype)initWithBackEndService:(id <HYBBackEndFacade>)b2bService productId:(NSString *)selectedProductId {

    if (self = [super initWithBackEndService:b2bService]) {
        _code = selectedProductId;
    }
    return self;
}

#pragma mark - General UI Buildup

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadProduct];

    //keyboard monitor
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self selector:@selector(keyboardDidShow:)
                   name:UIKeyboardDidShowNotification
                 object:nil];

    [center addObserver:self selector:@selector(keyboardWillHide:)
                   name:UIKeyboardWillHideNotification
                 object:nil];

}

//lock swipe back navigation gesture to let the drawers work
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark - Loading the shown product

- (void)loadView {
    [super loadView];
    if (!_mainView) {
        _mainView = [[HYBProductDetailsView alloc] initWithFrame:self.view.frame];
        _mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        UITapGestureRecognizer *tapGesture =
                [[UITapGestureRecognizer alloc] initWithTarget:self
                                                        action:@selector(backButtonPressed)];

        [_mainView.closeIcon addGestureRecognizer:tapGesture];

        _mainView.imagesScrollView.delegate = self;
        _mainView.imagesScrollView.pagingEnabled = YES;

        _mainView.masterScrollView.delegate = self;

        [_mainView.imagesScrollControl addTarget:self action:@selector(pageControlTapped) forControlEvents:UIControlEventValueChanged];

        [_mainView.addToCartButton addTarget:self action:@selector(addToCartPressed) forControlEvents:UIControlEventTouchUpInside];

        [_mainView.variantSelectionDoneButton addTarget:self action:@selector(variantSelectionDonePressed) forControlEvents:UIControlEventTouchUpInside];

        [_mainView.variantSelectionCancelButton addTarget:self action:@selector(dismissPicker) forControlEvents:UIControlEventTouchUpInside];
    }

    self.view = _mainView;
    originCenter = self.view.center;
}

- (void)loadProduct {
    DDLogDebug(@"Loading product with code %@", self.code);
    [self.b2bService findProductById:self.code withBlock:^(HYBProduct *product, NSError *error) {
        if (error) {
            DDLogError(@"Error while retrieving product with code %@, reason:", [error localizedDescription]);
        } else {
            DDLogDebug(@"Product loaded %@", [product name]);
            _product = product;

            [_mainView loadProductDetails:product];
            [self loadAllProductImages:product];
            [self addToCartButtonState];
        }
    }];
}

- (void)addToCartButtonState {

    if ([[_product stock] intValue] > 0) {
        [_mainView.addToCartButton setEnabled:YES];
        [_mainView.addToCartButton setCas_styleClass:@"primaryButton addToCartButton"];
    } else {
        [_mainView.addToCartButton setEnabled:NO];
        [_mainView.addToCartButton setCas_styleClass:@"primaryButton disabled addToCartButton"];
    }
}

- (void)loadAllProductImages:(HYBProduct *)product {
    [self.b2bService loadImagesForProduct:product block:^(NSMutableArray *fetchedImages, NSError *error) {
        if (error) {
            DDLogError(@"Can not retrieve images for product %@ - %@", product.code, [error localizedDescription]);
        } else {
            DDLogDebug(@"Retrieved %lu images, starting controller images init...", (unsigned long) [fetchedImages count]);
            [_mainView loadImagesInView:fetchedImages];
        }
    }];
}

#pragma mark - IBActions and Reactions

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _mainView.imagesScrollView) {
        CGFloat pageWidth = _mainView.imagesScrollView.frame.size.width;
        NSInteger newCurrent = (NSInteger) floor((_mainView.imagesScrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
        _mainView.imagesScrollControl.currentPage = newCurrent;
    }
}

- (void)pageControlTapped {
    CGFloat pageWidth = _mainView.imagesScrollView.frame.size.width;
    CGPoint scrollTo = CGPointMake(pageWidth * _mainView.imagesScrollControl.currentPage, 0);
    [_mainView.imagesScrollView setContentOffset:scrollTo animated:YES];
}

- (void)dismissPicker {
    [_mainView hideVariantPicker];
}

- (void)variantSelectionDonePressed {
    DDLogVerbose(@"Variant Selection done pressed.");

    [self dismissPicker];

    NSString *newSelectedProductCode = _mainView.selectedVariantCode;
    if (newSelectedProductCode) {
        _code = newSelectedProductCode;
        DDLogVerbose(@"New variant code was set to %@", _code);
        [self loadProduct];
    }
}

- (void)backButtonPressed {
    DDLogVerbose(@"Navigating back to the categories ...");
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)addToCartPressed {
    DDLogVerbose(@"Adding items to cart");

    NSNumber *amountToAdd = [_mainView currentQuantity];

    if (amountToAdd.intValue > 0) {
        if (amountToAdd.intValue > [_product.stock intValue]) {
            amountToAdd = [[NSNumber alloc] initWithInt:[[_product stock] intValue]];
        }

        [[self b2bService] addProductToCurrentCart:_product.code amount:amountToAdd block:^(HYBCart *cart, NSString *msg) {
            if ([cart hyb_isNotBlank]) {
                [_mainView setQTY:@"1"];
            } else {
                DDLogError(@"Product %@ not added to cart. Reason is %@", _product.code, msg);
            }
            [self showNotifyMessage:msg];
        }];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification {

    [UIView animateWithDuration:defaultAnimationDuration
                     animations:^() {
                         _mainView.masterScrollView.contentOffset = CGPointMake(0, 120);
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {

    [UIView animateWithDuration:defaultAnimationDuration
                     animations:^() {
                         _mainView.masterScrollView.contentOffset = CGPointMake(0, 0);
                     }];

}

@end
