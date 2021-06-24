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
      title: 'Homework 1',
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
        title: const Text('Homework 1'),
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

      } else {
        _loginState = ApplicationLoginState.loggedOut;
        _mainChatMessages = [];
        _mainChatSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;

  String? _email;
  String? get email => _email;

  StreamSubscription<QuerySnapshot>? _mainChatSubscription;
  List<MainChatMessage> _mainChatMessages = [];
  List<MainChatMessage> get mainChatMessages => _mainChatMessages.reversed.toList();


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
     // String firstName,
     // String lastName,
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
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Home Page"),
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

class MainChatMessage {
  MainChatMessage({required this.name, required this.message});
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

class _MainChatState extends State<MainChat> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_MainChatState');
  final _controller = TextEditingController();

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
