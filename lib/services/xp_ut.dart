import 'package:flutter/material.dart';
import 'package:path/path.dart' as path; //or will conflict
//import 'package:archive/archive.dart';
import 'dart:io';
import 'package:base_lib/all.dart';
import '../models/bao_row_dto.dart';
import '../stage_batch.dart';
import '../stage_step.dart';

/// static class
class XpUt {
  //=== constant start ===
  ///1.is https or not
  static const isHttps = false;

  ///2.api server end point
  static const apiServer = '192.168.1.103:5001';
  //static const String apiServer = '192.168.66.11:83';

  ///3.aes key string with 16 chars
  static const aesKey = 'YourAesKey';

  ///register file name
  static const regFile = 'MyApp.info';
  //=== constant end ===

  //=== auto set start ===
  ///already init or not
  static bool _isInit = false;

  ///encode userId in info file
  static String _encodeId = '';

  ///aeskey with correct length(16 char)
  static String _aesKey16 = '';

  ///baoId,join status(1:join, else:cancel)
  static final Map<String, String> _attend = {};
  //=== auto set end ===

  static Future initFunAsync([bool testMode=false]) async {
    if (!_isInit) {
      await FunUt.init(isHttps, apiServer, testMode);
      _aesKey16 = StrUt.preZero(16, aesKey, true);
      _isInit = true;
    }
  }

  /*
  /// get aes key with 16 chars(128 bits)
  static String _getAesKey() {
    return StrUt.preZero(16, XpUt.aesKey, true);
  }
  */

  /// aes encode
  /// @data plain text
  /// @return encode string
  static String encode(String data) {
    return StrUt.aesEncode(data, _aesKey16);
  }

  /*
  /// aes decode
  /// @data encode text
  /// @return plain string
  static String decode(String data) {
    return StrUt.aesDecode(data, _aesKey);
  }
  */
  
  /// system initial & login
  /// @context current context
  /// @return initial status
  static Future<bool> isRegAsync(BuildContext? context) async {
    //initial if need
    await initFunAsync();
    if (FunUt.isLogin) return true;

    //read info file if need
    if (_encodeId == '') _encodeId = await readInfoAsync();

    //set FunHp.isLogin
    if (StrUt.isEmpty(_encodeId)) {
      ToolUt.msg(context, '您尚未註冊, 請先執行[我的資料]->[維護基本資料]');
      return false;
    }

    await HttpUt.getJsonAsync(context, 'Home/Login', false, {'info': _encodeId}, (json){
      if (json == null) return false;

      var token = json['token'];
      if (StrUt.notEmpty(token)) {
        HttpUt.setToken(token!);
        FunUt.isLogin = true;
        _importAttend(json['attends']);
      }
    });

    return true;
  }

  ///import bao list into _attend json
  static void _importAttend(List<dynamic>? rows) {
    if (rows == null) return;

    for (var row in rows) {
      _attend[row['BaoId']] = row['AttendStatus'];
    }
  }

  ///get attend status
  static String? getAttendStatus(String baoId) {
    return _attend.containsKey(baoId)
      ? _attend[baoId]
      : null;
  }

  ///attend bao
  static void setAttendStatus(String baoId, String status) {
    _attend[baoId] = status;
  }

  ///open stage form
  static openStage(BuildContext context, bool isBatch, String baoId, String baoName) {
    if (isBatch){
      ToolUt.openForm(context, StageBatch(id: baoId, name: baoName));
    } else {
      ToolUt.openForm(context, StageStep(id: baoId, name: baoName));
    }
  }

  /// get info file object
  static void setInfo(String encodeId) {
    _encodeId = encodeId;

    //create info file
    var file = XpUt.getInfoFile();
    file.writeAsString(encodeId);
  }

  /// get info file object
  static File getInfoFile() {
    return File(FileUt.getFilePath(XpUt.regFile));
  }

  /// read info file string
  static Future<String> readInfoAsync() async {
    var file = getInfoFile();
    return await file.exists() ? await file.readAsString() : '';
  }

