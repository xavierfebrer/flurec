import 'dart:io';

import 'package:flurec/util/Constant.dart';
import 'package:flurec/util/DebugUtil.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileUtil {
  static Future<List<String>> getFilenames(Directory fileDirectory) async {
    return (await getFiles(fileDirectory)).map((file) => getName(file)).toList();
  }

  static Future<List<File>> getFiles(Directory fileDirectory) async {
    fileDirectory = await createDirs(fileDirectory);
    DebugUtil.log("${Constant.LOG_TAG}", "getFilenames() fileDirectory: $fileDirectory exists: ${await fileDirectory.exists()}");
    if (await fileDirectory.exists()) {
      List<FileSystemEntity> files = await fileDirectory.list().toList();
      DebugUtil.log("${Constant.LOG_TAG}", "getFilenames() files: $files");
      List<File> map = files.map((FileSystemEntity file) => File(file.path)).toList();
      DebugUtil.log("${Constant.LOG_TAG}", "getFilenames() map: $map");
      return map;
    }
    return List<File>();
  }

  static Future<Directory> createDirs(Directory dir, {bool recursive: true}) async {
    if (!await dir?.exists()) {
      try {
        return await dir.create(recursive: recursive);
      } catch (e) {}
    }
    return dir;
  }

  static Future<File> createFileByPath(String filePath, {bool recursive: true}) async {
    return await createFile(File(filePath));
  }

  static Future<File> createFile(File file, {bool recursive: true}) async {
    if (!await file?.exists()) {
      try {
        return await file.create(recursive: recursive);
      } catch (e) {}
    }
    return file;
  }

  static Future<bool> deleteFile(File fileToDelete) async {
    if (await fileToDelete?.exists()) {
      try {
        File deletedFile = await fileToDelete.delete();
        return !await deletedFile?.exists();
      } catch (e) {}
    }
    return false;
  }

  static Future<bool> deleteFileByPath(String filePathToDelete) async => await deleteFile(File(filePathToDelete));

  static Future<List<String>> deleteFilesByPath(List<String> filePathsToDelete) async {
    List<String> deletedFilePaths = [];
    for (String filePath in filePathsToDelete) {
      if (await FileUtil.deleteFileByPath(filePath)) deletedFilePaths.add(filePath);
    }
    return deletedFilePaths;
  }

  static Future<Directory> getAppDirectory() async {
    Directory appBaseDir = await createDirs(await getApplicationDocumentsDirectory());
    DebugUtil.log("${Constant.LOG_TAG}", "getAppDirectory() appBaseDir: $appBaseDir exists: ${await appBaseDir.exists()}");
    return appBaseDir != null ? await createDirs(Directory(path.join(appBaseDir.path, Constant.APP_NAME))) ?? null : null;
  }

  static Future<Directory> getRecordingsDirectory() async {
    Directory appDirectory = await getAppDirectory();
    DebugUtil.log("${Constant.LOG_TAG}", "getRecordingsDirectory() appDirectory: $appDirectory exists: ${await appDirectory.exists()}");
    return appDirectory != null ? await createDirs(Directory(path.join(appDirectory.path, Constant.FOLDER_NAME_RECORDINGS))) ?? null : null;
  }

  static Future<List<File>> getRecordingsFiles({bool sortedByFilename = false, bool sortedAscending = true}) async {
    Directory recordingsDirectory = await getRecordingsDirectory();
    DebugUtil.log("${Constant.LOG_TAG}", "getRecordingsFiles() recordingsDirectory: $recordingsDirectory exists: ${await recordingsDirectory.exists()}");
    List<File> list = await getFiles(recordingsDirectory) ?? List<String>();
    if (sortedByFilename) sortByFilename(list, sortedAscending: sortedAscending);
    DebugUtil.log("${Constant.LOG_TAG}", "list: $list");
    return list;
  }

  static Future<List<String>> getRecordingsFilenames() async {
    Directory recordingsDirectory = await getRecordingsDirectory();
    DebugUtil.log("${Constant.LOG_TAG}", "getRecordingsFiles() recordingsDirectory: $recordingsDirectory exists: ${await recordingsDirectory.exists()}");
    List<String> list = await getFilenames(recordingsDirectory);
    DebugUtil.log("${Constant.LOG_TAG}", "list: $list");
    return recordingsDirectory != null ? list : List<String>();
  }

  static Future<String> getNewRecordingFilePath(String extension) async {
    if (extension == null) extension = "";
    Directory recordingsDirectory = await getRecordingsDirectory();
    DebugUtil.log("${Constant.LOG_TAG}", "getNewRecordingFilePath() recordingsDirectory: $recordingsDirectory exists: ${await recordingsDirectory.exists()}");
    DateTime now = DateTime.now();
    String filenamePathDate =
        "${minZeroes(4, now.year)}_${minZeroes(2, now.month)}_${minZeroes(2, now.day)}_${minZeroes(2, now.hour)}_${minZeroes(2, now.minute)}_${minZeroes(2, now.second)}";
    String newFilePath = path.join(recordingsDirectory.path, "${Constant.FILE_NAME_RECORDING_BASE}_$filenamePathDate$extension");
    DebugUtil.log("${Constant.LOG_TAG}", "getNewRecordingFilePath() newFilePath: $newFilePath");
    return newFilePath;
  }

  static String getNameByPath(String filePath, {bool withExtension = true}) {
    return filePath != null
        ? withExtension
            ? path.basename(filePath)
            : path.basenameWithoutExtension(filePath)
        : "";
  }

  static String getName(FileSystemEntity file, {bool withExtension = true}) {
    return getNameByPath(file.path, withExtension: withExtension);
  }

  static String getExtensionByPath(String filePath) {
    return filePath != null ? path.extension(filePath) : "";
  }

  static String getExtension(FileSystemEntity file) {
    return getExtensionByPath(file.path);
  }

  static String getPath(FileSystemEntity file) {
    return file != null ? path.dirname(file.path) : "";
  }

  static void sortByFilename(List<File> list, {bool sortedAscending = true}) {
    list.sort((file1, file2) {
      return sortedAscending
          ? getName(file1, withExtension: true).compareTo(getName(file2, withExtension: true))
          : getName(file2, withExtension: true).compareTo(getName(file1, withExtension: true));
    });
  }

  static minZeroes(int desiredValueLength, int value, {bool addFront: true}) {
    String valueStr = "$value";
    String finalValue = valueStr;
    while (finalValue.length < desiredValueLength) {
      finalValue = addFront ? "0$finalValue" : "${finalValue}0";
    }
    return finalValue;
  }
}
