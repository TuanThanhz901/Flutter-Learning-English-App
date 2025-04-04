// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';

// void _showEditName(BuildContext context, String userName) {
//   TextEditingController _nameController = TextEditingController(text: userName);

//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Edit Name'),
//         content: Container(
//           height: 150,
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 5,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Name',
//                     style: TextStyle(fontSize: 20, fontFamily: 'Nunito'),
//                   ),
//                 ],
//               ),
//               TextField(
//                 controller: _nameController,
//                 decoration: InputDecoration(hintText: 'Enter new name'),
//               ),
//               SizedBox(
//                 height: 15,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             child: Text('Cancel'),
//             style: TextButton.styleFrom(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               foregroundColor: Colors.black,
//               backgroundColor: const Color.fromARGB(255, 205, 205, 205),
//             ),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             child: Text('Save'),
//             style: TextButton.styleFrom(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               foregroundColor: Colors.white,
//               backgroundColor: Colors.green,
//             ),
//             onPressed: () async {
//               final user = FirebaseAuth.instance.currentUser;
//               if (user != null) {
//                 DatabaseReference ref = FirebaseDatabase.instance.ref("users");
//                 final snapshot = await ref.get();
//                 if (snapshot.exists) {
//                   final data = snapshot.value as Map<dynamic, dynamic>;

//                   for (var key in data.keys) {
//                     var item = data[key];
//                     if (item != null && item is Map<dynamic, dynamic>) {
//                       if (item['email'] == user.email) {
//                         await ref
//                             .child(key)
//                             .update({'name': _nameController.text});
//                         setState(() {
//                           userName = _nameController.text;
//                         });
//                         break;
//                       }
//                     }
//                   }
//                 } else {
//                   print('No data available.');
//                 }
//               }
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
