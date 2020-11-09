import 'dart:io';
import 'dart:math' as math;

import 'package:flurec/util/Constant.dart';
import 'package:flurec/util/DebugUtil.dart';
import 'package:flurec/util/FileUtil.dart';
import 'package:flurec/view/navigation/FlurecNavigator.dart';
import 'package:flurec/view/screen/BaseScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AudioListScreen extends BaseScreen {
  @override
  _AudioListScreenState createState() => _AudioListScreenState();
}

class _AudioListScreenState extends BaseScreenState<AudioListScreen> {
  List<String> selectedItems;
  bool sortedAscending;

  @override
  void initState() {
    super.initState();
    selectedItems = [];
    sortedAscending = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future(() {
        if (selectedItems.isNotEmpty) {
          selectedItems.clear();
          setState(() {});
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
        "Recordings",
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
      appBarWidgets.add(
        IconButton(
          icon: Icon(
            Icons.delete_rounded,
          ),
          onPressed: () {
            deleteSelectedItems();
          },
        ),
      );
    }
    appBarWidgets.add(
      Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationX(sortedAscending ? math.pi : 0.0),
        child: IconButton(
          icon: Icon(
            Icons.sort_rounded,
          ),
          onPressed: () {
            setState(() {
              sortedAscending = !sortedAscending;
            });
          },
        ),
      ),
    );
    return appBarWidgets;
  }

  Widget getBody() {
    return SafeArea(
      child: Container(
        child: FutureBuilder<List<File>>(
          future: FileUtil.getRecordingsFiles(sortedByFilename: true, sortedAscending: sortedAscending),
          builder: (BuildContext context, AsyncSnapshot<List<File>> snapshot) {
            DebugUtil.log("${Constant.LOG_TAG}", "getBody() snapshot.hasData: ${snapshot.hasData}");
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              List<File> files = snapshot.data;
              DebugUtil.log("${Constant.LOG_TAG}", "getBody() files: ${files}");
              return Scrollbar(
                child: ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                    color: Constant.COLOR_DIVIDER,
                  ),
                  itemCount: files.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(
                      FileUtil.getName(files[index], withExtension: true),
                      style: TextStyle(
                        color: isSelectedItem(files[index].path) ? Constant.COLOR_TEXT_LIGHT : Constant.COLOR_TEXT,
                      ),
                    ),
                    selected: isSelectedItem(files[index].path),
                    selectedTileColor: Constant.COLOR_ACCENT,
                    onTap: () {
                      onItemSelected(files, index);
                    },
                    onLongPress: () {
                      onItemOptionsSelected(files, index);
                    },
                    isThreeLine: false,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void onItemSelected(List<File> files, int index) {
    if (selectedItems.isNotEmpty) {
      selectItem(files[index].path);
    } else {
      FlurecNavigator.getInstance().navigateToAudioDetail(context, files[index].path, false);
    }
  }

  void onItemOptionsSelected(List<File> files, int index) {
    selectItem(files[index].path);
  }

  bool isSelectedItem(String item) => selectedItems.contains(item);

  void selectItem(String item) {
    if (!selectedItems.contains(item)) {
      selectedItems.add(item);
    } else {
      selectedItems.remove(item);
    }
    setState(() {});
  }

  void deleteSelectedItems() async {
    await FileUtil.deleteFilesByPath(selectedItems);
    selectedItems.clear();
    setState(() {});
  }
}
