import 'package:flutter/material.dart';
import 'package:mynotes/utils/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialogScreen(BuildContext context) async {
  return showGenericDialog(
    context: context,
    title: 'Sharing',
    content: 'You cannot share empty notes 😵',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
