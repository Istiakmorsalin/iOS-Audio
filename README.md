# iOS-Audio
Here You will find audio related RnD for iOS.

As prior to iOS 8, it was needed to dive into the depths of the low-level Core Audio framework,It was a cumbersome task to handle audio processing on that particular mobile platform. But, The relief is that all the difficult tasks were a lot easier when Apple released AVAudioEngine in 2014. 

Here, you’ll use AVAudioEngine to build the next great podcasting app: Istiakcast. :

The features you’ll implement in this app are:

Play a local audio file.
View the playback progress.
Observe the audio signal level with a VU meter.
Skip forward or backward.
Change the playback rate and pitch.

Understanding iOS Audio Frameworks

Before jumping into the project, here’s a quick overview of the iOS Audio frameworks:

CoreAudio and AudioToolbox are the low-level C frameworks.
AVFoundation is an Objective-C/Swift framework.
AVAudioEngine is a part of AVFoundation.

![Screenshot 2021-08-21 at 8 38 34 PM](https://user-images.githubusercontent.com/2936695/130325367-51fc0e81-19cf-4a82-9eb3-88191a65554e.png)


AVAudioEngine is a class that defines a group of connected audio nodes. You’ll add two nodes to the project: AVAudioPlayerNode and AVAudioUnitTimePitch.

<img width="615" alt="Screenshot 2021-08-21 at 8 41 28 PM" src="https://user-images.githubusercontent.com/2936695/130325419-8f846b44-4ea9-4397-b450-5b52e8e37f84.png">



Comparison:

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

We decided that AVAudioEngine was the way to go but there were plenty of pitfalls. If you’re a developer here are some things to watch out for:
Bad documentation. You’ll have to scour the smallest corners of the web to find information
Bugs that only a few people have experienced. StackOverflow won’t help you here. This year there were only 82 total questions for AVAudioEngine
You should learn how audio is digitized and stored. Compressed, Uncompressed, VBR, CBR, etc.
If you want streaming to work you’ll have to be familiar with URLSession
Concurrency was a pain. Get familiar with GCD and log statements
Even though you’re working in Swift you’ll still need to do manual memory allocation. Pair this with concurrency problems and debugging gets disheartening.



AvAudioEngine implementation is done. Here is the screenshot of the implementation. 

![Simulator Screen Shot - iPhone 12 Pro Max - 2021-08-21 at 20 33 21](https://user-images.githubusercontent.com/2936695/130325144-a9f910ef-07c9-43e0-ab62-e0d5722af51a.png)

