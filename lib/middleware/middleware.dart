

import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'package:redux/redux.dart';
import 'package:crypto/crypto.dart' as CryptoUtils;

import 'package:flutter_redux_boilerplate/models/app_state.dart';
import 'package:flutter_redux_boilerplate/actions/auth_actions.dart';
import 'package:flutter_redux_boilerplate/models/user.dart';

final persistor = new Persistor<AppState>(storage: new FlutterStorage('redux-app'), decoder: AppState.rehydrationJSON);

List<Middleware<AppState>> createStoreTodosMiddleware(){
  final login = _login();
  final logout = _logout();

  return [
    TypedMiddleware<AppState, UserLogin>(login),
    TypedMiddleware<AppState, UserWillLogout>(logout)
  ];
}

// Set up middlewares
List<Middleware<AppState>> createMiddleware() => <Middleware<AppState>>[
    thunkMiddleware,
    persistor.createMiddleware(),
    new LoggingMiddleware.printer()
]..addAll(createStoreTodosMiddleware());



Middleware<AppState> _login() {
    return (Store store, action, NextDispatcher next) async {
        if(action is UserLogin){
          store.dispatch(new UserLoginRequest());
          var body = {
            'grant_type': 'password',
            'username': action.username,
            'password': action.password
          };



          var res = await postData("/oauth/token", null, body);
          print('${res}');
          if (res["access_token"] != null ) {
            store.dispatch(new UserLoginSuccess(new User(res["access_token"], 'placeholder_id')));
            Navigator.of(action.context).pushNamedAndRemoveUntil('/main', (_) => false);
          } else {
            store.dispatch(new UserLoginFailure('Username or password were incorrect.'));
          }
        }

        next(action);
    };
}

Middleware<AppState> _logout() {
  return (Store store, action, NextDispatcher next) async {
    if(action is UserWillLogout){
      store.dispatch(new UserLogout());
      Navigator.of(action.context).pushNamedAndRemoveUntil('/login', (_) => false);
    }

    next(action);
  };
}

postData(String url, Map<String, String> body, Map<String, String> params) async {
  var uri;
  if(params != null){
    uri = new Uri.http('192.168.1.41:8080', url, params);
  }else{
    uri = new Uri.http('192.168.1.41:8080', url);
  }

  String data = json.encode(body);
  print('uri: ${uri}');

  var response = await http.post(uri, body: data, headers: {HttpHeaders.CONTENT_TYPE: "application/x-www-form-urlencoded", HttpHeaders.AUTHORIZATION: "Basic Y2xpZW50OmNsaWVudHBhc3N3b3Jk", });
  if (response.statusCode == HttpStatus.OK) {
    print("Response body: ${response.body}");
    return json.decode(response.body);
  } else {
    print('Error while posting data:\nHttp status ${response.statusCode}');
    print("Response body: ${response.body}");
    return null;
  }
}

getData(String url, params) async {
  var httpClient = new HttpClient();
  var uri = new Uri.http(
      '192.168.1.41:8080', url);
  print('uri: ${uri}');
  var request = await httpClient.getUrl(uri);
  var response = await request.close();

  if (response.statusCode == HttpStatus.OK) {
    var jsonRes = await response.transform(UTF8.decoder).join();
    var data = json.decode(jsonRes);
    print('data: ${data}');
    return data;
  } else {
    print('Error while getting data:\nHttp status ${response.statusCode}');
    return null;
  }
}