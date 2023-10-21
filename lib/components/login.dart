import 'package:coffee_picker/components/coffee_input.dart';
import 'package:coffee_picker/components/scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth.dart';
import '../utils/forms.dart';

enum LoginAction {
  signup,
  login,
}

class Login extends ConsumerStatefulWidget {
  Login({super.key});

  String usernameError = '';
  String passwordError = '';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final _formKey = GlobalKey<FormState>();
  final usernameField = TextEditingController();
  final passwordField = TextEditingController();
  final signupButtonName = 'Signup';
  final loginButtonName = 'Login';
  LoginAction currentLoginAction = LoginAction.signup;

  @override
  void initState() {
    super.initState();
    initCurrentLoginAction();
  }

  @override
  Widget build(BuildContext context) {
    var inputForm = Padding(
        padding: const EdgeInsets.all(100),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildFormFieldText(
                  controller: usernameField,
                  hint: 'Email',
                  validationText: () => widget.usernameError,
                  emptyValidationText: 'Email is required.',
                  textInputType: TextInputType.emailAddress,
                  isInvalid: (_) => widget.usernameError.isNotEmpty),
              buildFormFieldText(
                  controller: passwordField,
                  hint: 'Password',
                  validationText: () => widget.passwordError,
                  emptyValidationText: 'Password is required.',
                  textInputType: TextInputType.visiblePassword,
                  obscureText: true,
                  isInvalid: (_) => widget.passwordError.isNotEmpty),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: handleLoginAction,
                  child: Text(mapLoginActionToName(currentLoginAction)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: TextButton(
                  onPressed: handleSwitchLoginAction,
                  child: Text(
                      "Switch to ${mapLoginActionToName(currentLoginAction, reversed: true)}"),
                ),
              ),
            ],
          ),
        ));
    return ScaffoldBuilder(body: inputForm);
  }

  void handleSwitchLoginAction() {
    setState(() {
      switchCurrentLoginAction();
      if (kDebugMode) {
        print({'Updated login state', currentLoginAction});
      }
    });
  }

  void handleLoginAction() {
    final emailAddress = usernameField.value.text;
    final password = passwordField.value.text;
    clearLoginErrors();

    switch (currentLoginAction) {
      case LoginAction.signup:
        signup(emailAddress, password)
            .then(handleSignupSuccess, onError: handleSignupError);
      case LoginAction.login:
        login(emailAddress, password)
            .then(handleLoginSuccess, onError: handleLoginError);
    }
  }

  void navigateToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CoffeeInput()),
    );
  }

  void handleSignupError(e) {
    if (e is FirebaseAuthException) {
      if (e.code == 'weak-password') {
        widget.passwordError = 'The password must be more than 6 characters.';
      } else if (e.code == 'email-already-in-use') {
        widget.usernameError = 'The account already exists for that email.';
      } else {
        widget.passwordError = 'Error signing up.';
      }
    } else {
      widget.passwordError = 'Error handling sign up.';
    }
    runFormValidation();
  }

  void handleLoginError(e) {
    if (e is FirebaseAuthException) {
      if (e.code == 'user-not-found') {
        widget.usernameError = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        widget.passwordError = 'Wrong password provided for that user.';
      } else {
        widget.passwordError = 'Error logging in.';
      }
    } else {
      widget.passwordError = 'Error handling log in.';
    }
    runFormValidation();
  }

  void handleSignupSuccess(value) {
    if (kDebugMode) {
      print({'Created user ', value});
    }
    clearLoginErrors();
    navigateToHome();
  }

  void handleLoginSuccess(value) {
    if (kDebugMode) {
      print({'User logged in ', value});
    }
    clearLoginErrors();
    navigateToHome();
  }

  void clearLoginErrors() {
    widget.usernameError = '';
    widget.passwordError = '';
    runFormValidation();
  }

  void runFormValidation() {
    _formKey.currentState?.validate();
  }

  initCurrentLoginAction() {
    currentLoginAction = LoginAction.signup;
  }

  switchCurrentLoginAction() {
    currentLoginAction = reverseLoginAction(currentLoginAction);
  }

  String mapLoginActionToName(LoginAction loginAction,
      {bool reversed = false}) {
    return switch (reversed ? reverseLoginAction(loginAction) : loginAction) {
      LoginAction.signup => signupButtonName,
      LoginAction.login => loginButtonName,
    };
  }

  LoginAction reverseLoginAction(LoginAction loginAction) {
    return switch (loginAction) {
      LoginAction.signup => LoginAction.login,
      LoginAction.login => LoginAction.signup,
    };
  }
}
