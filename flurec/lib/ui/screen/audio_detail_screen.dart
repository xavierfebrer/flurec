import 'package:auto_size_text/auto_size_text.dart';
import 'package:flurec/domain/model/settings.dart';
import 'package:flurec/presenter/audio_detail_state_presenter.dart';
import 'package:flurec/ui/model/play_state.dart';
import 'package:flurec/ui/model/play_state_info.dart';
import 'package:flurec/ui/navigation/flurec_navigator.dart';
import 'package:flurec/ui/view/audio_detail_view.dart';
import 'package:flurec/ui/view/state/audio_detail_view_state.dart';
import 'package:flurec/ui/view/util/view_util.dart';
import 'package:flurec/util/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:hack2s_flutter_util/util/audio_play_util.dart';
import 'package:hack2s_flutter_util/util/audio_util.dart';
import 'package:hack2s_flutter_util/util/file_util.dart';
import 'package:hack2s_flutter_util/util/popup_util.dart';
import 'package:hack2s_flutter_util/util/share_util.dart';
import 'package:hack2s_flutter_util/util/util.dart';
import 'package:hack2s_flutter_util/view/screen/base_screen.dart';
import 'package:hack2s_flutter_util/view/util/view_util.dart';

class AudioDetailScreen extends BaseScreen<AudioDetailView, AudioDetailViewState> implements AudioDetailView {
  final String filePath;

  AudioDetailScreen(this.filePath, {Key? key}) : super(key: key);

  @override
  AudioDetailScreenState createState() => AudioDetailScreenState(this, filePath);
}

