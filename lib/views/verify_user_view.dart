import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utils/show_snackbar.dart';

class VerifyUserView extends StatefulWidget {
  const VerifyUserView({Key? key}) : super(key: key);

  @override
  State<VerifyUserView> createState() => _VerifyUserViewState();
}

class _VerifyUserViewState extends State<VerifyUserView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(19.0),
          child: Center(
            child: Column(
              children: [
                const Text('Please Verify your email address'),
                TextButton(
                  onPressed: () async {
                    await AuthService.firebase().sendEmailVerification();
                    if (mounted) {
                      showSnack(context,
                          'Verification Mail sent to your registered ID');
                    }
                  },
                  child: const Text('Send Email Verification'),
                ),
                TextButton(
                  onPressed: () async {
                    await AuthService.firebase().logOut();
                    if (mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (route) => false,
                      );
                    }
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
