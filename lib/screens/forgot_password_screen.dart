// // ignore_for_file: use_build_context_synchronously

// import 'package:flutter/material.dart';
// import '../database/db_helper.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   bool emailVerified = false;

//   // STEP 1: Verify Email
//   void verifyEmail() async {
//     final user = await DBHelper().getUserByEmail(emailController.text);

//     if (user != null) {
//       setState(() {
//         emailVerified = true;
//       });
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Email not found")));
//     }
//   }

//   // STEP 2: Reset Password
//   void resetPassword() async {
//     await DBHelper().updatePassword(
//       emailController.text,
//       passwordController.text,
//     );

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Password reset successfully")),
//     );

//     Navigator.pop(context); // go back to login
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Forgot Password")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: "Email"),
//             ),

//             if (emailVerified)
//               TextField(
//                 controller: passwordController,
//                 decoration: const InputDecoration(labelText: "New Password"),
//                 obscureText: true,
//               ),

//             const SizedBox(height: 20),

//             ElevatedButton(
//               onPressed: emailVerified ? resetPassword : verifyEmail,
//               child: Text(emailVerified ? "Reset Password" : "Verify Email"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool emailVerified = false;

  // STEP 1: Verify Email
  void verifyEmail() async {
    final user = await DBHelper().getUserByEmail(emailController.text);

    if (user != null) {
      setState(() {
        emailVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email verified! Enter new password")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Email not found")));
    }
  }

  // STEP 2: Reset Password
  void resetPassword() async {
    if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a new password")),
      );
      return;
    }

    await DBHelper().updatePassword(
      emailController.text,
      passwordController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password reset successfully")),
    );

    Navigator.pop(context); // go back to login
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text("Forgot Password")),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Forgot Password",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter your email to reset password",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Email Field
                  CustomTextField(
                    hintText: "Email",
                    controller: emailController,
                  ),
                  const SizedBox(height: 20),

                  // New Password Field (only if email verified)
                  if (emailVerified) ...[
                    CustomTextField(
                      hintText: "New Password",
                      controller: passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),
                  ],

                  CustomButton(
                    text: emailVerified ? "Reset Password" : "Verify Email",
                    onPressed: emailVerified ? resetPassword : verifyEmail,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
