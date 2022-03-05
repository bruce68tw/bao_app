import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';
import 'all.dart';

//回復用戶帳號
class UserRecover extends StatefulWidget {  
  const UserRecover({Key? key, required this.email}) : super(key: key);
  final String email;

  @override
  _UserRecoverState createState() => _UserRecoverState();
}

class _UserRecoverState extends State<UserRecover> {  
  int _step = 1;  //control button status, 1/2
  final authCtrl = TextEditingController();

  /*
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, ()=> rebuildAsync());
  }
  */

  void rebuild(int step) {
    _step = step;
    setState((){});
  }

  /// onclick send email
  Future onEmailAsync() async {
    //get error msg if any
    await HttpUt.getStrAsync(context, 'User/EmailRecover', false, {'email': widget.email}, (msg){
      if (msg == ''){
        ToolUt.msg(context, 'Email已經送出, 請在下方欄位填入郵件裡面的認証碼後, 再按 [回復用戶帳號] 按鈕。');
        rebuild(2);
      } else {
        ToolUt.msg(context, msg);
      }      
    });
  }

  Future onRecoverAsync() async {
    // validate
    var authCode = authCtrl.text;
    if (StrUt.isEmpty(authCode)){
      ToolUt.msg(context, '認証碼不可空白。');
      return;
    }

    //return encode userId
    var data = XpUt.encode(authCode + ',' + widget.email);
    await HttpUt.getStrAsync(context, 'User/Auth', false, {'data': data}, (key){
      XpUt.setInfo(key);
      ToolUt.msg(context, '回復帳號作業已經完成。');
    });
  }

  @override
  Widget build(BuildContext context) {
    //if (!_isOk) return Container();

    return Scaffold(
      appBar: WG.appBar('回復用戶帳號'),
      body: SingleChildScrollView(
        padding: WG.pagePad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            WG.labelText('Email', widget.email),
            WidgetUt.text(16, '要回復這個Email所對應的用戶帳號, ' 
'請點擊下方的 [寄送認証郵件] 按鈕, 系統將會寄送認証Email到上面的信箱。'),
            WidgetUt.divider(),

            (_step == 1) ? WG.tailBtn('寄送認証郵件', ()=> onEmailAsync()) : 
            Column(
              children: <Widget>[
                TextFormField(
                  controller: authCtrl,
                  style: WG.inputStyle(),
                  decoration: WG.inputLabel('請輸入Email信件裡面的認証碼'),
                ),
                WG.tailBtn('回復用戶帳號', ()=> onRecoverAsync()),
            ]),
          ],
        ),
      ),
    );
  }
  
} //class
