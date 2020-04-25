
# react-native-tweet-composer

## Getting started

`$ npm install react-native-tweet-composer --save`

## Run the example
```
cd example

# packs and installs the library
npm run prepare 

# Install all dependencies
npm install

# Run Packager
react-native start
```

### Mostly automatic installation

`$ react-native link react-native-tweet-composer`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-tweet-composer` and add `RNReactNativeTwitterComposer.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNReactNativeTwitterComposer.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.yoshijaeger.RNReactNativeTwitterComposerPackage;` to the imports at the top of the file
  - Add `new RNReactNativeTwitterComposerPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-tweet-composer'
  	project(':react-native-tweet-composer').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-tweet-composer/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-tweet-composer')
  	```


## Usage
```javascript
import RNReactNativeTwitterComposer from 'react-native-tweet-composer';

// TODO: What to do with the module?
RNReactNativeTwitterComposer;
```
  