import 'package:flurec/data/repository/audio_file_repository_impl.dart';
import 'package:flurec/data/repository/audio_record_repository_impl.dart';
import 'package:flurec/domain/repository/audio_file_repository.dart';
import 'package:flurec/domain/repository/audio_record_repository.dart';
import 'package:get_it/get_it.dart';

class Locator {
  static final getIt = GetIt.I;

  static Future<void> initializeDI() async {
    await _data();
    await _domain();
    await _view();
  }

  static Future<void> _data() async {
    // DATA
    getIt.registerSingleton<AudioFileRepository>(AudioFileRepositoryImpl());
    getIt.registerSingleton<AudioRecordRepository>(AudioRecordRepositoryImpl());
  }

  static Future<void> _domain() async {}

  static Future<void> _view() async {}
}
