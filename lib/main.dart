import 'package:durotto/screens/app.dart';
import 'package:durotto/screens/home.dart';
import 'package:durotto/screens/login.dart';
import 'package:durotto/state_management/user_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider<UserBloc>.value(value: UserBloc()),
          ],
          child: MyApp()
      )
  );
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    UserBloc _userBloc = Provider.of<UserBloc>(context);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Neue',
        primarySwatch: Colors.lightGreen,
      ),
      home: _userBloc.isLogged? CommonMain():LoginPage(),
    );
  }
}