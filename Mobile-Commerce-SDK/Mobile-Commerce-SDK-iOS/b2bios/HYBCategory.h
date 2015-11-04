//
// HYBCategory.h
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

/**
* The class representing a category for products. Categories contain products of a related group.
*/
@interface HYBCategory : NSObject

@property(nonatomic) NSString *id;
@property(nonatomic) NSString *name;
@property(nonatomic) NSString *url;

/**
 *  init category from dictionnary with parent category
 *
 *  @param attributes NSDictionary
 *  @param parent     HYBCategory
 *
 *  @return HYBCategory object
 */
- (id)initWithAttributes:(NSDictionary *)attributes parent:(HYBCategory *)parent;

/**
 *  init category from JSON array
 *
 *  @param categoriesAsJSON NSArray
 *
 *  @return HYBCategory object
 */
- (id)initWithAttributesAsTree:(NSArray *)categoriesAsJSON;

/**
 *  returns subcategories as array
 *
 *  @return NSArray of categories
 */
- (NSArray *)subCategories;

/**
 *  returns BOOL YES if category has subcategories
 *
 *  @return BOOL hasSubcategories
 */
- (BOOL)hasSubcategories;

/**
 *  returns category's parent category
 *
 *  @return HYBCategory parentCategory
 */
- (HYBCategory *)parentCategory;

/**
 *  check if a category id part of current catgory's children
 *
 *  @param categoryId NSString
 *
 *  @return BOOL category's subcategories contains given category id
 */
- (BOOL)hasChildId:(NSString *)categoryId;

/**
 *  check if category is root
 *
 *  @return BOOL is root category
 */
- (BOOL)isRoot;

/**
 *  returns an array with parent category at index 0 and subcategories following
 *
 *  @return NSMutableArray of categories
 */
- (NSMutableArray *)listItSelfIncludingChildren;

/**
 *  returns a category given its category id
 *
 *  @param categoryId NSString
 *
 *  @return HYBCategory category
 */
- (HYBCategory *)findCategoryByIdInsideTree:(NSString *)categoryId;

/**
 *  check if category is leaf of subcategories tree
 *
 *  @return BOOL is leaf (ie. has no subcategories)
 */
- (BOOL)isLeaf;

@end