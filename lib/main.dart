import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
        title: const Text('Message Board'),
        backgroundColor: Colors.black,
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

      drawer: Drawer(
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
                    child: Image.asset('assets/pfp.png',
                    ),
                  ),
                ),
              ),
            ),


            Container(
              child: ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Go Back'),
              ),
            ),

            Container(
              child: ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Logout'),
              ),
            ),

          ],
        ),
      ),

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

      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red[900],
              ),
              child: Text('MENU'),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),

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

      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green[900],
              ),
              child: Text('MENU'),
            ),
            Container(
              child: ElevatedButton(

                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),

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

      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[900],
              ),
              child: Text('MENU'),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),

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

      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
              child: Text('MENU'),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),

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
        backgroundColor: Colors.red[900],


      ),

      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red[900],
              ),
              child: Text('MENU'),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),

      body: ListView(
        children: <Widget>[
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appState.loginState == ApplicationLoginState.loggedIn) ...[
                  
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
  MainChatMessage({required this.name, required this.message});
  final String name;
  final String message;
}

class Chat2Message {
  Chat2Message({required this.name, required this.message});
  final String name;
  final String message;
}

class Chat3Message {
  Chat3Message({required this.name, required this.message});
  final String name;
  final String message;
}

class Chat4Message {
  Chat4Message({required this.name, required this.message});
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
            Paragraph('${message.name}: ${message.message}'),
          SizedBox(height: 8),

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
          Paragraph('${message.name}: ${message.message}'),
        SizedBox(height: 8),

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
          Paragraph('${message.name}: ${message.message}'),
        SizedBox(height: 8),

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
          Paragraph('${message.name}: ${message.message}'),
        SizedBox(height: 8),

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