  ///return empty message
  static Widget emptyMsg(){
    return const Center(child: Text('目前無任何資料。', 
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        color: Colors.red,
      ),
    ));
  }

  /// baoRows to widget list for Bao/MyBao
  /// @rows source rows
  /// @trails tail widget list
  /// @return list widget
  static List<Widget> baosToWidgets(
      List<BaoRowDto> rows, List<Widget> trails) {

    var widgets = <Widget>[];
    if (rows.isEmpty) return widgets;

    for (int i = 0; i < rows.length; i++) {
      var row = rows[i];
      widgets.add(ListTile(
        title: Row(children: <Widget>[
          row.isMoney
              ? const Icon(Icons.paid, color: Colors.amber)
              : const Icon(Icons.redeem, color: Colors.blue),
          row.isMove
              ? const Icon(Icons.directions_run, color: Colors.red)
              : const Text(''),
          Text(row.name),
        ]),
        subtitle: Text(
            'by: ' + row.corp + '\n' + DateUt.format2(row.startTime) + ' 開始'),
        trailing: trails[i],
      ));
      widgets.add(WidgetUt.divider());
    }

    return widgets;
  }

  static String dirCmsCard() {
    return FunUt.dirApp + 'image/cmsCard';
  }

  /// get directory of stage image
  static String dirStageImage(String baoId) {
    return FunUt.dirApp + 'image/stage' + baoId;
  }

  /// download stage image
  static Future downStageImage(BuildContext context, String baoId, 
      bool isBatch, String dirImage) async {

    //create folder if need
    var dir = Directory(dirImage);
    //TODO: temp add for remove cached image files
    //dir.deleteSync(recursive: true);

    if (await dir.exists() && dir.listSync().isNotEmpty) return;

    //download it
    var action = isBatch ? 'Stage/GetBatchImage' : 'Stage/GetStepImage';
    await HttpUt.saveUnzipAsync(context, action, {'id': baoId}, dirImage);
  }

  //get body widget for stageStep/stageBatch
  static Widget getStageBody(String dirBao, bool isBatch, 
    TextEditingController ctrl, Function onSubmit) {

    //set widgets & return
    var dir = Directory(dirBao);
    var files = dir.listSync().toList();
    if (files.isEmpty) return emptyMsg();

    var widgets = <Widget>[];
    for (var file in files) {
      var cols = path.basename(file.path).split('_');
      //var no = int.parse(cols[0]);
      var text = '第' + cols[0] + '關';
      if (cols.length > 3){
        text += ', 提示：' + cols[2];
      }

      //widgets.add(ListTile(title: Text('(' + StrUt.addNum(no, 1) + ')')));
      //add text
      widgets.add(Padding(
        padding: const EdgeInsets.only(top:10, bottom:10, left: 5),
        child: WidgetUt.text(16, text),
      )); 
      //add image
      widgets.add(InteractiveViewer(
        panEnabled: true,
        boundaryMargin: WidgetUt.gap(0),
        minScale: 1,
        maxScale: 8, 
        child: Image.file(file as File),
      ));
      widgets.add(const Divider());
    }    

    String label;
    int lines;
    if (isBatch){
      label = '(每行一個答案，不含標點符號)';
      lines = files.length;
    } else {
      label = '(請輸入這個關卡的答案，不含標點符號)';
      lines = 1;
    }

    //add input
    widgets.add(TextField(
      controller: ctrl,
      maxLines: lines,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        counterText: ctrl.text,
        labelText: label,
        //hintText: 'type something...',
        border: const OutlineInputBorder(),
      ),
      //onChanged: (text) => setState(() {}),
    ));

    //add submit button
    widgets.add(Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(20),
      child: ElevatedButton(
        child: const Text('送出解答', style: TextStyle(fontSize: 15)),
        onPressed: ()=> onSubmit,
      ),
    ));

    return ListView(
      padding: WidgetUt.gap(10),
      children: widgets,
    );
  }

} //class
