import 'package:auto_size_text/auto_size_text.dart';
import 'package:flurec/model/settings.dart';
import 'package:flurec/util/constant.dart';
import 'package:flurec/util/settings_util.dart';
import 'package:flurec/util/view_util.dart';
import 'package:flurec/view/navigation/flurec_navigator.dart';
import 'package:flurec/view/screen/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:hack2s_flutter_util/util/audio_play_util.dart';
import 'package:hack2s_flutter_util/util/audio_util.dart';
import 'package:hack2s_flutter_util/util/file_util.dart';
import 'package:hack2s_flutter_util/util/popup_util.dart';
import 'package:hack2s_flutter_util/util/share_util.dart';
import 'package:hack2s_flutter_util/util/util.dart';

class AudioDetailScreen extends BaseScreen {
  final String filePath;

  AudioDetailScreen(this.filePath, {Key? key}) : super(key: key);

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
  late PlayStateInfo playStateInfo;
  FlutterSoundPlayer? player;
  late String newEditNameText;
  late Settings settings;
  late bool playedFirstTime;

  _AudioDetailScreenState(this.filePath) : super();

  @override
  void initState() {
    super.initState();
    playStateInfo = PlayStateInfo(PlayState.NOT_INIT, "");
    player = FlutterSoundPlayer();
    newEditNameText = "";
    playedFirstTime = false;
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
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
        backgroundColor: FlurecConstant.COLOR_PRIMARY_LIGHT,
        appBar: getAppBar(),
        body: getBody(),
      ),
    );
  }

  AppBar getAppBar() {
    List<Widget> appBarWidgets = [];
    appBarWidgets.add(IconButton(
      icon: Icon(
        Icons.edit_rounded,
      ),
      onPressed: () {
        onEditSelected(context);
      },
    ));
    if (FlurecConstant.ENABLE_SHARE) {
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
        style: TextStyle(color: FlurecConstant.COLOR_TEXT_LIGHT),
      ),
      automaticallyImplyLeading: true,
      centerTitle: false,
      iconTheme: IconThemeData(color: FlurecConstant.COLOR_PRIMARY_LIGHT),
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
    return FlurecViewUtil.getLoadingWidget<Settings>(FlurecSettingsUtil.getSettingsModel(), onLoadData: (context, data, isInitialData) {
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
      padding: EdgeInsets.fromLTRB(FlurecConstant.PADDING_IN_VIEW, 60, FlurecConstant.PADDING_IN_VIEW, FlurecConstant.PADDING_IN_VIEW),
      child: AutoSizeText(
        "${Hack2sFileUtil.getNameByPath(filePath)}",
        style: TextStyle(
          fontSize: 26.0,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ));
    widgetsBody.add(Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(FlurecConstant.PADDING_IN_VIEW, FlurecConstant.PADDING_IN_VIEW, FlurecConstant.PADDING_IN_VIEW, 50),
      child: AutoSizeText("${playStateInfo.info}"),
    ));
    widgetsBody.add(Container(
      alignment: Alignment.bottomLeft,
      padding: EdgeInsets.all(FlurecConstant.PADDING_IN_VIEW),
      child: Text(
        "${Hack2sUtil.getFormattedSize(Hack2sFileUtil.getFileStatByFilePath(filePath).size)}",
        maxLines: 1,
        textAlign: TextAlign.end,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: FlurecConstant.COLOR_TEXT_DARK_2, fontStyle: FontStyle.italic),
      ),
    ));
    widgetsBody.add(Container(
      alignment: Alignment.bottomRight,
      padding: EdgeInsets.all(FlurecConstant.PADDING_IN_VIEW),
      child: Text(
        "${Hack2sUtil.getFormattedDateTime(
          Hack2sFileUtil.getFileStatByFilePath(filePath).changed,
          separatorDate: "/",
          separatorTime: ":",
          separatorDateTime: " ",
          includeMS: false,
          replaceDateByTodayOrYesterday: true,
        )}",
        maxLines: 1,
        textAlign: TextAlign.end,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: FlurecConstant.COLOR_TEXT_DARK_2, fontStyle: FontStyle.italic),
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
      padding: EdgeInsets.all(FlurecConstant.PADDING_IN_VIEW),
      child: SizedBox(
        width: FlurecConstant.SIZE_BUTTON_PLAY,
        height: FlurecConstant.SIZE_BUTTON_PLAY,
        child: OutlinedButton(
          style: FlurecViewUtil.getPlayerButtonStyle(false),
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
        padding: EdgeInsets.all(FlurecConstant.PADDING_IN_VIEW),
        child: SizedBox(
          width: FlurecConstant.SIZE_BUTTON_PLAY,
          height: FlurecConstant.SIZE_BUTTON_PLAY,
          child: OutlinedButton(
            style: FlurecViewUtil.getPlayerButtonStyle(true),
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
    if (await Hack2sAudioPlayUtil.openAudioSession(player!)) {
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
    bool result = await Hack2sAudioPlayUtil.disposePlayer(player);
    player = null;
    return result;
  }

  void onPlaySelected() async {
    TargetPlatform platform = Theme.of(context).platform;
    /*String extension = FileUtil.getExtensionByPath(filePath);
    List<Codec> codecsForExtension = await Hack2sAppUtil.getCodecsForExtension(extension);*/
    List<Codec> availablePlatformCodecs = await Hack2sAudioUtil.getAvailableDecoderCodecs(platform);
    List<Codec> finalCodecs = [];
    /*for(Codec codecForExtension in codecsForExtension){
      if(availablePlatformCodecs.contains(codecForExtension)){
        finalCodecs.add(codecForExtension);
      }
    }*/
    finalCodecs.addAll(availablePlatformCodecs);
    //DebugUtil.log(
    //    "${Constant.LOG_TAG}", "onPlaySelected extension:$extension, codecsForExtension: ${codecsForExtension.join(", ")}, availablePlatformCodecs: ${availablePlatformCodecs.join(", ")}, finalCodecs: ${finalCodecs.join(", ")}");
    Duration? duration = await Hack2sAudioPlayUtil.startPlayer(player!, filePath, finalCodecs, onFinish: () {
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
    bool result = await Hack2sAudioPlayUtil.stopPlayer(player!);
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
    await Hack2sShareUtil.shareFile(context, this.filePath);
  }

  Future<void> onDeleteSelected(BuildContext context) async {
    await onStopSelected();
    Function() onConfirmAction = () async {
      if (await Hack2sFileUtil.deleteFileByPath(filePath)) {
        Navigator.of(context).pop();
        if (settings.showDeleteSuccessInfo) {
          Hack2sPopupUtil.showPopup(context, "File deleted", "The file ${Hack2sFileUtil.getNameByPath(filePath)} has been deleted.", "Ok", null,
              textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
              textStyleCancelButtonText: TextStyle(color: Theme.of(context).colorScheme.secondary));
        }
      } else {
        Hack2sPopupUtil.showPopup(context, "Delete Error", "Failed to delete the file ${Hack2sFileUtil.getNameByPath(filePath)}.", "Ok", null,
            textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
            textStyleCancelButtonText: TextStyle(color: Theme.of(context).colorScheme.secondary));
      }
    };
    if (settings.showConfirmationDeleteFiles) {
      Hack2sPopupUtil.showPopup(
          context, "Delete file", "Do you want to delete the file ${Hack2sFileUtil.getNameByPath(filePath)}?", "Delete", "Cancel",
          textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
          textStyleCancelButtonText: TextStyle(color: Theme.of(context).colorScheme.secondary), onConfirm: () {
        onConfirmAction();
      });
    } else {
      onConfirmAction();
    }
  }

  Future<void> onRenameStart(BuildContext context) async {
    newEditNameText = "";
    await Hack2sPopupUtil.showPopupEdit(
        context, "Edit file name", "${Hack2sFileUtil.getNameByPath(filePath, withExtension: false)}", "Rename", "Cancel",
        textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
        textStyleCancelButtonText: TextStyle(color: Theme.of(context).colorScheme.secondary),
        onConfirm: () async {
          await onRenameConfirmed();
        },
        onCancel: () {},
        onChanged: (String newText) {
          newEditNameText = newText;
        });
  }

  Future<void> onRenameConfirmed() async {
    if (newEditNameText.isNotEmpty == true) {
      String parentPath = Hack2sFileUtil.getPathByFilePath(filePath);
      String newFilename = "$newEditNameText${Hack2sFileUtil.getExtensionByPath(filePath)}";
      String newFilePath = Hack2sFileUtil.joinByPathFilename(parentPath, newFilename);
      if (await Hack2sFileUtil.fileExists(newFilePath)) {
        Function() onRenameConfirm = () async {
          await Hack2sFileUtil.renameFileByFilePath(filePath, newFilePath);
        };
        if (settings.showConfirmationRenameFiles) {
          await Hack2sPopupUtil.showPopup(
              context, "Replace existing file?", "A file already exists with the name: $newFilename.", "Replace", "Cancel",
              textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
              textStyleCancelButtonText: TextStyle(color: Theme.of(context).colorScheme.secondary),
              onConfirm: onRenameConfirm);
        } else {
          await onRenameConfirm();
        }
      } else {
        bool renamed = await Hack2sFileUtil.renameFileByFilePath(filePath, newFilePath);
        if (renamed) {
          if (settings.showRenameSuccessInfoFiles) {
            await Hack2sPopupUtil.showPopup(context, "File ${renamed ? "" : "not"}renamed",
                "Renamed the file:\n${Hack2sFileUtil.getNameByPath(filePath)}\nto:\n${Hack2sFileUtil.getNameByPath(newFilePath)}", "Ok", null,
                textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
                textStyleCancelButtonText: TextStyle(color: Theme.of(context).colorScheme.secondary));
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
    await Hack2sPopupUtil.showPopup(
        context, "File not renamed", "In order to rename the file, a valid and different name must be provided.", "Ok", null,
        textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
        textStyleCancelButtonText: TextStyle(color: Theme.of(context).colorScheme.secondary));
  }

  Future<void> changeFilePath(String newFilePath) async {
    FlurecNavigator.navigateToAudioDetailReplaced(context, newFilePath);
  }

  Future<void> onRefreshData() async {
    setState(() {});
  }
}
