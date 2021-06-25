import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../styleguide/textstyle.dart';
// import 'package:flutter_swipable/flutter_swipable.dart';
import '../Decorations/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';

ElevatedButton Heartbutton = ElevatedButton(
  onPressed: () => liked(),
  child: Icon(
    FontAwesomeIcons.heart,
    size: 30,
  ),
  style: ElevatedButton.styleFrom(
    onPrimary: Color(0xff44d083),
    primary: Colors.white,
    shape: CircleBorder(),
    padding: EdgeInsets.all(20),
  ),
);

ElevatedButton CrossButton = ElevatedButton(
  onPressed: () => passed(),
  child: Icon(
    FontAwesomeIcons.times,
    size: 30,
  ),
  style: ElevatedButton.styleFrom(
    onPrimary: Color(0xfffe3c72),
    primary: Colors.white,
    shape: CircleBorder(),
    padding: EdgeInsets.all(20),
  ),
);
final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final User user = firebaseAuth.currentUser;
final String uid = user.uid.toString();
CollectionReference collectionReference =
    FirebaseFirestore.instance.collection('User');

void liked() {
  //Add liked user to likes
  print('Liked');
  controller.triggerRight();
  CollectionReference swipeCollection =
      FirebaseFirestore.instance.collection('Swipes');
  Future<DocumentSnapshot> document = swipeCollection.doc(user.uid).get();
  document.then((doc) {
    if (doc.exists) {
      print("Exsts");
      // swipeCollection.doc(user.uid).set({'dee':'dedew', merge:true});
    } else {
      //Userid doesnt exits so create a doc
      print("Doesnt Exists");
      // swipeCollection.add(data)
    }
  });
  // collectionReference.doc(user.uid).set(data)
}

void passed() {
  print('Rejected');
  controller.triggerLeft();
}

CardController controller;

class swipePage extends StatefulWidget {
  // const homePage({ Key? key }) : super(key: key);

  @override
  _swipePageState createState() => _swipePageState();
}

List<dynamic> allData;

//   // Get data from docs and convert map to List
//   allData = querySnapshot.docs.map((doc) => doc['DownloadUrl']).toList();

Future<void> getData() async {
  // Get docs from collection reference
  QuerySnapshot querySnapshot = await collectionReference.get();

  // Get data from docs and convert map to List
  allData = querySnapshot.docs.map((doc) => doc.data()).toList();

  print(allData);
}

class _swipePageState extends State<swipePage> {
  // List<UserCard> welcomeImages = [
  //   //Images passed
  //   UserCard(Image.asset("assets/images/sample2.jpg")),
  //   UserCard(Image.asset("assets/images/image2.jpg"),
  //       userBio: 'lol', img2: Image.asset("assets/images/selena.jpg")),
  //   UserCard(Image.asset("assets/images/sample1.jpg"),
  //       img2: Image.asset("assets/images/image2.jpg"), userBio: 'hello'),
  //   UserCard(Image.asset("assets/images/selena.jpg"),
  //       userBio: 'asdfghjkl', img2: Image.asset("assets/images/sample3.jpg")),
  // ];

  @override
  Widget build(BuildContext context) {
    return myfuture();
  }

  List<UserCard> userCards(List<DocumentSnapshot> users) {
    List<UserCard> cards = [];
    for (DocumentSnapshot user in users) {
      // print(user['Age']);
      UserCard card = UserCard(
        Image.network(user['DownloadUrl']),
        age: user['Age'].toString(),
        education: user['Education'].toString(),
        gender: user['Gender'].toString(),
        work: user['Work'].toString(),
        aboutMe: user['About Me'].toString(),
        height: user['Height'].toString(),
      );
      // print(card.toString());
      cards.add(card);
    }
    return cards;
  }

