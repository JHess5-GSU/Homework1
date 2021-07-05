import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'src/authentication.dart';
import 'src/widgets.dart';

void main() {
  // Modify from here

  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: (context, _) => App(),
    ),
  );
  // to here.
}

class App extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Message Board',
      theme: ThemeData(
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
          highlightColor: Colors.grey,
        ),
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        accentColor: Colors.white,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      home: LoginPage(),

    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Message Board"),
        centerTitle: true,

      ),

      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.only(top:50),
          children: <Widget>[

             Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                  ),
                  onPressed: () {
                    showLogOutAlertDialog(context);
                  },
                  child: Text('Logout'),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[900],
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 8),
          // Add from here
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Authentication(
              email: appState.email,
              loginState: appState.loginState,
              startLoginFlow: appState.startLoginFlow,
              verifyEmail: appState.verifyEmail,
              signInWithEmailAndPassword: appState.signInWithEmailAndPassword,
              cancelRegistration: appState.cancelRegistration,
              registerAccount: appState.registerAccount,
              signOut: appState.signOut,
            ),
          ),
          // to here
          const Divider(
            height: 8,
            thickness: 2,
            indent: 8,
            endIndent: 8,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }
  Future<void> init() async {
    await Firebase.initializeApp();

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
        _mainChatSubscription = FirebaseFirestore.instance
            .collection('mainchat')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _mainChatMessages = [];
          snapshot.docs.forEach((document) {
            _mainChatMessages.add(
              MainChatMessage(
                date: document.data()['date'],
                name: document.data()['name'],
                message: document.data()['text'],
              ),
            );
          });
          notifyListeners();
        });

        _Chat2Subscription = FirebaseFirestore.instance
            .collection('Chat2')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _Chat2Messages = [];
          snapshot.docs.forEach((document) {
            _Chat2Messages.add(
              Chat2Message(
                date: document.data()['date'],
                name: document.data()['name'],
                message: document.data()['text'],
              ),
            );
          });
          notifyListeners();
        });

        _Chat3Subscription = FirebaseFirestore.instance
            .collection('Chat3')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _Chat3Messages = [];
          snapshot.docs.forEach((document) {
            _Chat3Messages.add(
              Chat3Message(
                date: document.data()['date'],
                name: document.data()['name'],
                message: document.data()['text'],
              ),
            );
          });
          notifyListeners();
        });

        _Chat4Subscription = FirebaseFirestore.instance
            .collection('Chat4')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _Chat4Messages = [];
          snapshot.docs.forEach((document) {
            _Chat4Messages.add(
              Chat4Message(
                date: document.data()['date'],
                name: document.data()['name'],
                message: document.data()['text'],
              ),
            );
          });
          notifyListeners();
        });

      } else {
        _loginState = ApplicationLoginState.loggedOut;
        _mainChatMessages = [];
        _mainChatSubscription?.cancel();
        _Chat2Messages = [];
        _Chat2Subscription?.cancel();
        _Chat3Messages = [];
        _Chat3Subscription?.cancel();
        _Chat4Messages = [];
        _Chat4Subscription?.cancel();
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;

  String? _email;
  String? get email => _email;

  StreamSubscription<QuerySnapshot>? _mainChatSubscription;
  StreamSubscription<QuerySnapshot>? _Chat2Subscription;
  StreamSubscription<QuerySnapshot>? _Chat3Subscription;
  StreamSubscription<QuerySnapshot>? _Chat4Subscription;

  List<MainChatMessage> _mainChatMessages = [];
  List<MainChatMessage> get mainChatMessages => _mainChatMessages.reversed.toList();

  List<Chat2Message> _Chat2Messages = [];
  List<Chat2Message> get Chat2Messages => _Chat2Messages.reversed.toList();

  List<Chat3Message> _Chat3Messages = [];
  List<Chat3Message> get Chat3Messages => _Chat3Messages.reversed.toList();

  List<Chat4Message> _Chat4Messages = [];
  List<Chat4Message> get Chat4Messages => _Chat4Messages.reversed.toList();

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> verifyEmail(
      String email,
      void Function(FirebaseAuthException e) errorCallback,
      ) async {
    try {
      var methods =
      await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
        _loginState = ApplicationLoginState.password;
      } else {
        _loginState = ApplicationLoginState.register;
      }
      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  Future<void> signInWithEmailAndPassword(
      String email,
      String password,
      void Function(FirebaseAuthException e) errorCallback,
      ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> registerAccount(
      String email,
      String displayName,
      //String firstName,
      //String lastName,
      String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateProfile(displayName: displayName);
      //await credential.user!.updateProfile(firstName: firstName);
      //await credential.user!.updateProfile(lastName: lastName);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }

    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({

      'userId':FirebaseAuth.instance.currentUser!.uid,
      'role':"customer",
      'registeredOn':DateTime.now(),
      'displayName': displayName,

    });

  }

  String dateToString(DateTime now){
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    final String formatted = formatter.format(now);
    return formatted;
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<DocumentReference> addMessageToMainChat(String message) {
    if (_loginState != ApplicationLoginState.loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance.collection('mainchat').add({
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'date': dateToString(DateTime.now())
    });
  }

  Future<DocumentReference> addMessageToChat2(String message) {
    if (_loginState != ApplicationLoginState.loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance.collection('Chat2').add({
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'date': dateToString(DateTime.now())
    });
  }

  Future<DocumentReference> addMessageToChat3(String message) {
    if (_loginState != ApplicationLoginState.loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance.collection('Chat3').add({
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'date': dateToString(DateTime.now())
    });
  }

  Future<DocumentReference> addMessageToChat4(String message) {
    if (_loginState != ApplicationLoginState.loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance.collection('Chat4').add({
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'date': dateToString(DateTime.now())
    });
  }

}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Message Board Home"),
        centerTitle: true,

      ),

      drawer: MyDrawer(),

      body: ListView(
        children: <Widget>[
          Material(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainChatHome()),
                  );
                },
                child: Container(
                  child: ClipRRect(
                    child: Image.asset('assets/college.png',
                    ),
                  ),
                ),
              ),
          ),
          Material(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Chat2Home()),
                  );
                },
                child: Container(
                  child: ClipRRect(
                    child: Image.asset('assets/life.png',
                        ),
                  ),
                ),
              ),
          ),
          Material(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Chat3Home()),
                  );
                },
                child: Container(
                  child: ClipRRect(
                    child: Image.asset('assets/future.png',
                    ),
                  ),
                ),
              ),
          ),
          Material(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Chat4Home()),
                  );
                },
                child: Container(
                  child: ClipRRect(
                    child: Image.asset('assets/technology.png',
                    ),
                  ),
                ),
              ),
          ),
    ],

    ),

    );
  }
}

class MainChatHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("College"),
        centerTitle: true,
        backgroundColor: Colors.red[900],


      ),

      drawer: MyDrawer(),

      body: ListView(
        reverse: true,
        children: <Widget>[
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appState.loginState == ApplicationLoginState.loggedIn) ...[
                  MainChat(
                    addMessage: (String message) =>
                        appState.addMessageToMainChat(message),
                    messages: appState.mainChatMessages,
                  ),
                ],
              ],
            ),
          ),

        ],

      ),

    );
  }
}

class Chat2Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Life"),
        centerTitle: true,
        backgroundColor: Colors.green[900],

      ),

      drawer: MyDrawer(),

      body: ListView(
        reverse: true,
        children: <Widget>[
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appState.loginState == ApplicationLoginState.loggedIn) ...[
                  Chat2(
                    addMessage: (String message) =>
                        appState.addMessageToChat2(message),
                    messages: appState.Chat2Messages,
                  ),
                ],
              ],
            ),
          ),

        ],

      ),

    );
  }
}

class Chat3Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Future"),
        centerTitle: true,
        backgroundColor: Colors.blue[900],

      ),

      drawer: MyDrawer(),

      body: ListView(
        reverse: true,
        children: <Widget>[
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appState.loginState == ApplicationLoginState.loggedIn) ...[
                  Chat3(
                    addMessage: (String message) =>
                        appState.addMessageToChat3(message),
                    messages: appState.Chat3Messages,
                  ),
                ],
              ],
            ),
          ),

        ],

      ),

    );
  }
}

