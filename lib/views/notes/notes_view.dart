import 'package:flutter/material.dart';
import 'package:my_notes/services/auth/auth_service.dart';

import '../../constants/routes.dart';
import '../../enums/menu_action.dart';
import '../../services/crud/notes_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  _NotesViewState createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(newNoteRoute);
              },
              icon: Icon(Icons.add)),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                ),
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            // case ConnectionState.none:
            //   break;
            // case ConnectionState.waiting:
            //   break;
            // case ConnectionState.active:
            //   break;
            case ConnectionState.waiting:
              return const Center(child: Text('waiting 1', style: TextStyle()));
            case ConnectionState.done:
              // return Text('Stream builder', style: const TextStyle());
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    // case ConnectionState.none:
                    //   break;
                    case ConnectionState.active:
                      return const Center(child: Text('active', style: TextStyle()));
                    case ConnectionState.waiting:
                      return const Center(child: Text('waiting 2', style: TextStyle()));

                    case ConnectionState.done:
                      return const Center(child: Text('done', style: TextStyle()));
                    default:
                      return const Center(child: Text('default 2', style: const TextStyle()));
                  }
                },
              );
            default:
              return const Center(child: Text('default 1', style: const TextStyle()));
            // return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
