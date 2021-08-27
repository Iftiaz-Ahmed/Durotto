import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:durotto/screens/history.dart';
import 'package:durotto/screens/home.dart';
import 'package:durotto/services/notification_api.dart';
import 'package:durotto/state_management/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'login.dart';

class CommonMain extends StatefulWidget {
  const CommonMain({Key? key}) : super(key: key);

  @override
  _CommonMainState createState() => _CommonMainState();
}

class _CommonMainState extends State<CommonMain> {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  var _showPage;

  Widget _pageChooser(int page) {
    switch (page) {
      case 0:
        return HomePage();
        break;
      case 1:
        return LocationHistory();
        break;
      default:
        return new Container(
          child: new Center(
            child: new Text(
              'No page found',
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 30.0
              ),
            ),
          ),
        );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    NotificationApi.init();
    listenNotifications();

    _showPage = HomePage();
  }

  void listenNotifications() =>
      NotificationApi.onNotifications.stream.listen(onClickedNotification);

  void onClickedNotification(String? payload) =>
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => HomePage())
      );

  @override
  Widget build(BuildContext context) {
    UserBloc _userBloc = Provider.of<UserBloc>(context);

    return FocusWatcher(
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                    _userBloc.user['image']!=null?_userBloc.user['image']:"http://via.placeholder.com/350x150",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            'Durotto',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25,
                letterSpacing: 5
            ),
          ),
          actions: [
            InkWell(
              onTap: () {
                _googleSignIn.signOut().then((value) {
                  _userBloc.isLogged = false;
                }).catchError((e) {
                  print(e);
                });
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                    LoginPage()), (Route<dynamic> route) => false);
                _userBloc.user.clear();
                _userBloc.distance = 0.0;
                _userBloc.start = "";
                _userBloc.destination = "";
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0, top: 5),
                child: Column(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.signOutAlt,
                      size: 20,
                    ),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        body: _showPage,
        bottomNavigationBar: ConvexAppBar.badge(
          {},
          badgeMargin: EdgeInsets.only(left: 35, bottom: 20),
          badgePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          badgeBorderRadius: 30,
          style: TabStyle.reactCircle,
          backgroundColor: Colors.lightGreen,
          color: Colors.white,
          items: [
            TabItem(
              icon: Icons.home,
              title: "Home"
            ),
            TabItem(
                icon: Icons.location_history_outlined,
              title: "History"
            ),
          ],
          initialActiveIndex: 0,//optional, default as 0
          onTap: (int index) {
            print(index);
            setState(() {
              _showPage = _pageChooser(index);
            });
          },
        ),
      ),
    );
  }
}
