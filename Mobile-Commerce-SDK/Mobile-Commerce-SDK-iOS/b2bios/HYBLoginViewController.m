//
// HYBLoginViewController.m
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


#import "HYBLoginViewController.h"
#import "HYBUser.h"
#import "NSError+HYErrorUtils.h"
#import "UIViewController+HYBBaseController.h"
#import "HYBLoginView.h"
#import "HYB2BService.h"
#import "HYBCart.h"
#import "HYBActivityIndicator.h"
#import "NSObject+HYBAdditionalMethods.h"
#import "HYBAppDelegate.h"

@interface HYBLoginViewController ()
@property(nonatomic) HYBLoginView *mainView;
@end

@implementation HYBLoginViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [_b2bService resetPagination];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:STORAGE_CURRENTLY_SHOWN_CATEGORY_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    HYBUser *lastAuthenticatedUser = [[_b2bService userStorage] objectForKey:LAST_AUTHENTICATED_USER_KEY];
    if (lastAuthenticatedUser) {
        DDLogDebug(@"An authenticated user from last time exist, skipping login.");
        [self navigateToMainMenu];
    } else {
        DDLogDebug(@"Login window will be rendered.");
        NSString *username = [[_b2bService userStorage] objectForKey:PREVIOUSLY_AUTHENTICATED_USER_KEY];
        if (username) {
            DDLogDebug(@"Found previous user data, prefilling the login.");
            [[self mainView] userName].text = username;
            [[self mainView] password].text = @"";
            [[[self mainView] password] becomeFirstResponder];
        }
    }
}

- (BOOL)isPreviouslyAuthenticatedUser:(NSString *)username {
    NSString *authenticatedUserName = [[_b2bService userStorage] objectForKey:LAST_AUTHENTICATED_USER_KEY];
    if (authenticatedUserName) {
        return [authenticatedUserName isEqualToString:username];
    } else {
        return NO;
    }
}

- (instancetype)initWithBackEndService:(id <HYBBackEndFacade>)b2bService {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        NSAssert(b2bService != nil, @"Service must be present.");
        _b2bService = b2bService;
    }
    return self;
}

- (BOOL)isValidEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (void)loadView {
    [super loadView];
    self.view = self.mainView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (HYBLoginView *)mainView {
    if (!_mainView) {
        _mainView = [HYBLoginView new];
        _mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [[_mainView loginButton] addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _mainView.userName.delegate = self;
        _mainView.password.delegate = self;
        
        [_mainView.userName addTarget:self
                               action:@selector(usernameFieldChanged)
                     forControlEvents:UIControlEventEditingChanged];
        
        [_mainView.password addTarget:self
                               action:@selector(passwordFieldChanged)
                     forControlEvents:UIControlEventEditingChanged];
        
    }
    return _mainView;
}

#pragma mark Text Field delegate 

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self updateButtonState];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _mainView.userName) {
        [_mainView.password becomeFirstResponder];
    }
    
    if (textField == _mainView.password) {
        [self loginButtonPressed];
    }
    
    return NO;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    textField.text = @"";
    [self updateButtonState];
    return NO;
}

-(void)updateButtonState {
    
    if ([self canUseLoginButton]) {
        _mainView.loginButton.cas_styleClass = @"primaryButton groupBegin";
        _mainView.loginButton.enabled = YES;
    } else {
        _mainView.loginButton.cas_styleClass = @"primaryButton disabled groupBegin";
        _mainView.loginButton.enabled = NO;
    }
}


- (void)usernameFieldChanged {
    [self updateButtonState];
}

- (void)passwordFieldChanged {
    [self updateButtonState];
}

#pragma mark Login Actions

- (IBAction)loginButtonPressed {

    NSString *username = [[[self mainView] userName] text];
    NSString *pass = [[[self mainView] password] text];

    DDLogDebug(@"Login button pressed ...");
    
    if([self canUseLoginButton]) [self loginWithUser:username pass:pass];
}

- (BOOL)canUseLoginButton {
    NSString *username = [[[self mainView] userName] text];
    NSString *pass = [[[self mainView] password] text];
    
    if(username && username.length > 0 && pass && (pass.length > 0 || ![pass isEqualToString:@""])) {
        return YES;
    }

    return NO;
}

- (void)loginWithUser:(NSString *)user pass:(NSString *)pass {
    
    [HYBActivityIndicator show];
        
    [self.b2bService authenticateUser:user password:pass block:^(NSString *errorMsgOrToken, NSError *error) {
        
        [HYBActivityIndicator hide];
        
        if (error) {
            DDLogDebug(@"Error retrieved ...");
            [[self mainView] password].text = @"";
            [self updateButtonState];
            if ([error isConnectionOfflineError]) {
                if ([self isPreviouslyAuthenticatedUser:user]) {
                    DDLogError(@"Offline error found but the user was authenticated before, "
                            "cache is used: %@", [error localizedDescription]);
                } else {
                    [self showAlertMessage:NSLocalizedString(@"login_first_time_not_connected", nil) withTitle:NSLocalizedString(@"login_alert_failed", nil) cancelButtonText:NSLocalizedString(@"OK", @"OK")];
                }
            } else {
                if ([self isValidEmail:user]) {
                    [self showAlertMessage:errorMsgOrToken withTitle:NSLocalizedString(@"login_alert_failed", nil) cancelButtonText:NSLocalizedString(@"OK", @"OK")];
                } else {
                    [self showAlertMessage:NSLocalizedString(@"login_invalid_email", @"Explain the user the provided "
                            "email is not a valid email format.") withTitle:NSLocalizedString(@"login_alert_failed", nil) cancelButtonText:NSLocalizedString(@"OK", @"OK")];
                }
            }
        } else {
            [self.b2bService costCentersForCurrentStoreAndExecute:^(NSArray *array, NSError *err) {
                if([array hyb_isNotBlank]){
                    DDLogInfo(@"Current cost centers are preloaded.");
                } else {
                    DDLogWarn(@"No cost centers could be found, this is an invalid state, please check the back end data configuration.");
                }
            }];
            [self.b2bService retrieveCartByUserIdFromCurrentCartsCreateIfNothingPresent:user andExecute:^(HYBCart *cart, NSError *error) {
                if (cart) {
                    DDLogInfo(@"Cart for user retrieved after login");
                } else {
                    DDLogError(@"Cart for user not retrieved after login, this is an error, verify backend functionality. "
                               "It is assumed that a cart will exist at this point. Backend error is %@", error.localizedDescription);
                }
            }];
           
            [_b2bService resetPagination];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:STORAGE_CURRENTLY_SHOWN_CATEGORY_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self navigateToMainMenu];
        }
    }];
}

@end
