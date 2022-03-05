import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';
import 'all.dart';

class StageBatch extends StatefulWidget {
  const StageBatch({Key? key, required this.id, required this.name})
      : super(key: key);

  //input parameter
  final String id;    //Bao.Id
  final String name;  //Bao.Name

  @override
  _StageBatchState createState() => _StageBatchState();
}

class _StageBatchState extends State<StageBatch> {
  //static const dirImage = 'image';    // image folder name  
  bool _isOk = false;   //status
  //int _stageCount = 0;
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

  /*
  String imageDir() {
    return FunUt.dirApp + dirImage + '/' + _baoId;
  }
  */

  Future rebuildAsync() async {

    /*
    //download images if need
    var dirBao = Directory(imageDir());
    if (!await dirBao.exists()) {
        await dirBao.create(recursive: true);
    }

      //download zip file and unzip
      var bytes =
          await HttpUt.getFileBytesAsync(context, 'Stage/GetBatchImage', {'id': _baoId});
      if (bytes == null) {
        //log('無法下載壓縮圖檔。');
        _stageCount = 0;
        _isOk = true;
        setState((){});
        return;
      }

      var files = ZipDecoder().decodeBytes(bytes);

      // Extract the contents of the Zip archive to disk.
      var dirBase = dirBao.path + '/';
      for (var file in files) {
        //..cascade operator
        File(dirBase + file.name)
          ..createSync()
          ..writeAsBytesSync(file.content as List<int>, flush:true);
      }
    }
    */
    await XpUt.downStageImage(context, _baoId, true, _dirImage);
    _isOk = true;
    setState((){});
  }

  /*
  //return image list
  List<Widget> getImages() {
    //get image list
    var dir = Directory(_dirImage);
    var files = dir.listSync().toList();
    //files.sort(); //order by name

    //set widgets & return
    _stageCount = files.length;
    var widgets = <Widget>[];

    for (var file in files) {
      var no = path.basename(file.path).substring(0, 1);
      //widgets.add(ListTile(title: Text('(' + StrUt.addNum(no, 1) + ')')));
      widgets.add(Padding(
        padding: const EdgeInsets.only(top:10, bottom:10, left: 5),
        child: WG.text(16, '(' + StrUt.addNum(no, 1) + ')'),
      )); 
      widgets.add(InteractiveViewer(
        panEnabled: true,
        boundaryMargin: ST.gap(0),
        minScale: 1,
        maxScale: 8, 
        child: Image.file(file as File),
      ));
      widgets.add(const Divider());
    }

    //add textarea input
    widgets.add(TextField(
      controller: replyCtrl,
      maxLines: _stageCount,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        counterText: replyCtrl.text,
        labelText: '(每行一個答案，不含標點符號)',
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
        onPressed: () => {onSubmitAsync()},
      ),
    ));

    return widgets;
  }
  */

  //onclick submit
  Future onSubmitAsync() async {
    var reply = replyCtrl.text;
    if (StrUt.isEmpty(reply)) {
      ToolUt.msg(context, '不可空白。');
      return;
    }

    //ToolUt.openWait(context);

    //0(fail),1(ok)
    var data = {'id': _baoId, 'reply': reply};
    await HttpUt.getStrAsync(context, 'Stage/ReplyBatch', false, data, (result){
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