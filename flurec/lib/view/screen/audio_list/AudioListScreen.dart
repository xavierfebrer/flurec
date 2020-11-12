import 'dart:io';
import 'dart:math' as math;

import 'package:flurec/model/Settings.dart';
import 'package:flurec/util/AppUtil.dart';
import 'package:flurec/util/Constant.dart';
import 'package:flurec/util/FileUtil.dart';
import 'package:flurec/util/PopupUtil.dart';
import 'package:flurec/util/ShareUtil.dart';
import 'package:flurec/util/Util.dart';
import 'package:flurec/util/ViewUtil.dart';
import 'package:flurec/view/navigation/FlurecNavigator.dart';
import 'package:flurec/view/screen/BaseScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AudioListScreen extends BaseScreen {
  @override
  _AudioListScreenState createState() => _AudioListScreenState();
}

class _AudioListScreenState extends BaseScreenState<AudioListScreen> with TickerProviderStateMixin {
  List<File> files;
  List<String> selectedItems;
  FileSort fileSort;
  Settings settings;
  AnimationController iconRotationController;

  @override
  void initState() {
    super.initState();
    files = [];
    selectedItems = [];
    fileSort = FileSort.DateDescending;
    iconRotationController = AnimationController(
      duration: const Duration(milliseconds: 430),
      vsync: this,
    );
    iconRotationController.forward(from: 0.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future(() {
        if (selectedItems.isNotEmpty) {
          selectedItems.clear();
          onRefreshData();
          return false;
        }
        return true;
      }),
      child: Scaffold(
        backgroundColor: Constant.COLOR_PRIMARY_LIGHT,
        appBar: getAppBar(),
        body: getBody(),
      ),
    );
  }

