import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Gemu/models/user.dart';
import 'package:Gemu/services/database_service.dart';
import 'package:Gemu/ui/screens/Activities/Messages/contacts_screen.dart';

class NewMessageProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<UserModel>>.value(
      value: DatabaseService.streamUsers(),
      child: ContactsScreen(),
    );
  }
}
