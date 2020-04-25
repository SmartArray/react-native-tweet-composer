/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React from 'react';
import {
  SafeAreaView,
  StyleSheet,
  ScrollView,
  View,
  Text,
  StatusBar,
  TouchableOpacity,
  Image,
} from 'react-native';

// Import Native Module
import RNReactNativeTwitterComposer from 'react-native-tweet-composer';

// Import API Keys specified in .env file (located in your project root dir)
import Config from 'react-native-config';

const Porenta = require('./porenta.jpg')

class TwitterTestView extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      signedIn: false,
    };
  }

  _login = () => {
    // Opens a window showing the application login and authorization process.
    RNReactNativeTwitterComposer.signIn().then(data => {
      // These are the response properties.
      // Email will only be set if the permissions are set accordingly. 
      const {
        userID,
        email,
        userName,
        authTokenSecret,
        authToken
      } = data;

      console.log(`Signed in! TwitterData = ${JSON.stringify(data)}`);
      this.setState({ signedIn: true });
    }).catch(e => {
      this.setState({ signedIn: false });
      console.error(e);
    });
  }

  _tweet = () => {
    RNReactNativeTwitterComposer.createTweet({
      text: 'Hi there! Lets try to tag someone @elonmusk',
      image: Porenta
    }).then((msg) => {
      console.log(msg);
    }).catch(e => {
      console.error(e);
    });
  }

  componentDidMount() {
    RNReactNativeTwitterComposer.init(Config.TWITTER_KEY, Config.TWITTER_SECRET).then(() => {
      console.log('Initialized');
    }).catch(e => {
      console.error('Not Initialized:', e);
    });
  }

  render() {
    if (!this.state.signedIn) {
      return (
        <View style={styles.body}>
          <TouchableOpacity style={styles.button} onPress={this._logout}>
            <Text style={styles.buttonText}>Logout</Text>
          </TouchableOpacity>

          <Image source={Porenta} />

          <TouchableOpacity style={styles.button} onPress={this._tweet}>
            <Text style={styles.buttonText}>Tweet</Text>
          </TouchableOpacity>          
        </View>
      );
    } else {
      return (
        <View style={styles.body}>
          <TouchableOpacity style={styles.button} onPress={this._login}>
            <Text style={styles.buttonText}>Login</Text>
          </TouchableOpacity>
        </View>
      );
    }
  }
}

const App: () => React$Node = () => {
  return (
    <React.Fragment>
      <StatusBar barStyle="dark-content" />
      <SafeAreaView>
        <TwitterTestView />
      </SafeAreaView>
    </React.Fragment>
  );
};

const styles = StyleSheet.create({
  scrollView: {
  },
  button: {
    backgroundColor: '#EEE',
    marginTop: 10,
  },
  buttonText: {
    color: 'black',
    padding: 30
  },
});

export default App;
