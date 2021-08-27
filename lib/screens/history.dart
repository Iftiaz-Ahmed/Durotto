import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:durotto/state_management/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LocationHistory extends StatefulWidget {
  const LocationHistory({Key? key}) : super(key: key);

  @override
  _LocationHistoryState createState() => _LocationHistoryState();
}

class _LocationHistoryState extends State<LocationHistory> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    UserBloc _userBloc = Provider.of<UserBloc>(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.grey[200],
      child: StreamBuilder(
        stream: firestore.collection("users").doc(_userBloc.user['email']).collection("records").orderBy('createdAt', descending: true).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(!snapshot.hasData) return const Center(child: CircularProgressIndicator(),);

          return snapshot.data.docs.length==0?
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: new AssetImage(
                  "assets/images/sad.gif",
                ),
                alignment: Alignment.center,
                width: 50,
                height: 50,
              ),

              Text(
                'No records found!',
                style: TextStyle(
                    fontSize: 18
                ),
              )
            ],
          ):Container(
            height: MediaQuery.of(context).size.height,
            child: ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
                var timeStamp = snapshot.data.docs[index]['createdAt'];
                DateTime dt = timeStamp.toDate();
                var date = DateFormat.yMMMMd().format(dt);
                var time = DateFormat.jm().format(dt);

                return Container(
                  margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.white
                  ),
                  child: ListTile(
                    isThreeLine: true,
                    leading: Image.asset(
                        "assets/images/logo.png",
                        width: 50,
                        height: 50,
                    ),
                    horizontalTitleGap: 10,
                    trailing: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              content: TextButton(
                                onPressed: () {
                                  CollectionReference users = FirebaseFirestore.instance.collection('users').doc(_userBloc.user['email']).collection("records");
                                  users
                                      .where("createdAt", isEqualTo: snapshot.data.docs[index]['createdAt'])
                                      .where("end", isEqualTo: snapshot.data.docs[index]['end'])
                                      .get()
                                      .then((querySnapshot) {
                                    querySnapshot.docs.forEach((document) {
                                      document.reference.delete();
                                    });
                                  });

                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Delete Record',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },

                        );
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.trashAlt,
                      ),
                    ),
                    title: AutoSizeText(
                      "Distance: " + snapshot.data.docs[index]['distance'].toString() + " km",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: 1
                      ),
                      maxFontSize: 18,
                      minFontSize: 12,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10,),
                        AutoSizeText(
                          "Start: " + snapshot.data.docs[index]['start'],
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 1
                          ),
                          maxFontSize: 14,
                          minFontSize: 12,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5,),
                        AutoSizeText(
                          "End: " + snapshot.data.docs[index]['end'],
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 1
                          ),
                          maxFontSize: 14,
                          minFontSize: 12,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 10,),
                        AutoSizeText(
                          date + "  " + time,
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1
                          ),
                          maxFontSize: 12,
                          minFontSize: 12,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