  Widget getAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        "Audio List",
        style: TextStyle(color: Constant.COLOR_TEXT_LIGHT),
      ),
      automaticallyImplyLeading: true,
      centerTitle: false,
      iconTheme: IconThemeData(color: Constant.COLOR_PRIMARY_LIGHT),
      actions: getAppBarOptionWidgets(),
    );
  }

  List<Widget> getAppBarOptionWidgets() {
    List<Widget> appBarWidgets = [];
    if (selectedItems.isNotEmpty) {
      if(Constant.ENABLE_SHARE){
        appBarWidgets.add(
          IconButton(
            icon: Icon(
              Icons.share_rounded,
            ),
            onPressed: () {
              onShareSelected(context);
            },
          ),
        );
      }
      appBarWidgets.add(
        IconButton(
          icon: Icon(
            Icons.delete_rounded,
          ),
          onPressed: () {
            deleteSelectedItems(context);
          },
        ),
      );
    }
    appBarWidgets.add(
      getAppBarWidgetSort(context),
    );
    return appBarWidgets;
  }

  Widget getAppBarWidgetSort(BuildContext context) {
    Function() onSortPressed = () {
      iconRotationController.forward(from: 0.0);
      setState(() {
        if (fileSort.index < FileSort.values.length - 1) {
          fileSort = FileSort.values[fileSort.index + 1];
        } else {
          fileSort = FileSort.values[0];
        }
      });
    };
    if (fileSort == FileSort.DateDescending || fileSort == FileSort.DateAscending) {
      return RotationTransition(
        turns: Tween(begin: fileSort == FileSort.DateDescending ? 0.0 : 0.5, end: fileSort == FileSort.DateDescending ? 0.5 : 0.0).animate(iconRotationController),
        alignment: Alignment.center,
        child: IconButton(
          icon: Icon(
            Icons.date_range_rounded,
          ),
          onPressed: onSortPressed,
        ),
      );
    } else if (fileSort == FileSort.SizeDescending || fileSort == FileSort.SizeAscending) {
      return RotationTransition(
        turns: Tween(begin: fileSort == FileSort.SizeDescending ? 0.0 : 0.5, end: fileSort == FileSort.SizeDescending ? 0.5 : 0.0).animate(iconRotationController),
        alignment: Alignment.center,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(fileSort == FileSort.SizeDescending ? math.pi : 0.0),
          child: IconButton(
            icon: Icon(
              Icons.sort_rounded,
            ),
            onPressed: onSortPressed,
          ),
        ),
      );
    } else {
      return RotationTransition(
        turns: Tween(begin: fileSort == FileSort.NameDescending ? 0.0 : 0.5, end: fileSort == FileSort.NameDescending ? 0.5 : 0.0).animate(iconRotationController),
        alignment: Alignment.center,
        child: IconButton(
          icon: Icon(
            Icons.sort_by_alpha_rounded,
          ),
          onPressed: onSortPressed,
        ),
      );
    }
  }

  Widget getBody() {
    return SafeArea(
      child: Container(
        child: getBodyWithoutData(),
      ),
    );
  }

  Widget getBodyWithoutData() {
    return ViewUtil.getLoadingWidget(AppUtil.getSettingsModel(), onLoadData: (context, data, isInitialData) {
      settings = data;
      return getBodyWithData();
    });
  }

  Widget getBodyWithData() {
    return FutureBuilder<List<File>>(
      future: FileUtil.getRecordingsFiles(fileSort: fileSort),
      builder: (BuildContext context, AsyncSnapshot<List<File>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          onNewData(snapshot.data);
          return Scrollbar(
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Constant.COLOR_DIVIDER,
              ),
              itemCount: files.length,
              itemBuilder: (context, index) {
                bool isItemSelected = isSelectedItem(files[index].path);
                return ListTile(
                  title: Text(
                    FileUtil.getName(files[index], withExtension: true),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isItemSelected ? Constant.COLOR_TEXT_LIGHT : Constant.COLOR_TEXT_DARK,
                      fontSize: 18.0,
                    ),
                  ),
                  subtitle: Text(
                    getFileSubtitle(files[index]),
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isItemSelected ? Constant.COLOR_TEXT_LIGHT_2 : Constant.COLOR_TEXT_DARK_2,
                      fontStyle: FontStyle.italic,
                      fontSize: 12.0,
                    ),
                  ),
                  leading: selectedItems.isNotEmpty
                      ? IconButton(
                          icon: Icon(isItemSelected ? Icons.audiotrack : Icons.audiotrack_outlined),
                          onPressed: () async => await onItemSelected(files, index),
                        )
                      : null,
                  selected: isItemSelected,
                  selectedTileColor: Constant.COLOR_ACCENT,
                  onTap: () async {
                    await onItemSelected(files, index);
                  },
                  onLongPress: () async {
                    await onItemOptionsSelected(files, index);
                  },
                  isThreeLine: false,
                );
              },
            ),
          );
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    onRefreshData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> onItemSelected(List<File> files, int index) async {
    if (selectedItems.isNotEmpty) {
      selectItem(files[index].path);
    } else {
      FlurecNavigator.getInstance().navigateToAudioDetail(context, files[index].path, false, () async {
        await onRefreshData();
      });
    }
  }

  Future<void> onItemOptionsSelected(List<File> files, int index) async {
    if (selectedItems.isNotEmpty) {
      await selectItem(files[index].path);
    } else {
      await selectItem(files[index].path);
    }
  }

  bool isSelectedItem(String item) => selectedItems.contains(item);

  Future<void> selectItem(String item) async {
    if (!selectedItems.contains(item)) {
      selectedItems.add(item);
    } else {
      selectedItems.remove(item);
    }
    await onRefreshData();
  }

  Future<void> onShareSelected(BuildContext context) async {
    if (selectedItems.isNotEmpty) await ShareUtil.shareFiles(context, selectedItems);
  }

  Future<void> deleteSelectedItems(BuildContext context) async {
    List<String> fileNames = [];
    for (String filePath in selectedItems) {
      fileNames.add(FileUtil.getNameByPath(filePath, withExtension: true));
    }
    Function() onConfirmAction = () async {
      List<String> deletedFiles = await FileUtil.deleteFilesByPath(selectedItems);
      selectedItems.clear();
      await onRefreshData();
      if (settings.showDeleteSuccessInfo) {
        if (deletedFiles.isNotEmpty) {
          await PopupUtil.showPopup(context, "File${deletedFiles.length > 1 ? "s" : ""} deleted",
              "${deletedFiles.length} file${deletedFiles.length > 1 ? "s" : ""} ${deletedFiles.length > 1 ? "have" : "has"} been deleted.", "Ok", null,
              textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
              textStyleCancelButtonText: TextStyle(color: Theme.of(context).accentColor));
        }
      }
    };
    if (settings.showConfirmationDeleteFiles) {
      await PopupUtil.showPopup(
          context, "Delete items", "Are you sure you want to delete ${fileNames.length} file${fileNames.length > 1 ? "s" : ""}?", "Delete", "Cancel",
          textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
          textStyleCancelButtonText: TextStyle(color: Theme.of(context).accentColor),
          onConfirm: onConfirmAction);
    } else {
      await onConfirmAction();
    }
  }

  Future<void> onRefreshData() async {
    await onNewData(files);
    setState(() {});
  }

  Future<void> onNewData(List<File> newFileList) async {
    files = newFileList;
    List<String> newSelectedItems = [];
    for (File file in files) {
      String filePath = file.path;
      if (selectedItems.contains(filePath)) {
        newSelectedItems.add(filePath);
      }
    }
    selectedItems = newSelectedItems;
  }

  String getFileSubtitle(File file) {
    FileStat fileStat = FileUtil.getFileStat(file);
    String paddingStart = "  ";
    String paddingBetween = "   ";
    return "$paddingStart${Util.getFormattedSize(fileStat.size)}$paddingBetween${Util.getFormattedDateTime(
      fileStat.changed,
      separatorDate: "/",
      separatorTime: ":",
      separatorDateTime: " ",
      includeMS: false,
      replaceDateByTodayOrYesterday: true,
    )}";
  }
}
