# Cozie Apple
> Cozie an iOS app app for human comfort data collection 

Cozie allows building occupants to provide feedback in real time

## Features

- [x] **Free and Easy to Use** - Building occupants can complete a right-here-right now survey directly from their Apple watch. Without the need of having to open an app on their Phone or a survey link.
- [x] **Open source** - Cozie is an Open Source project and together with [Cozie for Fitbit](https://cozie.app), allows researchers to focus on the data collection. We have taken care of all the programming for you!
- [x] **Powered by Apple ResearchKit** - Cozie iOS app uses [Apple's Research Kit](https://www.researchandcare.org/researchkit/). A software framework for Apple apps that let researchers gather robust and meaningful data.

## Documentation and tutorials

- [Documentation](https://www.cozie-apple.app/docs/)
- [Overview](https://www.youtube.com/watch?v=5e4FwVydYRE&t=109s)
- [Official website](https://www.cozie-apple.app/)

## Installation

I have created a [video tutorial](https://www.youtube.com/watch?v=gSNPvoGc8Zw) so you can see all the steps required to clone Cozie on your computer.

1. Clone the `cozie-app` repository on your computer, then `cd` into the repo. 

```git clone https://github.com/Cozie-IEQ/cozie-apple.git```

2. Install the CocoaPods with the following command `pod install`. You need to have CocoaPods installed on your Mac. You can install CocoaPods using the following command `sudo gem install cocoapods`. If you are using a new Mac with M1 chip you will need to use the following command to install CocoaPods `sudo arch -x86_64 gem install ffi` followed by `arch -x86_64 pod install`.
3. Open the `Cozie.xcworkspace` file with XCode.
4. Add Watch to iPhone simulaor `Window>Devices and Simulators>Create a new simulator`
5. Select Cozie as Target and press play button in XCode.
6. Select CozieWatchkitApp and press play button.
7. Prior completing a survey sync the watch and the phone.
8. If something is not working uninstall the app from both simulators and install it again.

For more information please visit the [official documentation website](https://cozie-apple.app/docs/)

## Contribute

We would love you for the contribution to our project, check the ``LICENSE`` file for more info.

## Authors

* [Federico Tartarini](https://github.com/FedericoTartarini) - Main developer
* [Clayton Miller](https://www.linkedin.com/in/claytonmiller/) - Supervisor
* [Stefano Schiavon](https://www.linkedin.com/in/stefanoschiavon/) - Supervisor

See ``LICENSE`` file for more information.
