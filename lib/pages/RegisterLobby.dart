import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ubus_track/model/baseapi.dart';
import 'package:ubus_track/model/global_state.dart';
import 'package:ubus_track/model/staionModel.dart';

class LocationRegisterLobby extends StatefulWidget {
  @override
  _LocationRegisterLobbyState createState() => _LocationRegisterLobbyState();
}

class _LocationRegisterLobbyState extends State<LocationRegisterLobby> {

  TextEditingController _controller = TextEditingController();
  final storage = FlutterSecureStorage();

  void registerAction(String token) {
    _onLoading(token);
  }



  void _onLoading(token) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            color: Colors.transparent,
            width: 100,
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            )
          ),
        );
      },
    );
    print(token);
    BaseAPI.registerDevice(token).then((val) async {
      if(val.statusCode == 200) {
        var res = val.data;
        print(res['id']);
        print(val.data);
        GlobalValue.uid = res['id'];
        await storage.write(key: 'uid', value: GlobalValue.uid.toString());
        await GlobalValue.initStation();

        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.of(context).pop();
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error Code ${val.statusCode}'),
              // titleTextStyle: TextStyle(color: Colors.red),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text("${val.data}"),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    var width = MediaQuery.of(context).size.width;
    var card = Container(
      width: 300,
      padding: EdgeInsets.all(10),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Text('Token',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                child: TextField(
                  decoration: new InputDecoration(
                    hintText: 'Enter token key',
                      border: new OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6.0))
                      ),
                      labelText: 'Key'
                  ),
                  controller: _controller,
                ),
              ),
              TextButton(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: Text('Register')
                ),
                onPressed: () {
                  registerAction(_controller.value.text);
                },
              )
            ],
          ),
        ),

      ),
    );

    return Scaffold(
      body: Container(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            card,
          ],
        ),
      ),
    );
  }
}