class Chat4Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Technology"),
        centerTitle: true,
        backgroundColor: Colors.grey,

      ),

      drawer: MyDrawer(),

      body: ListView(
        reverse: true,
        children: <Widget>[
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appState.loginState == ApplicationLoginState.loggedIn) ...[
                  Chat4(
                    addMessage: (String message) =>
                        appState.addMessageToChat4(message),
                    messages: appState.Chat4Messages,
                  ),
                ],
              ],
            ),
          ),

        ],

      ),

    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.black,


      ),

      drawer: MyDrawer(),

      body: ListView(
        children: <Widget>[
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appState.loginState == ApplicationLoginState.loggedIn) ...[

                  Material(
                    child: InkWell(

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Chat4Home()),
                        );
                      },
                      child: Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset('assets/pfp.png',
                          ),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 20, top: 20),
                      child: Center(
                        child: TextField(
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                                hintText: "${FirebaseAuth.instance.currentUser!.displayName}",
                            ),
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          onSubmitted: (String value) {FirebaseAuth.instance.currentUser!.updateDisplayName(value); FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                            'displayName': value,
                          });;},
                        ),
                        ),
                      ),
                    ),

                  Divider(
                    height: 5,

                    indent: 20,
                    endIndent: 20,
                  ),

                  Center(child: Text("Tap Above to Change Profile Name", style: TextStyle(color: Colors.grey, fontSize: 15)),),

                  Divider(
                    height: 40,
                    thickness: 3,
                    indent: 20,
                    endIndent: 20,
                  ),

                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.0,right: 20.0),
                      child: Text(
                          "Email: ${FirebaseAuth.instance.currentUser!.email}",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white, fontSize: 20)
                      ),
                    ),
                  ),

                  Divider(
                    height: 40,
                    thickness: 3,
                    indent: 20,
                    endIndent: 20,
                  ),


                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.0,right: 20.0),
                      child: Text(
                          "Bio: Hi, I almost know what I'm doing.",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white, fontSize: 20)
                      ),
                    ),
                  ),

                  Divider(
                    height: 40,
                    thickness: 3,
                    indent: 20,
                    endIndent: 20,
                  ),

                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.0,right: 20.0),
                      child: Text(
                          "Instagram: jason.hess",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white, fontSize: 20)
                      ),
                    ),
                  ),

                  Divider(
                    height: 40,
                    thickness: 3,
                    indent: 20,
                    endIndent: 20,
                  ),

                  Container(
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.0,right: 20.0),
                      child: Text(
                          "More stuff will go here later, I promise.",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white, fontSize: 20)
                      ),
                    ),
                  ),

                  Divider(
                    height: 40,
                    thickness: 3,
                    indent: 20,
                    endIndent: 20,
                  ),

                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.0,right: 20.0),
                      child: Text(
                          "This is just to show that the profile page scrolls whenever it needs to. I quite like this class at the moment. I've learned a lot.",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white, fontSize: 20)
                      ),
                    ),
                  ),

                  Divider(
                    height: 40,
                    thickness: 3,
                    indent: 20,
                    endIndent: 20,
                  ),
                ],
              ],
            ),
          ),

        ],

      ),

    );
  }
}

showLogOutAlertDialog(BuildContext context) {

  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed:  () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = FlatButton(
    child: Text("Yes"),
    onPressed: () {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        LoginPage()), (Route<dynamic> route) => false);
  },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Confirm Logout"),

    backgroundColor: Colors.grey,
    content: Text("Are you sure you wish to log out?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          Material(
            child: InkWell(

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: Container(

                child: ClipRRect(

                  borderRadius: BorderRadius.circular(69),
                  child: Image.asset('assets/pfp.png',    // Eventually load users profile pic here instead
                  ),
                ),
              ),
            ),
          ),

          Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: Text('Profile'),
            ),
          ),
          ),

          Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
              child: Text('Settings'),
            ),
          ),
          ),

          Container(
            child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Text('Message Boards'),
            ),
          ),
          ),

          Container(
            child: ClipRRect(
    borderRadius: BorderRadius.circular(100),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
              ),
              onPressed: () {
                showLogOutAlertDialog(context);
              },
              child: Text('Logout'),
            ),
          ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),

      drawer: MyDrawer(),

      body: ListView(
        children: <Widget>[
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appState.loginState == ApplicationLoginState.loggedIn) ...[

                  Container(
                    child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                          "${FirebaseAuth.instance.currentUser!.displayName}",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 25)
                      ),
                    ),
                  ),
                  ),

                  Container(
                    width: 500,
                    child: Center(
                      child: SizedBox(

                        child: ElevatedButton(

                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                          ),
                          onPressed: () {
                            showLogOutAlertDialog(context);
                          },
                          child: Text('Change Display Name'),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: 500,
                    child: Center(
                    child: SizedBox(

                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                        ),
                        onPressed: () {
                          showLogOutAlertDialog(context);
                        },
                        child: Text('Logout'),
                      ),
                    ),
                  ),
                  ),

                  Container(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                            "UID: ${FirebaseAuth.instance.currentUser!.uid}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 18)
                        ),
                      ),
                    ),
                  ),

                ],
              ],

            ),
          ),

        ],

      ),

    );
  }
}

