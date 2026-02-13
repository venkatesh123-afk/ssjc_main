// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:ssjc_p/utils/get_storage.dart';

// // class SplashPage extends StatefulWidget {
// //   const SplashPage({super.key});

// //   @override
// //   State<SplashPage> createState() => _SplashPageState();
// // }

// // class _SplashPageState extends State<SplashPage> {
// //   @override
// //   void initState() {
// //     super.initState();

// //     WidgetsBinding.instance.addPostFrameCallback((_) async {
// //       await Future.delayed(const Duration(seconds: 2));

// //       // ✅ CHECK LOGIN STATE
// //       if (AppStorage.isLoggedIn()) {
// //         Get.offAllNamed('/dashboard'); // reopen → home
// //       } else {
// //         Get.offAllNamed('/login'); // logged out → login
// //       }
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: SizedBox.expand(
// //         child: Image.asset(
// //           'assets/saraswati1.jpg',
// //           fit: BoxFit.cover,
// //           errorBuilder: (_, __, ___) =>
// //               const Center(child: CircularProgressIndicator()),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:student_app/staff_app/utils/get_storage.dart';

// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   @override
//   void initState() {
//     super.initState();

//     Future.delayed(const Duration(seconds: 2), () {
//       // ✅ CHECK LOGIN STATE
//       if (AppStorage.isLoggedIn()) {
//         Get.offAllNamed('/dashboard'); // logged in
//       } else {
//         Get.offAllNamed('/login'); // logged out
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SizedBox.expand(
//         child: Image.asset(
//           'assets/saraswati1.jpg',
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) =>
//               const Center(child: CircularProgressIndicator()),
//         ),
//       ),
//     );
//   }
// }
