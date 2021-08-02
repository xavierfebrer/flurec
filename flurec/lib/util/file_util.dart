import 'dart:io';

import 'package:hack2s_flutter_util/util/file_util.dart';
import 'package:path/path.dart' as path;

class FlurecFileUtil {
  static Future<List<File>> getRecordingsFiles(String appFolderName, String appSubFolderName, {FileSort fileSort = FileSort.DateDescending}) async {
    Directory recordingsDirectory = await Hack2sFileUtil.getRecordingsDirectory(appFolderName, appSubFolderName);
    List<File> list = await Hack2sFileUtil.getFiles(recordingsDirectory);
    Hack2sFileUtil.sort(list, fileSort: fileSort);
    return list;
  }

  static Future<List<String>> getRecordingsFilenames(String appFolderName, String appSubFolderName) async {
    Directory recordingsDirectory = await Hack2sFileUtil.getRecordingsDirectory(appFolderName, appSubFolderName);
    List<String> list = await Hack2sFileUtil.getFilenames(recordingsDirectory);
    return list;
  }

  static Future<String> getNewRecordingFilePath(String appFolderName, String appSubFolderName, String fileNameBase, String extension) async {
    Directory recordingsDirectory = await Hack2sFileUtil.getRecordingsDirectory(appFolderName, appSubFolderName);
    int index = 1;
    File? file;
    while (file == null || await file.exists()) {
      file = File(path.join(recordingsDirectory.path, "$fileNameBase$index$extension"));
      if(!await file.exists()){
        break;
      }
      index++;
    }
    return file.path;
  }
}
