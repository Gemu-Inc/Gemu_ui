import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gemu/models/user.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/ui/screens/Activities/Messages/contacts_screen.dart';

class NewMessageProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<UserModel>>.value(
      initialData: [],
      value: DatabaseService.streamUsers(),
      child: ContactsScreen(),
    );
  }
}
