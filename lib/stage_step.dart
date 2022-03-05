//import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';
import 'all.dart';

class StageStep extends StatefulWidget {
  const StageStep({Key? key, required this.id, required this.name})
      : super(key: key);

  //input parameter
  final String id;    //Bao.Id
  final String name;  //Bao.Name

  @override
  _StageStepState createState() => _StageStepState();
}

class _StageStepState extends State<StageStep> {
  bool _isOk = false;   //status
  late String _baoId;
  late String _dirImage;
  final replyCtrl = TextEditingController();

  @override
  void initState() {
     _baoId = widget.id;
     _dirImage = XpUt.dirStageImage(_baoId);

    super.initState();
    Future.delayed(Duration.zero, ()=> rebuildAsync());
  }

  Future rebuildAsync() async {

    /*
    //create folder if need
    var dirBao = Directory(_dirImage);
    if (!await dirBao.exists()) {
      await dirBao.create(recursive: true);
    }

    //if no file, download it
    if (dirBao.listSync().isEmpty){
      var bytes =
          await HttpUt.getFileBytesAsync(context, 'Stage/GetStepImage', {'id': _baoId});
      if (bytes != null) {
        var file = ZipDecoder().decodeBytes(bytes)[0];

        // Extract the contents of the Zip archive to disk.
        //..cascade operator
        File(dirBao.path + '/' + file.name)
          ..createSync()
          ..writeAsBytesSync(file.content as List<int>, flush:true);
      }
    }
    */

    await XpUt.downStageImage(context, _baoId, false, _dirImage);
    _isOk = true;
    setState((){});
  }

  //onclick submit
  Future onSubmitAsync() async {
    var reply = replyCtrl.text;
    if (StrUt.isEmpty(reply)) {
      ToolUt.msg(context, '不可空白。');
      return;
    }

    //0(fail),1(ok)
    var data = {'id': _baoId, 'reply': reply};
    await HttpUt.getStrAsync(context, 'Stage/ReplyStep', false, data, (result){
      if (result == '1'){
        XpUt.setAttendStatus(_baoId, AttendEstr.finish);
        ToolUt.msg(context, '恭喜答對了!');
      } else {
        ToolUt.msg(context, '哦哦，你猜錯了!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOk) return Container();

    return Scaffold(
      appBar: WG.appBar('解謎: ' + widget.name),
      body: XpUt.getStageBody(_dirImage, false, replyCtrl, onSubmitAsync),
    );
  }
  
} //class