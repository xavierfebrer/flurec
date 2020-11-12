import 'dart:io';

import 'package:flurec/util/Constant.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileUtil {
  static Future<List<String>> getFilenames(Directory fileDirectory) async {
    return (await getFiles(fileDirectory)).map((file) => getName(file)).toList();
  }

  static Future<List<File>> getFiles(Directory fileDirectory) async {
    fileDirectory = await createDirs(fileDirectory);
    if (await fileDirectory.exists()) {
      List<FileSystemEntity> files = await fileDirectory.list().toList();
      List<File> map = files.map((FileSystemEntity file) => File(file.path)).toList();
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
    return appBaseDir != null ? await createDirs(Directory(path.join(appBaseDir.path, Constant.APP_NAME))) ?? null : null;
  }

  static Future<Directory> getRecordingsDirectory() async {
    Directory appDirectory = await getAppDirectory();
    return appDirectory != null ? await createDirs(Directory(path.join(appDirectory.path, Constant.FOLDER_NAME_RECORDINGS))) ?? null : null;
  }

  static Future<List<File>> getRecordingsFiles({FileSort fileSort = FileSort.DateDescending}) async {
    Directory recordingsDirectory = await getRecordingsDirectory();
    List<File> list = await getFiles(recordingsDirectory) ?? List<String>();
    sort(list, fileSort: fileSort);
    return list;
  }

  static Future<List<String>> getRecordingsFilenames() async {
    Directory recordingsDirectory = await getRecordingsDirectory();
    List<String> list = await getFilenames(recordingsDirectory);
    return recordingsDirectory != null ? list : List<String>();
  }

  static Future<String> getNewRecordingFilePath(String extension) async {
    if (extension == null) extension = "";
    Directory recordingsDirectory = await getRecordingsDirectory();
    int index = 1;
    File file;
    while (file == null || await file.exists()) {
      file = File(path.join(recordingsDirectory.path, "${Constant.FILE_NAME_RECORDING_BASE}$index$extension"));
      if(!await file.exists()){
        break;
      }
      index++;
    }
    return file.path;
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

  static String getPathByFilePath(String filePath) {
    return filePath != null ? path.dirname(filePath) : "";
  }

  static String getPath(FileSystemEntity file) {
    return getPathByFilePath(file.path);
  }

  static FileStat getFileStat(FileSystemEntity file) {
    return file != null ? file.statSync() : null;
  }

  static FileStat getFileStatByFilePath(String filePath) {
    return getFileStat(File(filePath));
  }

  static Future<void> sortByFilePath(List<String> listFilePaths, {FileSort fileSort = FileSort.DateAscending}) async {
    sort(listFilePaths.map((filePath) => File(filePath)), fileSort: fileSort);
  }

  static void sort(List<File> list, {FileSort fileSort = FileSort.DateAscending}) {
    if (fileSort != null) {
      if (fileSort == FileSort.NameDescending || fileSort == FileSort.NameAscending) {
        list.sort((file1, file2) {
          return fileSort == FileSort.NameAscending
              ? getName(file1, withExtension: true).compareTo(getName(file2, withExtension: true))
              : getName(file2, withExtension: true).compareTo(getName(file1, withExtension: true));
        });
      } else if (fileSort == FileSort.DateDescending) {
        list.sort((file1, file2) {
          return getFileStat(file1).changed.isAfter(getFileStat(file2).changed) ? -1 : 1;
        });
      } else if (fileSort == FileSort.DateAscending) {
        list.sort((file1, file2) {
          return getFileStat(file1).changed.isBefore(getFileStat(file2).changed) ? -1 : 1;
        });
      } else if (fileSort == FileSort.SizeDescending) {
        list.sort((file1, file2) {
          return getFileStat(file1).size < getFileStat(file2).size ? -1 : 1;
        });
      } else if (fileSort == FileSort.SizeAscending) {
        list.sort((file1, file2) {
          return getFileStat(file1).size > getFileStat(file2).size ? -1 : 1;
        });
      }
    }
  }

  static Future<bool> fileExists(String newFilePath) async {
    return await File(newFilePath).exists();
  }

  static Future<bool> renameFileByFilePath(String existingFilePath, String newFilePath) async {
    File originFile = File(existingFilePath);
    if (await originFile.exists()) {
      File newTargetFile = await originFile.copy(newFilePath);
      bool copyCreated = await newTargetFile.exists();
      if (!copyCreated) return false;
      bool deletedOriginFile = await deleteFile(originFile);
      // TODO if(!deletedOriginFile) return false;
      return await newTargetFile.exists();
    }
    return false;
  }

  static String joinByPathFilename(String dirPath, String filename) {
    return path.join(dirPath, filename);
  }
}

enum FileSort {
  NameAscending,
  NameDescending,
  DateAscending,
  DateDescending,
  SizeAscending,
  SizeDescending,
}
