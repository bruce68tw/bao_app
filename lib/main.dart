import 'package:flutter/material.dart';
import 'bao.dart';
import 'msg.dart';
import 'my_data.dart';

void main()=> runApp(const MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainForm(),
    );
  }
} //MyApp

class MainForm extends StatefulWidget {
  const MainForm({Key? key}) : super(key: key);

  @override
  _MainFormState createState() => _MainFormState();
}

class _MainFormState extends State<MainForm> {
  //1.控制要顯示的畫面
  int _index = 0;
  final _items = <Widget>[
    const Bao(),
    const Msg(),
    const MyData(),
  ];

  @override
  Widget build(BuildContext context) {
    //2.主畫面內容
    return Scaffold(
      body: SafeArea(
        child: _items.elementAt(_index),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          item('尋寶', Icons.redeem),
          item('最新消息', Icons.unsubscribe),
          item('我的資料', Icons.person),
        ],
        currentIndex: _index,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: onItem,
        //type: BottomNavigationBarType.shifting,
        //iconSize: 40,
        //elevation: 5
      ),
    );
  }

  ///get icon item
  BottomNavigationBarItem item(String label, IconData icon){
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }

  //onclick item
  void onItem(int index) {
    setState(()=> _index = index);
  }

} //class