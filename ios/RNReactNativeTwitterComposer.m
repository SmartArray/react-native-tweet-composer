
#import <React/RCTConvert.h>
#import <TwitterKit/TWTRKit.h>
#import "RNReactNativeTwitterComposer.h"

@implementation RNReactNativeTwitterComposer

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
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
//    TWTRComposer *composer = [[TWTRComposer alloc] init];
    
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    // Check if current session has users logged in
    if ([[Twitter sharedInstance].sessionStore hasLoggedInUsers]) {
        TWTRComposerViewController *composer = [TWTRComposerViewController emptyComposer];
        UIImage* image = nil;
        
        if (options[@"image"] != nil) {
            image = [RCTConvert UIImage:options[@"image"]];
        }
        
        composer = [composer initWithInitialText:options[@"text"] image:image videoData:nil];
        [vc presentViewController:composer animated:YES completion:nil];
        resolve(nil);
    } else {
        [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
            if (session) {
                TWTRComposerViewController *composer = [TWTRComposerViewController emptyComposer];
                UIImage* image = nil;
                
                if (options[@"image"] != nil) {
                    image = [RCTConvert UIImage:options[@"image"]];
                }
                
                composer = [composer initWithInitialText:options[@"text"] image:image videoData:nil];
                [vc presentViewController:composer animated:YES completion:nil];
                resolve(nil);
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

@end