class AudioDetailScreenState extends BaseScreenState<AudioDetailView, AudioDetailViewState, AudioDetailStatePresenter, AudioDetailScreen>
    implements AudioDetailViewState {
  AudioDetailScreenState(AudioDetailScreen screen, String filePath) : super(screen) {
    presenter = AudioDetailStatePresenterImpl(this.screen, this, filePath, Locator.getIt(), Locator.getIt());
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      child: Hack2sViewUtil.getBaseState(
        context,
        appBar: getAppBar(),
        body: getBody(),
      ),
      onWillPop: () {
        return Future(() {
          // TODO handle back press
          return true;
        });
      });

  AppBar getAppBar() {
    List<Widget> appBarWidgets = [];
    appBarWidgets.add(IconButton(
      icon: Icon(Icons.edit_rounded),
      onPressed: () async => await onEditSelected(context),
    ));
    appBarWidgets.add(IconButton(
      icon: Icon(Icons.delete_rounded),
      onPressed: () async => await onDeleteSelected(context),
    ));
    return AppBar(
      title: Text(FlurecConstant.TEXT_AUDIO_DETAIL),
      centerTitle: false,
      actions: appBarWidgets,
    );
  }

  Widget getBody() {
    return SafeArea(
      child: getBodyContent(),
    );
  }

  Widget getBodyContent() {
    List<Widget> widgetsBody = [];
    widgetsBody.add(Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.fromLTRB(FlurecConstant.PADDING_IN_VIEW, 60, FlurecConstant.PADDING_IN_VIEW, FlurecConstant.PADDING_IN_VIEW),
      child: AutoSizeText(
        "${Hack2sFileUtil.getNameByPath(presenter.filePath)}",
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
      child: AutoSizeText("${presenter.stateInfo.info}"),
    ));
    widgetsBody.add(Container(
      alignment: Alignment.bottomLeft,
      padding: EdgeInsets.all(FlurecConstant.PADDING_IN_VIEW),
      child: Text(
        "${Hack2sUtil.getFormattedFileSize(Hack2sFileUtil.getFileStatByFilePath(presenter.filePath).size)}",
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
          Hack2sFileUtil.getFileStatByFilePath(presenter.filePath).changed,
          separatorDate: "/",
          separatorTime: ":",
          separatorDateTime: " ",
          includeMS: false,
          replaceDateByToday: true,
          replaceDateByYesterday: true,
        )}",
        maxLines: 1,
        textAlign: TextAlign.end,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: FlurecConstant.COLOR_TEXT_DARK_2, fontStyle: FontStyle.italic),
      ),
    ));
    if (presenter.stateInfo.state == PlayState.INIT) {
      widgetsBody.add(FlurecViewUtil.getPlayStartButton(() => presenter.onPlayStartSelected()));
    } else if (presenter.stateInfo.state == PlayState.PLAYING) {
      widgetsBody.add(FlurecViewUtil.getPlayStopButton(() => presenter.onPlayStopSelected()));
    }
    return Stack(
      children: widgetsBody,
    );
  }

  Future<void> onEditSelected(BuildContext context) async {
    await presenter.onPlayStopSelected(); // TODO involve presenter, join 2 lines
    await onRenameStart(context); // TODO involve presenter, join 2 lines
  }

  Future<void> onDeleteSelected(BuildContext context) async {
    await onStopSelected();
    Function() onConfirmAction = () async {
      if (await Hack2sFileUtil.deleteFileByPath(presenter.filePath)) {
        Navigator.of(context).pop();
        if (presenter.settings.showDeleteSuccessInfo) {
          Hack2sPopupUtil.showPopup(
              context, "File deleted", "The file ${Hack2sFileUtil.getNameByPath(presenter.filePath)} has been deleted.", "Ok", null,
              textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
              textStyleCancelButtonText: TextStyle(color: Theme.of(context).colorScheme.secondary));
        }
      } else {
        Hack2sPopupUtil.showPopup(
            context, "Delete Error", "Failed to delete the file ${Hack2sFileUtil.getNameByPath(presenter.filePath)}.", "Ok", null,
            textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
            textStyleCancelButtonText: TextStyle(color: Theme.of(context).colorScheme.secondary));
      }
    };
    if (presenter.settings.showConfirmationDeleteFiles) {
      Hack2sPopupUtil.showPopup(
          context, "Delete file", "Do you want to delete the file ${Hack2sFileUtil.getNameByPath(presenter.filePath)}?", "Delete", "Cancel",
          textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
          textStyleCancelButtonText: TextStyle(color: Theme.of(context).colorScheme.secondary), onConfirm: () {
        onConfirmAction();
      });
    } else {
      onConfirmAction();
    }
  }

  Future<void> onRenameStart(BuildContext context) async {
    presenter.newEditNameText = "";
    await Hack2sPopupUtil.showPopupEdit(
        context, "Edit file name", "${Hack2sFileUtil.getNameByPath(presenter.filePath, withExtension: false)}", "Rename", "Cancel",
        textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
        textStyleCancelButtonText: TextStyle(color: Theme.of(context).colorScheme.secondary),
        onConfirm: () async {
          await onRenameConfirmed();
        },
        onCancel: () {},
        onChanged: (String newText) {
          presenter.newEditNameText = newText;
        });
  }

  Future<void> onRenameConfirmed() async {
    if (presenter.newEditNameText.isNotEmpty == true) {
      String parentPath = Hack2sFileUtil.getPathByFilePath(presenter.filePath);
      String newFilename = "$presenter.newEditNameText${Hack2sFileUtil.getExtensionByPath(presenter.filePath)}";
      String newFilePath = Hack2sFileUtil.joinByPathFilename(parentPath, newFilename);
      if (await Hack2sFileUtil.fileExists(newFilePath)) {
        Function() onRenameConfirm = () async {
          await Hack2sFileUtil.renameFileByFilePath(presenter.filePath, newFilePath);
        };
        if (presenter.settings.showConfirmationRenameFiles) {
          await Hack2sPopupUtil.showPopup(
              context, "Replace existing file?", "A file already exists with the name: $newFilename.", "Replace", "Cancel",
              textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
              textStyleCancelButtonText: TextStyle(color: Theme.of(context).colorScheme.secondary),
              onConfirm: onRenameConfirm);
        } else {
          await onRenameConfirm();
        }
      } else {
        bool renamed = await Hack2sFileUtil.renameFileByFilePath(presenter.filePath, newFilePath);
        if (renamed) {
          if (presenter.settings.showRenameSuccessInfoFiles) {
            await Hack2sPopupUtil.showPopup(
                context,
                "File ${renamed ? "" : "not"}renamed",
                "Renamed the file:\n${Hack2sFileUtil.getNameByPath(presenter.filePath)}\nto:\n${Hack2sFileUtil.getNameByPath(newFilePath)}",
                "Ok",
                null,
                textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
                textStyleCancelButtonText: TextStyle(color: Theme.of(context).colorScheme.secondary));
          }
          await changeFilePath(newFilePath);
        } else {
          await showFileNotRenamedPopup(context);
          await onRefreshAll();
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
  @override
  TargetPlatform getTargetPlatform() => Theme.of(context).platform;
}