class MainChatMessage {
  MainChatMessage({required this.date, required this.name, required this.message});
  final String date;
  final String name;
  final String message;
}

class Chat2Message {
  Chat2Message({required this.date, required this.name, required this.message});
  final String date;
  final String name;
  final String message;
}

class Chat3Message {
  Chat3Message({required this.date, required this.name, required this.message});
  final String date;
  final String name;
  final String message;
}

class Chat4Message {
  Chat4Message({required this.date, required this.name, required this.message});
  final String date;
  final String name;
  final String message;
}

class MainChat extends StatefulWidget {
  MainChat({required this.addMessage, required this.messages});
  final FutureOr<void> Function(String message) addMessage;
  final List<MainChatMessage> messages;

  @override
  _MainChatState createState() => _MainChatState();
}

class Chat2 extends StatefulWidget {
  Chat2({required this.addMessage, required this.messages});
  final FutureOr<void> Function(String message) addMessage;
  final List<Chat2Message> messages;

  @override
  _Chat2State createState() => _Chat2State();
}

class Chat3 extends StatefulWidget {
  Chat3({required this.addMessage, required this.messages});
  final FutureOr<void> Function(String message) addMessage;
  final List<Chat3Message> messages;

  @override
  _Chat3State createState() => _Chat3State();
}

class Chat4 extends StatefulWidget {
  Chat4({required this.addMessage, required this.messages});
  final FutureOr<void> Function(String message) addMessage;
  final List<Chat4Message> messages;

  @override
  _Chat4State createState() => _Chat4State();
}

class _MainChatState extends State<MainChat> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_MainChatState');
  final _controller = TextEditingController();

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          for (var message in widget.messages)
            Paragraph('On ${message.date}, ${message.name} said:\n${message.message}'),
          SizedBox(height: 15),

      Padding(

        padding: const EdgeInsets.all(8.0),

        child: Form(
          key: _formKey,
          child: Row(
            children: [

              Expanded(

                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter a message',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your message to continue';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 8),
              StyledButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await widget.addMessage(_controller.text);
                    _controller.clear();
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.send),
                    SizedBox(width: 4),
                    Text('SEND'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

          SizedBox(height: 10),
        ],
    );
  }
}

class _Chat2State extends State<Chat2> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_Chat2State');
  final _controller = TextEditingController();

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        for (var message in widget.messages)
          Paragraph('On ${message.date}, ${message.name} said:\n${message.message}'),
        SizedBox(height: 15),

        Padding(

          padding: const EdgeInsets.all(8.0),

          child: Form(
            key: _formKey,
            child: Row(
              children: [

                Expanded(

                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your message to continue';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 8),
                StyledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await widget.addMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.send),
                      SizedBox(width: 4),
                      Text('SEND'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 10),
      ],
    );
  }
}



class _Chat3State extends State<Chat3> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_Chat3State');
  final _controller = TextEditingController();

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        for (var message in widget.messages)
          Paragraph('On ${message.date}, ${message.name} said:\n${message.message}'),
        SizedBox(height: 15),

        Padding(

          padding: const EdgeInsets.all(8.0),

          child: Form(
            key: _formKey,
            child: Row(
              children: [

                Expanded(

                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your message to continue';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 8),
                StyledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await widget.addMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.send),
                      SizedBox(width: 4),
                      Text('SEND'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 10),
      ],
    );
  }
}

class _Chat4State extends State<Chat4> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_Chat4State');
  final _controller = TextEditingController();

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        for (var message in widget.messages)
          Paragraph('On ${message.date}, ${message.name} said:\n${message.message}'),
        SizedBox(height: 15),

        Padding(

          padding: const EdgeInsets.all(8.0),

          child: Form(
            key: _formKey,
            child: Row(
              children: [

                Expanded(

                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your message to continue';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 8),
                StyledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await widget.addMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.send),
                      SizedBox(width: 4),
                      Text('SEND'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 10),
      ],
    );
  }
}