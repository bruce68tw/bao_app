import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';
import 'all.dart';

class MyBao extends StatefulWidget {
  const MyBao({Key? key}) : super(key: key);

  @override
  _MyBaoState createState() => _MyBaoState();
}

class _MyBaoState extends State<MyBao> {  
  bool _isOk = false;   //status
  late PagerSrv _pagerSrv;  //pager service
  late PagerDto<BaoRowDto> _pagerDto;

  @override
  void initState() {
    //set first, coz function parameter !!
    _pagerSrv = PagerSrv(rebuildAsync);

    //call before reload()
    super.initState();
    Future.delayed(Duration.zero, ()=> rebuildAsync());
  }

  //reload page
  Future rebuildAsync() async {
    if (!await XpUt.isRegAsync(context)) return;

    //get rows & check
    await HttpUt.getJsonAsync(context, 'MyBao/GetPage', true, _pagerSrv.getDtJson(), (json){
      if (json == null) return;
      
      _pagerDto = PagerDto<BaoRowDto>.fromJson(json, BaoRowDto.fromJson);
      _isOk = true;
      setState((){});
    });
  }

  ///get view body widget
  Widget getBody() {
    var rows = _pagerDto.data;
    if (rows.isEmpty) return XpUt.emptyMsg();

    var list = XpUt.baosToWidgets(rows, rowsToTrails(rows));
    list.add(_pagerSrv.getWidget(_pagerDto));
    return ListView(children: list);
  }

  //get trailings widget
  List<Widget> rowsToTrails(List<BaoRowDto> rows) {
    var widgets = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      var row = rows[i];
      widgets.add(WG.textBtn('解題', ()=> onAns(row.isBatch, row.id, row.name)));
    }
    return widgets;
  }

  void onAns(bool isBatch, String baoId, String baoName) {
    XpUt.openStage(context, isBatch, baoId, baoName);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOk) return Container();

    return Scaffold(
      appBar: WG.appBar('我的尋寶'),
      body: getBody(),
    );
  }
  
}//class
