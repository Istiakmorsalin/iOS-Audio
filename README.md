# iOS-Audio
Here You will find audio related RnD for iOS.

As prior to iOS 8, it was needed to dive into the depths of the low-level Core Audio framework,It was a cumbersome task to handle audio processing on that particular mobile platform. But, The relief is that all the difficult tasks were a lot easier when Apple released AVAudioEngine in 2014. 

Here, We’ll use AVAudioEngine to build the next great podcasting app: Istiakcast. :

The features We’ll implement in this app are:

1. Play a local audio file.
2. View the playback progress.
3. Observe the audio signal level with a VU meter.
4. Skip forward or backward.
5. Change the playback rate and pitch.

**Understanding iOS Audio Frameworks**

Before jumping into the project, here’s a quick overview of the iOS Audio frameworks:

- CoreAudio and AudioToolbox are the low-level C frameworks.
- AVFoundation is an Objective-C/Swift framework.
- AVAudioEngine is a part of AVFoundation.**

![Screenshot 2021-08-21 at 8 38 34 PM](https://user-images.githubusercontent.com/2936695/130325367-51fc0e81-19cf-4a82-9eb3-88191a65554e.png)


- AVAudioEngine is a class that defines a group of connected audio nodes. We’ll add two nodes to the project: AVAudioPlayerNode and AVAudioUnitTimePitch.

<img width="615" alt="Screenshot 2021-08-21 at 8 41 28 PM" src="https://user-images.githubusercontent.com/2936695/130325419-8f846b44-4ea9-4397-b450-5b52e8e37f84.png">


**Comparison:**

AVPlayer
+ Super simple
+ Gets things done
+ Does streaming and downloaded audio
– does not do more than 2x (not true as explained above)
– can’t do more advanced ideas we have in the future

AVAudioPlayer
+ Still simple
+ Still gets things done
+ Can do more than 2x
– Doesn’t do streaming well
* can do some of our advanced ideas


AVAudioEngine
+ Playing downloaded audio is super simple
+ Can do 32x speed
+ Can do all the advanced ideas we have: EQ, distortion and more
+ Apple endorsed as seen in WWDC 2017
– Playing streaming audio is a huuuge pain


CoreAudio
+ Can do all advanced ideas
– Painful to work with
– Apple’s deprecating parts of it

We decided that AVAudioEngine was the way to go but there were plenty of pitfalls. The implementation is done. Here is the screenshot of the implementation. 


https://user-images.githubusercontent.com/2936695/130327190-1b1b962e-86d4-4c56-97a2-b8be7af0d90e.mov



