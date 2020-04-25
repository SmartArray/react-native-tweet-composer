
#import <TwitterKit/TWTRKit.h>
#import "RNReactNativeTwitterComposer.h"

@implementation RNReactNativeTwitterComposer

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(init: (NSString *)consumerKey consumerSecret:(NSString *)consumerSecret)
{
    [[Twitter sharedInstance] startWithConsumerKey:consumerKey consumerSecret:consumerSecret];
    return 0;
}

RCT_EXPORT_METHOD(logIn: (RCTPromiseResolveBlock)resolve
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
            reject(@"Error", @"Twitter signin error", error);
        }
    }];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(createTweet: (void*)resolve)
{
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    return composer;
}

RCT_EXPORT_METHOD(logOut)
{
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSString *userID = store.session.userID;
    [store logOutUserID:userID];
}

@end
  
