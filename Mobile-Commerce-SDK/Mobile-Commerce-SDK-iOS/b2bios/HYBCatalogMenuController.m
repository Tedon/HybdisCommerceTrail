//
// HYBCatalogMenuController.m
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

#import "HYBCatalogMenuController.h"
#import "HYBCategory.h"
#import "HYBCatalogMenuView.h"
#import "HYB2BService.h"

@implementation HYBCatalogMenuController {
    NSArray *_categories;
    HYBCategory *_categoriesTree;
    HYBCatalogMenuView *_mainView;
}

- (instancetype)initWithBackEndService:(id <HYBBackEndFacade>)b2bService {
    if (self = [super initWithBackEndService:b2bService]) {
        _categories = [NSArray array];
        [self loadCategories];

    }
    return self;
}

- (void)loadView {
    [super loadView];

    if (!_mainView) {
        _mainView = [[HYBCatalogMenuView alloc] init];
        _mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    self.view = _mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _mainView.categoriesTable.delegate = self;
    _mainView.categoriesTable.dataSource = self;
}

- (void)forceReload {
    [_mainView.categoriesTable reloadData];
}

- (BOOL)isClosedMenu {
    DDLogDebug(@"Is open menu on %@ with current shown category %@", self, _currentlyShownCat);
    if (_currentlyShownCat == nil) {
        return NO;
    } else {
        return [_currentlyShownCat isLeaf];
    }
}

- (void)loadCategories {
    [self.b2bService resetPagination];

    [self.b2bService findCategoriesWithBlock:^(NSArray *foundCategories, NSError *error) {
        if (error) {
            DDLogError(@"Problems during the retrieval of the categories: %@", [error localizedDescription]);
        } else {
            if ([foundCategories count] > 0) {
                _categoriesTree = [foundCategories firstObject];
            }
            DDLogDebug(@"category tree loaded with %@", _categoriesTree);
            [self setCategoriesRefresh:foundCategories];
        }
    }];
}

- (void)setCategoriesRefresh:(NSArray *)categories {
    if (_currentlyShownCat == nil) {
        DDLogDebug(@"Currently shown not found, starting full load...");
        NSString *lastShownCatId = [[self.b2bService userStorage] objectForKey:STORAGE_CURRENTLY_SHOWN_CATEGORY_KEY];
        if (lastShownCatId) {
            DDLogDebug(@"Last time stored %@ was found and will be rendered", lastShownCatId);
            if (_categoriesTree != nil && [_categoriesTree hasSubcategories]) {
                DDLogDebug(@"Saved category ID found %@, retrieving category from tree by id.", lastShownCatId);
                HYBCategory *startCat = [_categoriesTree findCategoryByIdInsideTree:lastShownCatId];
                NSAssert(startCat != nil, @"The category for stored id %@ is nil", lastShownCatId);
                [self setNavigationFromStartCategory:startCat];
            } else {
                DDLogWarn(@"Categories Tree seems to benot fully loaded.");
            }
        } else {
            DDLogDebug(@"No last saved found.");
            if ([[categories firstObject] isRoot]) {
                DDLogDebug(@"Root category identified as _currentlyShownCateogry and will be set ...");
                HYBCategory *startCategory = [categories firstObject];
                [self setNavigationFromStartCategory:startCategory];
            } else {
                NSString *msg = @"A wrong state in the navigation has occured, there must be either a last shown "
                        "category saved or the delivered category must be the root.";
                @throw([NSException exceptionWithName:@"InitException" reason:msg userInfo:nil]);
            }
        }
    } else {
        [self setNavigationFromStartCategory:_currentlyShownCat];
    }
    
    [_mainView.categoriesTable reloadData];
}


- (void)setNavigationFromStartCategory:(HYBCategory *)startCategory {
    NSAssert(startCategory != nil, @"Start category was nil.");
    [self setCurrentlyShown:startCategory];
    if ([_currentlyShownCat hasSubcategories]) {
        if ([startCategory isRoot]) {
            _categories = [startCategory subCategories];
        } else {
            _categories = [_currentlyShownCat listItSelfIncludingChildren];
        }
    } else {
        _categories = [[_currentlyShownCat parentCategory] listItSelfIncludingChildren];
    }
}


- (HYBCategory *)categoryAtIndex:(int)row {
    return [_categories objectAtIndex:row];
}


- (NSArray *)navigateToCategoryAtPosition:(int)row {
    NSMutableArray *result = nil;

    HYBCategory *selectedCategory = [self categoryAtIndex:row];

    BOOL shouldNavigateToParent = selectedCategory == _currentlyShownCat;

    DDLogDebug(@"selected category is %@", selectedCategory);
    if (shouldNavigateToParent) {
        DDLogDebug(@"Navigation to parent ...");
        HYBCategory *parentOfSelected = [selectedCategory parentCategory];
        if ([parentOfSelected isRoot]) {
            DDLogDebug(@"Parent is root, no higher categories are present, staying at the same level.");
            result = [NSMutableArray arrayWithArray:[parentOfSelected subCategories]];
        } else {
            DDLogDebug(@"Setting to content of category %@ its subcategories are %@", parentOfSelected, [parentOfSelected subCategories]);
            result = [parentOfSelected listItSelfIncludingChildren];
        }
        [self setCurrentlyShown:parentOfSelected];
    } else {
        if ([selectedCategory hasSubcategories]) {
            DDLogDebug(@"Selected %@ has subcategories %@", selectedCategory, [selectedCategory subCategories]);
            [self setCurrentlyShown:selectedCategory];
            result = [selectedCategory listItSelfIncludingChildren];
        } else {
            DDLogDebug(@"Selected %@ has NO subcategories ...", selectedCategory);
            [self setCurrentlyShown:[selectedCategory parentCategory]];
            result = [[selectedCategory parentCategory] listItSelfIncludingChildren];
        }
    }
    return [[NSArray alloc] initWithArray:result];
}

- (void)setCurrentlyShown:(HYBCategory *)currentlyShown {
    DDLogDebug(@"Setting currently shown to %@", currentlyShown);
    
    _currentlyShownCat = currentlyShown;
    [[self.b2bService userStorage] setObject:currentlyShown.id forKey:STORAGE_CURRENTLY_SHOWN_CATEGORY_KEY];
    [[self.b2bService userStorage] synchronize];
}

#pragma mark Table Delegate Implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_categories count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CATEGORIES_MENU_CELL_ID];
    [cell setUserInteractionEnabled:YES];
    cell.imageView.image = nil;
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setAccessoryView:nil];
    [cell setCas_styleClass:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BOOL hasSubcategories = NO;
    BOOL applyBlackStyle  = NO;
    BOOL applySelectStyle = NO;
   

    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"sidebar_main_menu", @"Main Menu");
        cell.accessibilityIdentifier = @"ACCESS_CATALOG_MENU_ITEM_MAINMENU";
        cell.imageView.image = [UIImage imageNamed:@"Arrow_drawerBack.png"];        
        [cell cas_addStyleClass:@"mainNavCell"];
    } else {
        HYBCategory *category = [self categoryAtIndex:(int)[indexPath row]-1];
        cell.textLabel.text = category.name;
        cell.accessibilityIdentifier = [NSString stringWithFormat:@"%@_%ld", @"ACCESS_CATALOG_MENU_ITEM", (long)[indexPath row]];
        
        NSString *lastShownCatId = [[self.b2bService userStorage] objectForKey:STORAGE_CURRENTLY_SHOWN_CATEGORY_KEY];
        
        if(category == _currentlyShownCat) {
            if (indexPath.row == 1) {
                applyBlackStyle = YES;
            } else {
                applySelectStyle = YES;
            }
        } else {
            if (indexPath.row == 1 && [category hasChildId:lastShownCatId])  applyBlackStyle = YES;
            else if (indexPath.row > 0 && [category hasSubcategories]) hasSubcategories = YES;
        }
    }
    
    if (applySelectStyle) {
        [cell cas_addStyleClass:@"selectedCell"];
    }
    
    if (applyBlackStyle) {
        cell.imageView.image = [UIImage imageNamed:@"Arrow_drawerBack.png"];
        cell.imageView.accessibilityIdentifier = @"ACCESS_CATALOG_MENU_ITEM_L_ARROW";
    } else {
        if(hasSubcategories) {
            [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arrow_drawerNext.png"]]];
            cell.accessoryView.accessibilityIdentifier = @"ACCESS_CATALOG_MENU_ITEM_R_ARROW";
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
        }
    }
    
    [cell cas_setNeedsUpdateStylingForSubviews];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = (int)[indexPath row];
    if (row == 0) {
        DDLogDebug(@"Navigating to Main Menu ...");        
        [self navigateToMainMenu];
    } else {
        int selectedCategoryIndex = row - 1;

        HYBCategory *tappedCategory = [_categories objectAtIndex:selectedCategoryIndex];
        
        DDLogDebug(@"Category %@ was tapped.", tappedCategory);
        
        if ([tappedCategory isLeaf]) {
            DDLogDebug(@"Leaf category tapped, closing the drawer.");
            [[self mm_drawerController] closeDrawerAnimated:YES completion:nil];
            [self setCurrentlyShown:tappedCategory];
            [self openCategoryInCatalog:tappedCategory];
        } else {
            DDLogDebug(@"Category with sub categories tapped, refreshing the categories list.");
            NSArray *resultingCategories = [self navigateToCategoryAtPosition:selectedCategoryIndex];
            [self setCategoriesRefresh:resultingCategories];
            [self openCategoryInCatalog:_currentlyShownCat];
        }        
    }
}

@end