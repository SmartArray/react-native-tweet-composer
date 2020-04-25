import { NativeModules } from 'react-native';
const { RNReactNativeTwitterComposer } = NativeModules;

import resolveAssetSource from 'react-native/Libraries/Image/resolveAssetSource';

class RNReactNativeTwitterComposerWrapper {
  constructor() {
  }

  init(key, secret) {
    return RNReactNativeTwitterComposer.init(key, secret);
  }

  signIn() {
    return RNReactNativeTwitterComposer.signIn();
  }

  createTweet(options) {
    const opt = Object.assign({}, options);
    if (opt.image) {
      if (typeof opt.image == 'number') {
        // Most likely a bundle id, resolve!!
        opt.image = resolveAssetSource(opt.image);
      }
    }

    return RNReactNativeTwitterComposer.createTweet(opt);    
  }

  logout() {
    return RNReactNativeTwitterComposer.logout(opt);
  }
}

export default new RNReactNativeTwitterComposerWrapper();