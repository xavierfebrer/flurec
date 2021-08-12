import 'dart:io';

import 'package:hack2s_flutter_util/util/file_util.dart';

abstract class AudioFileRepository {
  Future<List<File>> getRecordingsFiles(String appFolderName, String appSubFolderName, {FileSort fileSort = FileSort.DateDescending});

  Future<List<String>> getRecordingsFilenames(String appFolderName, String appSubFolderName);

  Future<String> getNewRecordingFilePath(String appFolderName, String appSubFolderName, String fileNameBase, String extension);
}
