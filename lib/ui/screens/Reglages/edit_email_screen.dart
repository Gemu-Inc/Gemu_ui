import 'package:flutter/material.dart';

class EditEmailScreen extends StatefulWidget {
  EditEmailScreen({Key key}) : super(key: key);

  @override
  _EditEmailScreenState createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  String _currentEMail;

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
        title: Text('Changer l\'adresse e-mail'),
      ),
      body: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "E-Mail"),
                validator: (value) =>
                    value.isEmpty ? 'Please enter a mail' : null,
                onChanged: (value) => setState(() => _currentEMail = value),
              ),
              RaisedButton(
                  child: Text('Save'),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      print("E-mail updated");
                      //await model.updateUserPseudo(_currentName);
                    }
                    //Navigator.pushNamed(context, NavScreenRoute);
                  })
            ],
          )),
    );
  }
}
