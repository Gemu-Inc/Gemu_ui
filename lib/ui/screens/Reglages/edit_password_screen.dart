import 'package:flutter/material.dart';

class EditPasswordScreen extends StatefulWidget {
  EditPasswordScreen({Key key}) : super(key: key);

  @override
  _EditPasswordScreenState createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _currentPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black26,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Changer le mot de passe'),
      ),
      body: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Password"),
                validator: (value) =>
                    value.isEmpty ? 'Please enter a password' : null,
                onChanged: (value) => setState(() => _currentPassword = value),
              ),
              RaisedButton(
                  child: Text('Save'),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      print("Password updated");
                      //await model.updateUserPseudo(_currentName);
                    }
                    //Navigator.pushNamed(context, NavScreenRoute);
                  })
            ],
          )),
    );
  }
}
