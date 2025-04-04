import 'package:final_project/colors.dart';
import 'package:final_project/database/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Ranking extends StatefulWidget {
  @override
  _RankingState createState() => _RankingState();
}

class _RankingState extends State<Ranking> {
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
    fetchUserRankings();
  }

  Future<void> fetchUserRankings() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      List<UserModel> loadedUsers = [];
      for (var item in data.values) {
        if (item != null && item is Map<dynamic, dynamic>) {
          var userModel = UserModel.fromMap(item);
          loadedUsers.add(userModel);
        }
      }

      // Calculate total points for each user
      for (var user in loadedUsers) {
        user.listPoint =
            user.listPoint.where((point) => point != null).toList();
      }

      loadedUsers.sort((a, b) {
        int totalPointsA = a.listPoint.fold(0, (sum, item) => sum + item.point);
        int totalPointsB = b.listPoint.fold(0, (sum, item) => sum + item.point);
        return totalPointsB.compareTo(totalPointsA);
      });

      setState(() {
        users = loadedUsers;
      });
    } else {
      print('No data available.');
    }
  }

  Future<String?> fetchUserImage(String email) async {
    try {
      var ref = FirebaseStorage.instance.ref().child("/$email.jpg");
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error fetching image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        SizedBox(
          height: 15,
        ),
        Container(
            width: 120,
            height: 120,
            child: Image.asset('assets/images/rankPage.png')),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: users.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final totalPoints = user.listPoint
                          .fold(0, (sum, item) => sum + item.point);
                      return FutureBuilder<String?>(
                        future: fetchUserImage(user.email),
                        builder: (context, snapshot) {
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ListTile(
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${index + 1}',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  SizedBox(width: 20),
                                  snapshot.connectionState ==
                                              ConnectionState.done &&
                                          snapshot.hasData
                                      ? CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(snapshot.data!),
                                          radius: 25, // Adjusted size
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          child: Icon(Icons.person, size: 25),
                                          radius: 25, // Adjusted size
                                        ),
                                ],
                              ),
                              title: Text(
                                '${user.name}',
                                style: TextStyle(fontSize: 20),
                              ),
                              trailing: Text(
                                '${totalPoints}',
                                style: TextStyle(
                                    fontSize: 25,
                                    color: const Color.fromARGB(
                                        255, 116, 116, 117)),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ],
    ));
  }
}
