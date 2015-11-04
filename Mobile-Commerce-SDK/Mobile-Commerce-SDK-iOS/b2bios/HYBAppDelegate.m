//
// HYBAppDelegate.m
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

#import "HYBAppDelegate.h"
#import "HYBLoginViewController.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"
#import "HYB2BService.h"
#import "HYBBackEndFacade.h"

@interface HYBAppDelegate ()
@end

@implementation HYBAppDelegate {
    UIImageView *snapshotSecurityBlocker;
}

@synthesize isGridView;

- (id)init {
    self = [super init];
    return self;
}

- (void)registerDefaultsFromSettingsBundle {
    
    NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    
    if (bundle) {
        NSDictionary *defaultSettings = [NSDictionary dictionaryWithContentsOfFile:[bundle stringByAppendingPathComponent:@"Root.plist"]];
        NSArray *prefs = [defaultSettings objectForKey:@"PreferenceSpecifiers"];
        NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[prefs count]];
        
        for (NSDictionary *prefSpecification in prefs) {
            NSString *key = [prefSpecification objectForKey:@"Key"];
            if (key) {
                [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //initialize Logging
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    isGridView = NO;

    [self registerDefaultsFromSettingsBundle];
    _backEndService = [[HYB2BService alloc] initWithDefaults];

    HYBLoginViewController *login = [[HYBLoginViewController alloc] initWithBackEndService:_backEndService];

    //setup main window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    //main navigation controller
    self.mainNavigationController = [[UINavigationController alloc] initWithRootViewController:login];
    self.mainNavigationController.navigationBarHidden = YES;

    self.window.rootViewController = self.mainNavigationController;
    [self.window makeKeyAndVisible];

    [self watchDynamicStyleChangesInSimulationMode];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (UIImageView *)createLogoView {
    UIImageView *imageHolder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo.png"]];
    imageHolder.contentMode = UIViewContentModeScaleAspectFit;
    return imageHolder;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    snapshotSecurityBlocker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];
    snapshotSecurityBlocker.frame = self.window.frame;
    snapshotSecurityBlocker.contentMode = UIViewContentModeCenter;

    UIView *logo = [self createLogoView];
    logo.center = snapshotSecurityBlocker.center;
    [snapshotSecurityBlocker addSubview:logo];

    [self.window addSubview:snapshotSecurityBlocker];
}


- (void)applicationDidBecomeActive:(UIApplication *)application{
    if(snapshotSecurityBlocker){
        [snapshotSecurityBlocker removeFromSuperview];
        snapshotSecurityBlocker = nil;
    }
}

- (void)watchDynamicStyleChangesInSimulationMode {
#if TARGET_IPHONE_SIMULATOR
    NSString *absoluteFilePath = CASAbsoluteFilePath(@"stylesheet.cas");
    [CASStyler defaultStyler].watchFilePath = absoluteFilePath;
#endif

}
@end
