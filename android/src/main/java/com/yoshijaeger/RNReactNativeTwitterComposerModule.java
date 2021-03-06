
package com.yoshijaeger;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.twitter.sdk.android.core.DefaultLogger;
import com.twitter.sdk.android.core.Result;
import com.twitter.sdk.android.core.SessionManager;
import com.twitter.sdk.android.core.Twitter;
import com.twitter.sdk.android.core.TwitterAuthConfig;
import com.twitter.sdk.android.core.TwitterAuthToken;
import com.twitter.sdk.android.core.TwitterConfig;
import com.twitter.sdk.android.core.TwitterCore;
import com.twitter.sdk.android.core.TwitterException;
import com.twitter.sdk.android.core.TwitterSession;
import com.twitter.sdk.android.tweetcomposer.ComposerActivity;
import com.twitter.sdk.android.tweetcomposer.TweetComposer;
import com.twitter.sdk.android.core.identity.TwitterAuthClient;
import java.util.Map;
import java.util.Set;

@ReactModule(name="RNReactNativeTwitterComposer")
public class RNReactNativeTwitterComposerModule extends ReactContextBaseJavaModule implements ActivityEventListener {

  public static String TAG = "RNReactNativeTwitterComposer";
  private final ReactApplicationContext reactContext;
  TwitterAuthClient twitterAuthClient;

  public RNReactNativeTwitterComposerModule(ReactApplicationContext reactContext) {
    super(reactContext);
    reactContext.addActivityEventListener(this);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return TAG;
  }

  @ReactMethod
  public void init(String consumerKey, String consumerSecret, Promise promise) {
    TwitterConfig config = new TwitterConfig.Builder(this.reactContext)
            .logger(new DefaultLogger(Log.DEBUG))
            .twitterAuthConfig(new TwitterAuthConfig(consumerKey, consumerSecret))
            .debug(true)
            .build();
    Twitter.initialize(config);
    WritableMap map = Arguments.createMap();
    promise.resolve(map);
  }

  @ReactMethod
  public void signIn(final Promise promise) {
    twitterAuthClient = new TwitterAuthClient();
    twitterAuthClient.authorize(getCurrentActivity(), new com.twitter.sdk.android.core.Callback<TwitterSession>() {
      @Override
      public void success(Result<TwitterSession> result) {
        final TwitterSession session = result.data;
        TwitterAuthToken twitterAuthToken = session.getAuthToken();
        final WritableMap map = Arguments.createMap();
        map.putString("authToken", twitterAuthToken.token);
        map.putString("authTokenSecret", twitterAuthToken.secret);
        map.putString("name", session.getUserName());
        map.putString("userID", Long.toString(session.getUserId()));
        map.putString("userName", session.getUserName());
        twitterAuthClient.requestEmail(session, new com.twitter.sdk.android.core.Callback<String>() {
          @Override
          public void success(Result<String> result) {
            map.putString("email", result.data);
            promise.resolve(map);
          }

          @Override
          public void failure(TwitterException exception) {
            map.putString("email", "COULD_NOT_FETCH");
            promise.reject(
                    "COULD_NOT_FETCH",
                    map.toString(),
                    new Exception("Failed to obtain email", exception));
          }
        });
      }

      @Override
      public void failure(TwitterException exception) {
        promise.reject("USER_CANCELLED", exception.getMessage(), exception);
      }
    });
  }

  @ReactMethod
  public void createTweet(ReadableMap options, final Promise promise) {
    final TwitterSession session = TwitterCore.getInstance()
            .getSessionManager()
            .getActiveSession();

    ComposerActivity.Builder builder = new ComposerActivity.Builder(reactContext.getCurrentActivity());
    builder = builder.session(session);

    if (options.hasKey("text")) {
      builder = builder.text(options.getString("text"));
    }

    if (options.hasKey("image")) {
      ReadableMap image = options.getMap("image");
      Uri uri = Uri.parse(image.getString("uri"));
      builder = builder.image(uri);
    }

    final Intent intent = builder.createIntent();
    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

    reactContext.startActivity(intent);
  }

  @ReactMethod
  public void logout() {

    TwitterCore instance = TwitterCore.getInstance();
    SessionManager<TwitterSession> sessionManager = instance.getSessionManager();
    Map<Long, TwitterSession> sessions = sessionManager.getSessionMap();
    System.out.println("TWITTER SEESIONS " + +sessions.size());
    Set<Long> sessids = sessions.keySet();
    for (Long sessid : sessids) {
      System.out.println("TWITTER SESSION CLEARING " + sessid);
      instance.getSessionManager().clearSession(sessid);
    }

    sessionManager.clearActiveSession();
  }

  @Override
  public void onNewIntent(Intent intent) {
  }

  @Override
  public void onActivityResult(Activity currentActivity, int requestCode, int resultCode, Intent data) {
    if (twitterAuthClient != null && twitterAuthClient.getRequestCode() == requestCode) {
      twitterAuthClient.onActivityResult(requestCode, resultCode, data);
    }
  }
}