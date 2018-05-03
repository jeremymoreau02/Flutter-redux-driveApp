import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

import 'package:flutter_redux_boilerplate/models/user.dart';
import 'package:flutter_redux_boilerplate/models/app_state.dart';

class UserLoginRequest {}

class UserLoginSuccess {
    final User user;

    UserLoginSuccess(this.user);
}

class UserLoginFailure {
    final String error;

    UserLoginFailure(this.error);
}

class UserLogout {}

class UserLogin {
    final String username;
    final String password;
    final BuildContext context;

    UserLogin(this.context, this.username, this.password);
}

class UserWillLogout {
  final BuildContext context;

  UserWillLogout(this.context);
}