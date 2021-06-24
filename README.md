# Homework 1    -    Jason Hess

My first ever attempt to design an app. It works on Android and Web platforms.

To run, just download the zip, extract into a directory, and run the build.gradle file with Android Studio (either by right clicking in Explorer or by going to File > New > Import Project)

Going to be honest, I had absolutely no prior Dart or mobile app experience. This homework assignment was challenging for me due to the steep learning curve involved.

As a result, the assignment was not fully completed. That being said, I have already learned a considerable amount.

# To Run The Project

Assuming you already have a Flutter setup, please just extract the zip into the directory that contains your existing flutter apps. Everything you need is included in the repo, but your Flutter SDK location could be set to anywhere.

Included for ease of grading is a screen recording. I believe it shows everything you need, especially as you can pause it whenever necessary.

Things that are working: 

    -   Splash Screen
    
    -   Firebase API usage              -   Described below.
    
    -   User Registration / Login       -   Instead of two separate pages, there is a common email field. If input email does not already exist in Firebase Auth, the registration process is started.
    
    -   Login with Email and Password   -   I was able to successfully set up Firebase and use Cloud Firestore and Firebase Authentication to enable email-based logins.
    
    -   Cloud Firestore                 -   Does not yet store the registration datetime.
    
    -   Firebase Authentication         -   Email and Password are working. Did not have enough time to add social media, but Twitter and Google login is technically enabled and ready to setup.
    
    -   Global Messages                 -   Currently, all messages show to everyone.
    
    -   Send Messages                   -   Since I did not have time to set up User Roles, everyone that logs in can currently send messages in the chat.
    
    -   Sign Out                        -   Added a Drawer with a Log Out button. It will take you back to the login screen.
    
    -   Web and Android Platforms       -   I did not configure it for iOS as I do not have a setup yet for MacOS.
   
    
    
Things that are NOT working:

    -   Login with Social Media         -   Did not have time. Twitter API key and secret are generated. Google SHA-1 generated and input into Firebase console.
    
    -   User Roles                      -   Did not have a chance to set up.
    
    -   Log Out Alert Dialog            -   Did not have a chance to implement. 
    
    
A screen recording is included.

Thanks,
Jason Hess