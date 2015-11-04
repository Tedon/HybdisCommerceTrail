//
// HYBCartController.h
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
#import "HYBSideDrawer.h"

@class HYB2BService;
@class HYBCartView;


@interface HYBCartController : UIViewController <HYBSideDrawer, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic) BOOL isBatchDeleting;
@property (nonatomic) BOOL isCartEmpty;
@property (nonatomic) BOOL validAmount;

- (id)initWithBackEndService:(HYB2BService *)b2bService;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView;

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end