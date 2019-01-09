import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_ppicker/image_picker_handler.dart';
import 'package:flutter_image_ppicker/image_picker_dialog.dart';
import 'package:http/http.dart' as http ;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin,ImagePickerListener{

  File _image;
  AnimationController _controller;
  ImagePickerHandler imagePicker;
  String printValue = "";
  double SIZE = 500.0;
  IconData icon = Icons.camera;
  FloatingActionButtonLocation floatingActionButtonLocation = FloatingActionButtonLocation.centerDocked;

  void returnFunction(){
      if(_image == null){
        imagePicker.showDialog(context);
      }
      else {
        print(showServerResult());
      }

  }
  

  @override
  void initState() {
    super.initState();

      _controller = new AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      imagePicker = new ImagePickerHandler(this, _controller);
      imagePicker.init();
  }
  File getPicture(){
    return _image;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title,
        style: new TextStyle(
          color: Colors.white
        ),
        ),
      ),
        floatingActionButton: FloatingActionButton(onPressed:  returnFunction,
        child: _image == null ? Icon(icon) : Icon(Icons.send),
        ),
        floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new IconButton(icon: new Icon(Icons.menu), onPressed: null),
          ],
        ),
      ),
      body:

      Column(
        children: <Widget>[new GestureDetector(
          child: new Center(
            child: _image == null
                ? new Stack(
              children: <Widget>[

                new Center(

                )
              ],
            )
                : new Container(
              height:SIZE-150,
              width: double.infinity,
              decoration: new BoxDecoration(
                color: const Color(0xff7c94b6),
                image: new DecorationImage(
                  image: new ExactAssetImage(_image.path),
                  fit: BoxFit.cover,
                ),
//                border:
//                Border.all(color: Colors.red, width: 5.0),
//                borderRadius:
//                new BorderRadius.all(const Radius.circular(80.0)),
              ),
            ),
          ),

        ),
          Text(printValue)
        ],

      ),


    );
  }

  @override
  userImage(File _image) {
    setState(() {
      this._image = _image;
      floatingActionButtonLocation = FloatingActionButtonLocation.endDocked;
    });
  }
  returnModelName(String name){
    setState(() {
      this.printValue = name;
      SIZE = 300.0;
//      _image = null;
    });
  }

  Future<String> showServerResult() async{

    var stream = http.ByteStream(DelegatingStream.typed(_image.openRead()));
    var length = await _image.length();
    var uri = Uri.parse("http://192.168.64.2/htdocs/executePph.php");
    var request = http.MultipartRequest('POST' , uri);
    var multiPartFile = http.MultipartFile("image" , stream , length , filename: _image.path);
    request.files.add(multiPartFile);
    var response = await request.send();
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
      value  = "Model Prediction is :" + value ;
      returnModelName(value);
    });

    print(response.request);
    return response.toString();
  }

}
//uploadImageThroughhttp