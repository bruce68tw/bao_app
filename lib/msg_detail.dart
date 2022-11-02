import 'package:flutter/material.dart';
//import 'package:flutter_html/flutter_html.dart';
import 'package:base_lib/all.dart';
import 'all.dart';
import 'enums/cms_type_estr.dart';

class MsgDetail extends StatefulWidget {
  const MsgDetail({Key? key, required this.id}) : super(key: key);
  final String id;  //input Msg.Id

  @override
  _MsgDetailState createState() => _MsgDetailState();
}

class _MsgDetailState extends State<MsgDetail> {
  bool _isOk = false;
  bool _isCard = false;
  late Map<String, dynamic>? _json;  //msg row json
  late Widget? _bodyWidget;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, ()=> rebuildAsync());
  }

  Future rebuildAsync() async {
    //1.get Cms row
    await HttpUt.getJsonAsync(context, 'Cms/GetDetail', false, {'id': widget.id}, (json) {
      //Future.delayed(Duration.zero, ()=> rebuildAsync2(json));
      //2.async function
      Future.delayed(Duration.zero, () async {
        //check result
        _isOk = (json != null);
        if (!_isOk) return;

        _json = json!;
        _isCard = (json['CmsType'] == CmsTypeEstr.card);
        if (_isCard){
          //3.get image file
          _bodyWidget = await HttpUt.getImageAsync(context, 'Cms/ViewFile', 
            { 'id':widget.id, 'ext':FileUt.jsonToImageExt(json)});
          _bodyWidget ??= Xp.emptyMsg();
        } else {
          _bodyWidget = WG2.labelText('訊息內容', json['Text']);
        }

        setState((){});
      });
    });
  }

  /*
  Future rebuildAsync2(Map<String, dynamic>? json) async {
    //get row
    _isOk = (json != null);
    if (!_isOk) return;

    _json = json!;
    _isCard = (json['CmsType'] == CmsTypeEstr.card);
    if (_isCard){
      _bodyWidget = await HttpUt.getImageAsync(context, 'Cms/ViewFile', 
        { 'id':widget.id, 'ext':FileUt.jsonToImageExt(json)});
      _bodyWidget ??= XpUt.emptyMsg();
    } else {
      _bodyWidget = WG.labelText('訊息內容', json['Text']);
    }

    setState((){});      
  }
  */

  @override
  Widget build(BuildContext context) {
    if (!_isOk) return Container();

    var json = _json!;
    return Scaffold(
      appBar: WG2.appBar('最新消息明細'),
      body: SingleChildScrollView(
        padding: WG2.pagePad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            WG2.labelText('標題', json['Title']),
            _bodyWidget!
          ],
        ),
      ),
    );
  }
  
} //class