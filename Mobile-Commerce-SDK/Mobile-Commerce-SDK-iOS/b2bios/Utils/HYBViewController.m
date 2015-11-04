//
// HYBViewController.m
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


#import "HYBViewController.h"

@interface HYBViewController ()

@end

@implementation HYBViewController


- (instancetype)initWithBackEndService:(id <HYBBackEndFacade>)b2bService {
    if(self = [super init]) {
        _b2bService = b2bService;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // listener for any cart change that will update the cart in header
    [self observeCartUpdatesAndShowInHeader];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSearchIconState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
