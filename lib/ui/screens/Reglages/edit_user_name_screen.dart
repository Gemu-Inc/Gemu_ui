import 'package:flutter/material.dart';

class EditUserNameScreen extends StatefulWidget {
  EditUserNameScreen({Key key}) : super(key: key);

  @override
  _EditUserNameScreenState createState() => _EditUserNameScreenState();
}

class _EditUserNameScreenState extends State<EditUserNameScreen> {
  final _formKey = GlobalKey<FormState>();
  String _currentName;

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
        title: Text('Changer le nom d\'utilisateur'),
      ),
      body: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Pseudo"),
                validator: (value) =>
                    value.isEmpty ? 'Please enter a name' : null,
                onChanged: (value) => setState(() => _currentName = value),
              ),
              RaisedButton(
                  child: Text('Save'),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      print("Username updated");
                      //await model.updateUserPseudo(_currentName);
                    }
                    //Navigator.pushNamed(context, NavScreenRoute);
                  })
            ],
          )),
    );
  }
}
