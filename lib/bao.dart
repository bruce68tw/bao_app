//import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';
import 'all.dart';
import 'bao_detail.dart';
import 'stage_batch.dart';
import 'stage_step.dart';

class Bao extends StatefulWidget {
  const Bao({Key? key}) : super(key: key);

  @override
  _BaoState createState() => _BaoState();
}

class _BaoState extends State<Bao> {
  //1.宣告變數
  bool _isOk = false;       //state variables
  late PagerSrv _pagerSrv;  //pager service
  late PagerDto<BaoRowDto> _pagerDto;

  @override
  void initState() {
    //2.分頁元件, set first, coz function parameter !!
    _pagerSrv = PagerSrv(rebuildAsync);

    //call before rebuild()
    super.initState();

    //3.讀取資料, call async rebuild
    Future.delayed(Duration.zero, ()=> rebuildAsync());
  }

  /// rebuild page
  Future rebuildAsync() async {
    //4.檢查初始狀態, check initial status
    if (!await XpUt.isRegAsync(context)) return;

    //5.讀取資料庫, get rows & check
    await HttpUt.getJsonAsync(context, 'Bao/GetPage', true, _pagerSrv.getDtJson(), (json){
      if (json == null) return;

      _pagerDto = PagerDto<BaoRowDto>.fromJson(json, BaoRowDto.fromJson);
      _isOk = true;
      setState((){}); //call build()
    });
  }

  //6.顯示畫面內容, get view body widget
  Widget getBody() {
    var rows = _pagerDto.data;
    if (rows.isEmpty) return XpUt.emptyMsg();

    var list = XpUt.baosToWidgets(rows, rowsToTrails(rows));
    list.add(_pagerSrv.getWidget(_pagerDto));
    return ListView(children: list);
  }

  //7.畫面結構
  @override
  Widget build(BuildContext context) {
    //check status
    if (!_isOk) return Container();

    //return page
    return Scaffold(
      appBar: WG.appBar('尋寶'),
      body: getBody(),
    );
  }
  
  /// onclick bao item
  /// @id Bao.Id
  void onDetail(String id) {
    ToolUt.openForm(context, BaoDetail(id: id));
  }

  //onOpen Stage
  void onStage(bool isBatch, String id, String name) {
    if (isBatch){
      ToolUt.openForm(context, StageBatch(id: id, name: name));
    } else {
      ToolUt.openForm(context, StageStep(id: id, name: name));
    }
  }

  /// get trailings widget
  /// @rows Bao list rows
  List<Widget> rowsToTrails(List<BaoRowDto> rows) {
    var widgets = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      var row = rows[i];
      var status = XpUt.getAttendStatus(row.id);
      widgets.add(
        (status == null) ? WG.textBtn('看明細', ()=> onDetail(row.id)) :
        (status == AttendEstr.run) ? WG.textBtn('已參加', ()=> onStage(row.isBatch, row.id, row.name), Colors.green) : 
        (status == AttendEstr.finish) ? WG.textBtn('已答對', ()=> onDetail(row.id)) : 
        WG.textBtn('已取消', ()=> onStage(row.isBatch, row.id, row.name), Colors.red)
      );
    }

    return widgets;
  }

} //class