  Widget myfuture() {
    return FutureBuilder(
        future: FirebaseFirestore.instance.collection('User').get(),
        // ignore: missing_return
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List users = snapshot.data.docs; //Stores list of users
            List<UserCard> cardList = userCards(users);
            if (snapshot.data != null) {
              return Container(
                padding: EdgeInsets.only(top: 10),
                height: MediaQuery.of(context).size.height * 1,
                child: new TinderSwapCard(
                  allowVerticalMovement: false,
                  swipeUp: false,
                  swipeDown: false,
                  orientation: AmassOrientation.TOP,
                  totalNum: cardList.length,
                  stackNum: 3,
                  swipeEdge: 4.0,
                  maxWidth: MediaQuery.of(context).size.width * 1,
                  maxHeight: MediaQuery.of(context).size.width * 2.2,
                  minWidth: MediaQuery.of(context).size.width * 0.8,
                  minHeight: MediaQuery.of(context).size.width * 0.8,
                  cardBuilder: (context, index) => cardList[index],
                  cardController: controller = CardController(),
                  swipeUpdateCallback:
                      (DragUpdateDetails details, Alignment align) {
                    /// Get swiping card's alignment
                    if (align.x < -10) {
                      //Logic for swiping executed here
                      //Card is LEFT swiping
                      passed();
                    } else if (align.x > 10) {
                      //Card is RIGHT swiping
                      liked();
                    }
                  },
                  swipeCompleteCallback:
                      (CardSwipeOrientation orientation, int index) {
                    /// Get orientation & index of swiped card!
                  },
                ),
              );
            }
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

class UserCard extends StatefulWidget {
  // List<Widget> items;
  Image img1;
  String age;
  String gender;
  String height;
  String education;
  String aboutMe;
  String work;

  UserCard(Image img1,
      {String age,
      String gender,
      String height,
      String education,
      String aboutMe,
      String work}) {
    this.img1 = img1;
    this.age = age;
    this.gender = gender;
    this.height = height;
    this.education = education;
    this.aboutMe = aboutMe;
    this.work = work;
  }

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  Container bottomProfile = Container(
      //Contains like and pass buttons
      child: Column(children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(padding: EdgeInsets.all(20.0), child: CrossButton),
        Padding(padding: EdgeInsets.all(20.0), child: Heartbutton)
      ],
    )
  ]));
  // List<Widget> userData() {
  //   List<Widget> userData = [
  //     Text(widget.age),
  //     widget.img1,
  //     Text(widget.gender),
  //     Text(widget.height),
  //     Text(widget.aboutMe),
  //     Text(widget.education),
  //     Text(widget.work),
  //     TextButton(onPressed: () => getData(), child: Text("Retrieve user data"))
  //   ];
  //   return userData;
  // }

  List<Widget> newData() {
    List<String> userText = [
      widget.age,
      widget.gender,
      widget.height,
      widget.aboutMe,
      widget.education,
      widget.work
    ];
    List<Widget> newList = [
      Container(
        child: widget.img1,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Color(0xffdee2ff),
            width: 10,
          ),
        ),
      )
    ];
    for (String text in userText) {
      if (text != 'null') {
        if (text == widget.aboutMe) {
          newList.add(Card(
            // shadowColor: Colors.pink[500],
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      0, 10, MediaQuery.of(context).size.width * 0.7, 0),
                  child: Text(
                    'Bio',
                    style: SwipingProfileHeaders,
                  ),
                ),
                Text(
                  text,
                  style: SwipingProfileText,
                ),
              ],
            ),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            margin: EdgeInsets.all(10),
          ));
          continue;
        }
        newList.add(Card(
          color: Color(0xffdee2ff),
          // shadowColor: Colors.pink[500],
          child: Text(
            text,
            style: SwipingProfileText,
          ),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          margin: EdgeInsets.all(10),
        ));
      }
    }
    newList.add(bottomProfile);
    return newList;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // child: Swipable(
      // Set the swipable widget
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        // padding: EdgeInsets.all(20),
        child: ListView(
          // child: Column(
          children: newData(),
        ),
      ),
    );
  }
}
