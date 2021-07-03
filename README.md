# Group Assignment 1    -    Jason Hess

Hi there. This is my group assignment submission. I actually did not have a group and preferred to do this alone.

As a result, it may not be as polished as groups that have 5x the brainpower and time available than I do, but I am fairly happy with the result I have.

It is certainly not perfect, and the list below will help explain the various things that are and are not working in the app.

Things that are working: 

    -   Splash Screen                   -   Picture of me, albeit a few years ago. :)
    
    -   Firebase API usage              -   Described below.
    
    -   User Registration / Login       -   Instead of two separate pages, there is a common email field. If input email does not already exist in Firebase Auth, the registration process is started.
    
    -   Login with Email and Password   -   I was able to successfully set up Firebase and use Cloud Firestore and Firebase Authentication to enable email-based logins.
    
    -   Cloud Firestore                 -   Stores userId, registeredOn (date), role, and displayName upon registration.
    
    -   Firebase Authentication         -   Email and Password are working. Did not have enough time to add social media, but Twitter and Google login is technically enabled and ready to setup.
    
    -   Message Boards                  -   Four message boards are present. Each has their own chat, and messages now show date and time when sent. Image assets are hardcoded.
                                        -   I color coded the AppBar at the top to match each message board! It looks nice, in my opinion.
    
    -   Navigation Bar                  -   Drawer at the top left includes a profile picture, and buttons for profile, settings, message boards, and signing out.
                                            
    -   Profile Picture                 -   Profile picture is currently hardcoded, but could soon use firestore for custom, updatable pictures. Tappable to go to profile page.
    
    -   Profile button/home             -   Takes you to the profile page, which has the profile pic, display name, and other info.
    
    -   Settings button                 -   Takes you to the settings page, which has a log out
    
    -   Sign Out                        -   It will sign you out and take you back to the login screen.
    
    -   Web and Android Platforms       -   I did not configure it for iOS as I do not have a setup yet for MacOS.
    
Things that are NOT working:

    -   Edit Display Name               -   Display name is shown, but currently not editable. Plan was to make it a text field that could be saved and then gets uploaded to user doc.
    
    -   Social Media Profiles           -   No way to link profiles yet. Space on the profile page to add links.
    
A screen recording is included. 

Thanks,
Jason Hess

# P.S. The images were all handcrafted by me, in MS Paint. :)

To run it, you can extract to any directory and then open it in Android Studio. Or, you can use the screen recording, which shows the entire app in a little over a minute and is pausable.

Things I plan to work on in the future:

    -   Cleaner UI                      -   UI is not very pretty, but I am not a graphic artist nor UI expert. I could certainly improve that in the future.
    
    -   Cleaner code                    -   Code is a little bit of a spaghetti mess, I could separate things into separate files/classes a little bit better in the future.
    
    -   Prettier messages               -   Messages right now are very basic Paragraph/Text objects in a list. Could improve these with profile pictures, bubbles, etc.