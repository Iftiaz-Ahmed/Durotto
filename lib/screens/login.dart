import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:durotto/screens/app.dart';
import 'package:durotto/state_management/user_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[ 'email', 'profile' ]);
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  addUserToDB(data) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    users.doc(data['email']).set(data);
  }

  @override
  Widget build(BuildContext context) {
    UserBloc _userBloc = Provider.of<UserBloc>(context);
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.lightGreen,
        child: Stack(
          children: [
            Center(
              heightFactor: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 60,
                      child: Image.asset(
                        "assets/images/logo.png",
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                  ),

                  Container(
                    width: size.width/1.3,
                    child: ElevatedButton(
                      onPressed: () {
                        _googleSignIn.signIn().then((userData) {
                          setState(() {

                            var string = userData!.email.toString();
                            var username = string.split("@");

                            var data = {
                              "username": username[0].toString(),
                              "name": userData.displayName.toString(),
                              "email": userData.email.toString(),
                              "image": userData.photoUrl.toString(),
                            };

                            _userBloc.user = data;
                            _userBloc.isLogged = true;

                            addUserToDB(data);

                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                                CommonMain()), (Route<dynamic> route) => false);

                          });
                        }).catchError((e) {
                          print(e);
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.google,
                            color: Colors.white,
                          ),
                          Text(
                            'Continue with Google',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.red[600],
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20)
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'Durotto',
                    style: TextStyle(
                        fontSize: 30,
                        letterSpacing: 5,
                        color: Colors.black,
                        fontWeight: FontWeight.w900
                    ),
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}
