import 'package:chat_app/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  const ChatScreen({Key? key}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _fireStore =
      FirebaseFirestore.instance; //instance to store data in firestore
  dynamic loggedInUser;
  late String messageText;
  final TextEditingController controller = TextEditingController();
  late Stream<QuerySnapshot> stream;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getData();
  }

  void getCurrentUser() async {
    final user = await _auth.currentUser;
    try {
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  getData() async {
    // function to fetch data from firebase firestore
    setState(() {});
    stream = await _fireStore
        .collection('messages')
        .orderBy('ts', descending: true)
        .snapshots();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                // stream builder is used for continuous data stream
                //Widget that builds itself based on the latest snapshot
                stream: stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  {
                    return ListView.builder(
                        reverse: true,
                        shrinkWrap: true,
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot ds = snapshot.data!.docs[index];
                          // print(ds['text']);
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  ds['sender'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Material(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15)),
                                  color: Colors.lightBlueAccent,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Text(
                                      ds['text'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  }
                }),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      onChanged: (value) {
                        messageText = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      controller.clear();
                      //Implement send functionality.
                      await _fireStore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                        'ts': DateTime.now(),
                      });
                      await getData();
                      setState(() {});
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//
// return Padding(
// padding: const EdgeInsets.only(
// left: 10, right: 10, top: 10),
// child: Row(
// children: [
// Expanded(
// child: Text(
// ds['sender'],
// style: TextStyle(
// fontSize: 12,
// color: Colors.black54,
// ),
// ),
// ),
// SizedBox(
// height: 5,
// ),
// Material(
// borderRadius: BorderRadius.only(
// topLeft: Radius.circular(15),
// bottomLeft: Radius.circular(15),
// bottomRight: Radius.circular(15)),
// color: Colors.lightBlueAccent,
// child: Padding(
// padding: const EdgeInsets.symmetric(
// vertical: 10, horizontal: 20),
// child: Text(
// ds['text'],
// style: TextStyle(
// color: Colors.white,
// fontSize: 17,
// ),
// ),
// ),
// ),
// ],
// ),
// );
