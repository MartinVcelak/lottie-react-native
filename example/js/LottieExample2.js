/* eslint-disable global-require */
import React from 'react';
import {
    View,
    StyleSheet,
    TouchableOpacity,

} from 'react-native';
import LottieView from 'lottie-react-native';


export default class LottieExample2 extends React.Component {
    state = {
        isPlaying: true,
    };

    render() {
        const { isPlaying } = this.state;

        return (
            <View style={{ flex: 1, flexDirection: "column" }}>
                {isPlaying && (<>
                    <LottieView
                        autoPlay={true}
                        style={[{ width: 200 }]}
                        source={require('./animations/HamburgerArrow.json')}
                        loop={true}
                        onAnimationStart={() => console.log("Animation started")}
                        onAnimationProgress={progress => console.log("Animation progress1: " + progress)}
                        enableMergePathsAndroidForKitKatAndAbove
                    />
                    <LottieView
                        autoPlay={true}
                        style={[{ width: 200 }]}
                        source={require('./animations/LineAnimation.json')}
                        loop={true}
                        onAnimationStart={() => console.log("Animation started")}
                        onAnimationProgress={progress => console.log("Animation progress2: " + progress)}
                        enableMergePathsAndroidForKitKatAndAbove
                    />
                </>)}
                <TouchableOpacity 
                    style={{backgroundColor:"red", width: 200, height: 200}} 
                    onPress={() => { this.setState({isPlaying: !isPlaying})}}
                />
            </View>

        )
    }
}
