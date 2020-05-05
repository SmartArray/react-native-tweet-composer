
#import <React/RCTConvert.h>
#import <TwitterKit/TWTRKit.h>
#import "RNReactNativeTwitterComposer.h"


@implementation RNReactNativeTwitterComposer

// Global variable is ok in this case, as only one tweet composer will be shown per time
RCTPromiseResolveBlock lastResolver;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)viewController {
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)viewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navContObj = (UINavigationController*)viewController;
        return [self topViewControllerWithRootViewController:navContObj.visibleViewController];
    } else if (viewController.presentedViewController && !viewController.presentedViewController.isBeingDismissed) {
        UIViewController* presentedViewController = viewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    }
    else {
        for (UIView *view in [viewController.view subviews])
        {
            id subViewController = [view nextResponder];
            if ( subViewController && [subViewController isKindOfClass:[UIViewController class]])
            {
                if ([(UIViewController *)subViewController presentedViewController]  && ![subViewController presentedViewController].isBeingDismissed) {
                    return [self topViewControllerWithRootViewController:[(UIViewController *)subViewController presentedViewController]];
                }
            }
        }
        return viewController;
    }
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(init: (NSString *)consumerKey
                  consumerSecret:(NSString *)consumerSecret
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [[Twitter sharedInstance] startWithConsumerKey:consumerKey consumerSecret:consumerSecret];
    resolve(nil);
}

RCT_EXPORT_METHOD(signIn: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession * _Nullable sessionData, NSError * _Nullable error) {
        if (sessionData) {
            TWTRAPIClient *client = [TWTRAPIClient clientWithCurrentUser];

            [client requestEmailForCurrentUser:^(NSString *email, NSError *error) {
                NSString *requestedEmail = (email) ? email : @"";
                NSDictionary *body = @{@"authToken": sessionData.authToken,
                                       @"userID":sessionData.userID,
                                       @"email": requestedEmail,
                                       @"userName":sessionData.userName,
                                       @"authTokenSecret": sessionData.authTokenSecret};
                resolve(body);
            }];
        } else {
            reject(@"Error", @"Twitter SignIn Error", error);
        }
    }];
}

RCT_EXPORT_METHOD(createTweet: (NSDictionary*)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    UIViewController* vc = RNReactNativeTwitterComposer.topViewController;
    lastResolver = resolve;
    
    // Check if current session has users logged in
    if ([[Twitter sharedInstance].sessionStore hasLoggedInUsers]) {
        TWTRComposerViewController *composer = [TWTRComposerViewController emptyComposer];
        composer.delegate = self;
        UIImage* image = nil;
        
        if (options[@"image"] != nil) {
            image = [RCTConvert UIImage:options[@"image"]];
        }
        
        composer = [composer initWithInitialText:options[@"text"] image:image videoData:nil];
        [vc presentViewController:composer animated:YES completion:nil];
    } else {
        [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
            if (session) {
                TWTRComposerViewController *composer = [TWTRComposerViewController emptyComposer];
                composer.delegate = self;
                UIImage* image = nil;
                
                if (options[@"image"] != nil) {
                    image = [RCTConvert UIImage:options[@"image"]];
                }
                
                composer = [composer initWithInitialText:options[@"text"] image:image videoData:nil];
                [vc presentViewController:composer animated:YES completion:nil];
            } else {
                reject(@"Error", @"Not signed in", error);
            }
        }];
    }
}

RCT_EXPORT_METHOD(logout)
{
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSString *userID = store.session.userID;
    [store logOutUserID:userID];
}

- (void)composerDidSucceed:(TWTRComposerViewController *)controller withTweet:(TWTRTweet *)tweet {
    NSDictionary *body = @{@"tweetID": tweet.tweetID};
    lastResolver(body);
}

@end
