import 'package:flutter/material.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/components/alert_dialog_custom.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  Privacyviewstate createState() => Privacyviewstate();
}

class Privacyviewstate extends State<PrivacyScreen> {
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
        barrierDismissible: false,
        barrierColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white24
            : Colors.black54,
        builder: (BuildContext context) {
          return AlertDialogCustom(context, 'Change privacy',
              'Voulez-vous modifier la confidentialité de votre compte?', [
            TextButton(
                onPressed: () {
                  updatePrivacy(newValue);
                  Navigator.pop(context);
                },
                child: Text(
                  'Oui',
                  style: TextStyle(color: cGreenConfirm),
                )),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Non',
                  style: TextStyle(color: cRedCancel),
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
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary
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
