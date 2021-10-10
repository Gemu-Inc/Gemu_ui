import 'package:flutter/material.dart';
import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/widgets/alert_dialog_custom.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  PrivacyScreenState createState() => PrivacyScreenState();
}

class PrivacyScreenState extends State<PrivacyScreen> {
  late bool isAccountPrivate;

  updatePrivacy(bool newValue) async {
    if (newValue) {
      await me!.ref!.update({'privacy': 'private'});
    } else {
      await me!.ref!.update({'privacy': 'public'});
    }
    setState(() {
      isAccountPrivate = newValue;
    });
  }

  Future alertPrivacy(bool newValue) {
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialogCustom(context, 'Change privacy',
              'Voulez-vous modifier la confidentialité de votre compte?', [
            TextButton(
                onPressed: () {
                  updatePrivacy(newValue);
                  Navigator.pop(context);
                },
                child: Text(
                  'Oui',
                  style: TextStyle(color: Colors.blue[200]),
                )),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Non',
                  style: TextStyle(color: Colors.red[200]),
                ))
          ]);
        });
  }

  @override
  void initState() {
    if (me!.privacy == 'public') {
      setState(() {
        isAccountPrivate = false;
      });
    } else {
      setState(() {
        isAccountPrivate = true;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 6,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios)),
        title: Text('Privacy'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ])),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Private account',
                style: mystyle(14),
              ),
              Switch(
                  value: isAccountPrivate,
                  onChanged: (newValue) {
                    alertPrivacy(newValue);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
