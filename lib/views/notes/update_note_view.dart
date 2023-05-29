// import 'package:flutter/material.dart';
// import 'package:mynotes/services/crud/notes_service.dart';
//
// class UpdateNoteView extends StatefulWidget {
//   const UpdateNoteView({Key? key, required this.noteToUpdate})
//       : super(key: key);
//
//   final DatabaseNote? noteToUpdate;
//
//   @override
//   State<UpdateNoteView> createState() => _UpdateNoteViewState();
// }
//
// class _UpdateNoteViewState extends State<UpdateNoteView> {
//   late final NoteService _notesService;
//
//   late final TextEditingController _textEditingController;
//
//   void _saveNoteIfTextNotEmpty() async {
//     final text = _textEditingController.text;
//     if (widget.noteToUpdate != null && text.isNotEmpty) {
//       await _notesService.updateNote(
//         note: widget.noteToUpdate!,
//         text: text,
//       );
//     }
//   }
//
//   void _textControllerListener() async {
//     final note = widget.noteToUpdate;
//     if (note == null) return;
//     final text = _textEditingController.text;
//     await _notesService.updateNote(
//       note: note,
//       text: text,
//     );
//   }
//
//   void _setupTextControllerListener() {
//     _textEditingController.removeListener(_textControllerListener);
//     _textEditingController.addListener(_textControllerListener);
//   }
//
//   Future<DatabaseNote?> handleNote() async {
//     return widget.noteToUpdate;
//   }
//
//   @override
//   void initState() {
//     _textEditingController =
//         TextEditingController(text: widget.noteToUpdate?.text);
//     _notesService = NoteService();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _saveNoteIfTextNotEmpty();
//     _textEditingController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Note'),
//       ),
//       body: FutureBuilder(
//         future: handleNote(),
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.active:
//             case ConnectionState.done:
//               _setupTextControllerListener();
//               if (snapshot.hasData) {
//                 return Padding(
//                   padding: const EdgeInsets.all(13.0),
//                   child: TextField(
//                     controller: _textEditingController,
//                     keyboardType: TextInputType.multiline,
//                     decoration: const InputDecoration(
//                       prefixIcon: Icon(Icons.edit),
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 );
//               }
//             default:
//               return const Text('1');
//           }
//
//           return const Text('2');
//         },
//       ),
//     );
//   }
// }
