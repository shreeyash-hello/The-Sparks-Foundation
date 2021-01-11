import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app4/sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'first_screen.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Social Media Integration'),
          ),
          body: Container(
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/Untitled.jpg"),
                      fit: BoxFit.cover)
              ),
              child: Column(children: <Widget>[
                FlutterLogo(size: 150),
                SizedBox(height: 100),

                Fbsignin(),
                Container(
                    margin: EdgeInsets.all(25),
                    child: isLoggedIn
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
              )
                  : GoogleAuthButton(
                onPressed: () {
                  signInWithGoogle().then((result) {
                    if (result != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return FirstScreen();
                          },
                        ),
                      );
                    }
                  });
                },
              ),
            ),
          ]
          ))
      ),
    );
  }

  bool isLoggedIn = false;
  var profileData;

  var facebookLogin = FacebookLogin();

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  @override
  Widget Fbsignin() {
    return OutlineButton(
        onPressed: () => facebookLogin.isLoggedIn
        .then((isLoggedIn) => isLoggedIn ? _logout() : {}),
        child: isLoggedIn
        ? _displayUserData(profileData)
        : _displayLoginButton(),
    );
  }

  void initiateFacebookLogin() async {
    var facebookLoginResult =
    await facebookLogin.logInWithReadPermissions(['email']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(400)&access_token=${facebookLoginResult
                .accessToken.token}');

        var profile = json.decode(graphResponse.body);
        print(profile.toString());

        onLoginStatusChanged(true, profileData: profile);
        break;
    }
  }

  _displayUserData(profileData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 200.0,
          width: 200.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(
                profileData['picture']['data']['url'],
              ),
            ),
          ),
        ),
        SizedBox(height: 28.0),
        Text(
          "${profileData['name']}\n${profileData['email']}",
          style: TextStyle(
            fontSize: 20.0,
            letterSpacing: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  _displayLoginButton() {
    return RaisedButton(
      onPressed: () => initiateFacebookLogin(),
      color: Colors.blue,
      textColor: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Text("Sign in with Facebook",
        style: TextStyle(fontSize: 20),
      )
    );
  }

  _logout() async {
    await facebookLogin.logOut();
    onLoginStatusChanged(false);

  }
}
