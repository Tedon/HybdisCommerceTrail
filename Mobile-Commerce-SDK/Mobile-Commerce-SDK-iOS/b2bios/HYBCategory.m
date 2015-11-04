//
// HYBCategory.m
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


#import "HYBCategory.h"
#import "NSObject+HYBAdditionalMethods.h"

@implementation HYBCategory {
    NSArray *_subcategories;
    HYBCategory *_parent;
}

- (id)initWithAttributes:(NSDictionary *)attributes parent:(HYBCategory *)parent {
    if (attributes == nil) {
        NSString *reason = @"Please provide valid attributes for this category.";
        @throw [[NSException alloc] initWithName:@"InitException" reason:reason userInfo:nil];
    }
    self = [super init];
    if (self) {
        _parent = parent;
        self.id = [attributes objectForKey:@"id"];
        self.name = [attributes objectForKey:@"name"];
        if(![self.name hyb_isNotBlank]){
            self.name = self.id;
        }
        self.url = [attributes objectForKey:@"url"];

        _subcategories = [NSArray array];

        id subCats = [attributes objectForKey:@"subcategories"];
        if (subCats) {
            NSArray *cats = (NSArray *) subCats;
            NSMutableArray *catsContainer = [[NSMutableArray alloc] initWithCapacity:[cats count]];
            [cats enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [catsContainer addObject:[[HYBCategory alloc] initWithAttributes:obj parent:self]];
            }];
            _subcategories = [[NSArray alloc] initWithArray:catsContainer];
        }
    }
    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"%@: ", NSStringFromClass([self class])];

    if([self isRoot]){
        [description appendString:@",Root: "];
    }
    [description appendString:self.name];
    if ([self hasSubcategories]) {
        NSString *subCats = [[NSString alloc] initWithFormat:@", Subcategories:%lu", (unsigned long)[[self subCategories] count]];
        [description appendString:subCats];
    }
    return description;
}

- (id)initWithAttributesAsTree:(NSDictionary *)categoriesAsJSON {
    return [self initWithAttributes:categoriesAsJSON parent:nil];
}

- (NSArray *)subCategories {
    return _subcategories;
}

- (BOOL)hasSubcategories {
    return [_subcategories count] > 0;
}

- (HYBCategory *)parentCategory {
    return _parent;
}

- (BOOL)isRoot {
    return self.parentCategory == nil;
}

- (NSMutableArray *)listItSelfIncludingChildren {
    NSMutableArray *categoriesContainer = [[NSMutableArray alloc] initWithObjects:self, nil];
    [categoriesContainer addObjectsFromArray:[self subCategories]];
    return categoriesContainer;
}

- (HYBCategory *)findCategoryByIdInsideTree:(NSString *)categoryId {
    HYBCategory *result = nil;
    NSString *ownId = self.id;
    if ([categoryId isEqualToString:ownId]) {
        result = self;
    } else {
        if ([self hasSubcategories]) {
            for (HYBCategory *currentCat in [self subCategories]) {
                result = [currentCat findCategoryByIdInsideTree:categoryId];
                if (result != nil) {
                    break;
                }
            }
        }
    }
    return result;
}

- (BOOL)hasChildId:(NSString *)categoryId {
    return ([self findCategoryByIdInsideTree:categoryId] != nil);
}

- (BOOL)isLeaf {
    return ![self hasSubcategories];
}
@end