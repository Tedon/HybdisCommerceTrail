//
// HYBWebviewController.m
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


#import "HYBWebviewController.h"

@interface HYBWebviewController ()
@property(nonatomic, strong) UIWebView *webview;

@end

@implementation HYBWebviewController

- (id)initWithLink:(NSString *)link {
    return [self initWithURL:[NSURL URLWithString:link]];
}

- (id)initWithURL:(NSURL *)url {

    self = [super init];

    if (self) {
        self.webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
        [self.webview loadRequest:[NSURLRequest requestWithURL:url]];
        [self.view addSubview:self.webview];
    }

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //adapt back button color
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

@end
