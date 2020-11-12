import 'package:auto_size_text/auto_size_text.dart';
import 'package:flurec/model/Settings.dart';
import 'package:flurec/util/AppUtil.dart';
import 'package:flurec/util/AudioPlayUtil.dart';
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
import 'package:flutter_sound/flutter_sound.dart';

class AudioDetailScreen extends BaseScreen {
  final String filePath;

  AudioDetailScreen(this.filePath, {Key key}) : super(key: key);

  @override
  _AudioDetailScreenState createState() => _AudioDetailScreenState(filePath);
}

enum PlayState {
  NOT_INIT,
  INIT,
  PLAYING,
}

class PlayStateInfo {
  PlayState state;
  String info;

  PlayStateInfo(this.state, this.info);
}

class _AudioDetailScreenState extends BaseScreenState<AudioDetailScreen> {
  final String filePath;
  PlayStateInfo playStateInfo;
  FlutterSoundPlayer player;
  String newEditNameText;
  Settings settings;
  bool playedFirstTime;

  _AudioDetailScreenState(this.filePath) : super();

  @override
  void initState() {
    super.initState();
    playStateInfo = PlayStateInfo(PlayState.NOT_INIT, "");
    player = FlutterSoundPlayer();
    newEditNameText = "";
    playedFirstTime = false;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initializePlayer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future(() {
        onStopSelected();
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
    List<Widget> appBarWidgets = [];
    appBarWidgets.add(IconButton(
      icon: Icon(
        Icons.edit_rounded,
      ),
      onPressed: () {
        onEditSelected(context);
      },
    ));
    if (Constant.ENABLE_SHARE) {
      appBarWidgets.add(IconButton(
        icon: Icon(
          Icons.share_rounded,
        ),
        onPressed: () {
          onShareSelected(context);
        },
      ));
    }
    appBarWidgets.add(IconButton(
      icon: Icon(
        Icons.delete_rounded,
      ),
      onPressed: () {
        onDeleteSelected(context);
      },
    ));
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          onStopSelected();
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        "Audio Detail",
        style: TextStyle(color: Constant.COLOR_TEXT_LIGHT),
      ),
      automaticallyImplyLeading: true,
      centerTitle: false,
      iconTheme: IconThemeData(color: Constant.COLOR_PRIMARY_LIGHT),
      actions: appBarWidgets,
    );
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
      if (!playedFirstTime && settings.autoPlayWhenVisitingDetail) {
        playedFirstTime = true;
        onPlaySelected();
      }
      return getBodyWithData();
    });
  }

  Widget getBodyWithData() {
    List<Widget> widgetsBody = [];
    widgetsBody.add(Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.fromLTRB(Constant.PADDING_IN_VIEW, 60, Constant.PADDING_IN_VIEW, Constant.PADDING_IN_VIEW),
      child: AutoSizeText(
        "${FileUtil.getNameByPath(filePath)}",
        style: TextStyle(
          fontSize: 26.0,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ));
    widgetsBody.add(Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(Constant.PADDING_IN_VIEW, Constant.PADDING_IN_VIEW, Constant.PADDING_IN_VIEW, 50),
      child: AutoSizeText("${playStateInfo.info}"),
    ));
    widgetsBody.add(Container(
      alignment: Alignment.bottomLeft,
      padding: EdgeInsets.all(Constant.PADDING_IN_VIEW),
      child: Text(
        "${Util.getFormattedSize(FileUtil.getFileStatByFilePath(filePath).size)}",
        maxLines: 1,
        textAlign: TextAlign.end,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Constant.COLOR_TEXT_DARK_2, fontStyle: FontStyle.italic),
      ),
    ));
    widgetsBody.add(Container(
      alignment: Alignment.bottomRight,
      padding: EdgeInsets.all(Constant.PADDING_IN_VIEW),
      child: Text(
        "${Util.getFormattedDateTime(
          FileUtil.getFileStatByFilePath(filePath).changed,
          separatorDate: "/",
          separatorTime: ":",
          separatorDateTime: " ",
          includeMS: false,
          replaceDateByTodayOrYesterday: true,
        )}",
        maxLines: 1,
        textAlign: TextAlign.end,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Constant.COLOR_TEXT_DARK_2, fontStyle: FontStyle.italic),
      ),
    ));
    if (playStateInfo.state == PlayState.INIT) {
      widgetsBody.add(getPlayButton());
    } else if (playStateInfo.state == PlayState.PLAYING) {
      widgetsBody.add(getStopButton());
    }
    if (playStateInfo.state == PlayState.INIT) {
      widgetsBody.add(getPlayButton());
    } else if (playStateInfo.state == PlayState.PLAYING) {
      widgetsBody.add(getStopButton());
    }
    return Stack(
      children: widgetsBody,
    );
  }

  Widget getPlayButton() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(Constant.PADDING_IN_VIEW),
      child: SizedBox(
        width: Constant.SIZE_BUTTON_PLAY,
        height: Constant.SIZE_BUTTON_PLAY,
        child: OutlinedButton(
          style: ViewUtil.getPlayerButtonStyle(false),
          child: Icon(
            Icons.play_arrow_rounded,
            size: 96.0,
          ),
          onPressed: () {
            onPlaySelected();
          },
        ),
      ),
    );
  }

  Widget getStopButton() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(Constant.PADDING_IN_VIEW),
        child: SizedBox(
          width: Constant.SIZE_BUTTON_PLAY,
          height: Constant.SIZE_BUTTON_PLAY,
          child: OutlinedButton(
            style: ViewUtil.getPlayerButtonStyle(true),
            child: Icon(
              Icons.stop_rounded,
              size: 96.0,
            ),
            onPressed: () {
              onStopSelected();
            },
          ),
        ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      onResume();
    } else {
      onPause();
    }
  }

  Future<void> onResume() async {
    await initializePlayer();
    await onRefreshData();
  }

  Future<void> onPause() async {
    await onStopSelected();
    await disposePlayer();
  }

  @override
  void dispose() {
    disposePlayer();
    super.dispose();
  }

  Future<bool> initializePlayer() async {
    await disposePlayer();
    player = FlutterSoundPlayer();
    if (await AudioPlayUtil.openAudioSession(player)) {
      setState(() {
        playStateInfo = PlayStateInfo(PlayState.INIT, "");
      });
      return true;
    } else {
      await onFailedToOpenPlayer();
    }
    return false;
  }

  Future<bool> disposePlayer() async {
    bool result = await AudioPlayUtil.disposePlayer(player);
    player = null;
    return result;
  }

  void onPlaySelected() async {
    TargetPlatform platform = Theme.of(context).platform;
    /*String extension = FileUtil.getExtensionByPath(filePath);
    List<Codec> codecsForExtension = await AppUtil.getCodecsForExtension(extension);*/
    List<Codec> availablePlatformCodecs = await AppUtil.getAvailableDecoderCodecs(platform);
    List<Codec> finalCodecs = List<Codec>();
    /*for(Codec codecForExtension in codecsForExtension){
      if(availablePlatformCodecs.contains(codecForExtension)){
        finalCodecs.add(codecForExtension);
      }
    }*/
    finalCodecs.addAll(availablePlatformCodecs);
    //DebugUtil.log(
    //    "${Constant.LOG_TAG}", "onPlaySelected extension:$extension, codecsForExtension: ${codecsForExtension.join(", ")}, availablePlatformCodecs: ${availablePlatformCodecs.join(", ")}, finalCodecs: ${finalCodecs.join(", ")}");
    Duration duration = await AudioPlayUtil.startPlayer(player, filePath, finalCodecs, onFinish: () {
      onStopSelected();
    });
    if (duration != null) {
      setState(() {
        playStateInfo = PlayStateInfo(PlayState.PLAYING, "");
      });
    } else {
      onFailedToStartPlayer("Failed to play sound.");
    }
  }

  Future<void> onStopSelected() async {
    bool result = await AudioPlayUtil.stopPlayer(player);
    if (result) {
      setState(() {
        playStateInfo = PlayStateInfo(PlayState.INIT, "");
      });
    } else {
      setState(() {
        playStateInfo = PlayStateInfo(PlayState.INIT, "Error");
      });
    }
  }

  Future<void> onFailedToOpenPlayer() async {
    setState(() {
      playStateInfo = PlayStateInfo(PlayState.NOT_INIT, "Error");
    });
  }

  Future<void> onFailedToStartPlayer(String message) async {
    setState(() {
      playStateInfo = PlayStateInfo(PlayState.INIT, message);
    });
  }

  Future<void> onEditSelected(BuildContext context) async {
    await onStopSelected();
    await onRenameStart(context);
  }

  Future<void> onShareSelected(BuildContext context) async {
    await onStopSelected();
    await ShareUtil.shareFile(context, this.filePath);
  }

  Future<void> onDeleteSelected(BuildContext context) async {
    await onStopSelected();
    Function() onConfirmAction = () async {
      if (await FileUtil.deleteFileByPath(filePath)) {
        Navigator.of(context).pop();
        if (settings.showDeleteSuccessInfo) {
          PopupUtil.showPopup(context, "File deleted", "The file ${FileUtil.getNameByPath(filePath)} has been deleted.", "Ok", null,
              textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
              textStyleCancelButtonText: TextStyle(color: Theme.of(context).accentColor));
        }
      } else {
        PopupUtil.showPopup(context, "Delete Error", "Failed to delete the file ${FileUtil.getNameByPath(filePath)}.", "Ok", null,
            textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark), textStyleCancelButtonText: TextStyle(color: Theme.of(context).accentColor));
      }
    };
    if (settings.showConfirmationDeleteFiles) {
      PopupUtil.showPopup(context, "Delete file", "Do you want to delete the file ${FileUtil.getNameByPath(filePath)}?", "Delete", "Cancel",
          textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
          textStyleCancelButtonText: TextStyle(color: Theme.of(context).accentColor), onConfirm: () {
        onConfirmAction();
      });
    } else {
      onConfirmAction();
    }
  }

  Future<void> onRenameStart(BuildContext context) async {
    newEditNameText = "";
    await PopupUtil.showPopupEdit(context, "Edit file name", "${FileUtil.getNameByPath(filePath, withExtension: false)}", "Rename", "Cancel",
        textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
        textStyleCancelButtonText: TextStyle(color: Theme.of(context).accentColor),
        onConfirm: () async {
          await onRenameConfirmed();
        },
        onCancel: () {},
        onChanged: (String newText) {
          newEditNameText = newText;
        });
  }

  Future<void> onRenameConfirmed() async {
    if (newEditNameText?.isNotEmpty == true) {
      String parentPath = FileUtil.getPathByFilePath(filePath);
      String newFilename = "$newEditNameText${FileUtil.getExtensionByPath(filePath)}";
      String newFilePath = FileUtil.joinByPathFilename(parentPath, newFilename);
      if (await FileUtil.fileExists(newFilePath)) {
        Function() onRenameConfirm = () async {
          await FileUtil.renameFileByFilePath(filePath, newFilePath);
        };
        if (settings.showConfirmationRenameFiles) {
          await PopupUtil.showPopup(context, "Replace existing file?", "A file already exists with the name: $newFilename.", "Replace", "Cancel",
              textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
              textStyleCancelButtonText: TextStyle(color: Theme.of(context).accentColor),
              onConfirm: onRenameConfirm);
        } else {
          await onRenameConfirm();
        }
      } else {
        bool renamed = await FileUtil.renameFileByFilePath(filePath, newFilePath);
        if (renamed) {
          if (settings.showRenameSuccessInfoFiles) {
            await PopupUtil.showPopup(context, "File ${renamed ? "" : "not"}renamed",
                "Renamed the file:\n${FileUtil.getNameByPath(filePath)}\nto:\n${FileUtil.getNameByPath(newFilePath)}", "Ok", null,
                textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
                textStyleCancelButtonText: TextStyle(color: Theme.of(context).accentColor));
          }
          await changeFilePath(newFilePath);
        } else {
          await showFileNotRenamedPopup(context);
          await onRefreshData();
        }
      }
    } else {
      await showFileNotRenamedPopup(context);
    }
  }

  Future<void> showFileNotRenamedPopup(BuildContext context) async {
    await PopupUtil.showPopup(context, "File not renamed", "In order to rename the file, a valid and different name must be provided.", "Ok", null,
        textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark), textStyleCancelButtonText: TextStyle(color: Theme.of(context).accentColor));
  }

  Future<void> changeFilePath(String newFilePath) async {
    FlurecNavigator.getInstance().navigateToAudioDetailReplaced(context, newFilePath);
  }

  Future<void> onRefreshData() async {
    setState(() {});
  }
}
