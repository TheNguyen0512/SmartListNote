import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartlist/features/notes/domain/entities/note.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  if (kDebugMode) {
    print('Hive initialized successfully');
  }
}

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    return Note(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
      isCompleted: reader.readBool(),
      dueDate: reader.read() as DateTime?,
      priority: Priority.values[reader.readInt()],
      createdAt: reader.read() as DateTime,
      updatedAt: reader.read() as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeString(obj.id ?? '');
    writer.writeString(obj.title);
    writer.writeString(obj.description ?? '');
    writer.writeBool(obj.isCompleted);
    writer.write(obj.dueDate);
    writer.writeInt(obj.priority.index);
    writer.write(obj.createdAt);
    writer.write(obj.updatedAt);
  }
}