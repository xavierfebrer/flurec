import 'dart:io';
import 'dart:math' as math;

import 'package:flurec/di/locator.dart';
import 'package:flurec/presenter/audio_list_state_presenter.dart.dart';
import 'package:flurec/ui/navigation/flurec_navigator.dart';
import 'package:flurec/ui/view/audio_list_view.dart';
import 'package:flurec/ui/view/state/audio_list_view_state.dart';
import 'package:flurec/ui/view/util/view_util.dart';
import 'package:flurec/util/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hack2s_flutter_util/util/file_util.dart';
import 'package:hack2s_flutter_util/view/screen/base_screen.dart';
import 'package:hack2s_flutter_util/view/util/view_util.dart';

class AudioListScreen extends BaseScreen<AudioListView, AudioListViewState> implements AudioListView {
  @override
  AudioListScreenState createState() => AudioListScreenState(this);
}

class AudioListScreenState extends BaseScreenState<AudioListView, AudioListViewState, AudioListStatePresenter, AudioListScreen>
    with TickerProviderStateMixin
    implements AudioListViewState {
  static const int DURATION_ANIMATION_ROTATION = 430;
  static const double ROTATION_FROM = 0.0;
  static const double ROTATION_NORMAL = 0.0;
  static const double ROTATION_INVERTED = math.pi;
  static const double TWEEN_NORMAL_BEGIN = 0.0;
  static const double TWEEN_NORMAL_END = 0.5;
  static const double TWEEN_INVERTED_BEGIN = 0.5;
  static const double TWEEN_INVERTED_END = 0.0;

  late AnimationController iconRotationController;

  AudioListScreenState(AudioListScreen screen) : super(screen) {
    presenter = AudioListStatePresenterImpl(this.screen, this, Locator.getIt());
    iconRotationController = AnimationController(
      duration: const Duration(milliseconds: DURATION_ANIMATION_ROTATION),
      vsync: this,
    );
    if (presenter.startInverted) startViewRotation();
  }

  @override
  Widget build(BuildContext context) => Hack2sViewUtil.getBaseState(
        context,
        appBar: getAppBar(),
        body: getBody(),
      );

  AppBar getAppBar() => Hack2sViewUtil.getAppBar(
        context,
        title: FlurecConstant.TEXT_AUDIO_LIST,
        actions: getAppBarOptionWidgets(),
      );

  List<Widget> getAppBarOptionWidgets() {
    List<Widget> appBarWidgets = [];
    appBarWidgets.add(getAppBarWidgetSort(context));
    return appBarWidgets;
  }

  Widget getAppBarWidgetSort(BuildContext context) {
    Function() onSortPressed = () => presenter.onSortSelected();
    if (presenter.fileSort == FileSort.DateDescending || presenter.fileSort == FileSort.DateAscending) {
      return RotationTransition(
        turns: Tween(
                begin: presenter.fileSort == FileSort.DateDescending ? TWEEN_NORMAL_BEGIN : TWEEN_INVERTED_BEGIN,
                end: presenter.fileSort == FileSort.DateDescending ? TWEEN_NORMAL_END : TWEEN_INVERTED_END)
            .animate(iconRotationController),
        alignment: Alignment.center,
        child: IconButton(
          icon: Icon(
            Icons.date_range_rounded,
          ),
          onPressed: onSortPressed,
        ),
      );
    } else if (presenter.fileSort == FileSort.SizeDescending || presenter.fileSort == FileSort.SizeAscending) {
      return RotationTransition(
        turns: Tween(
                begin: presenter.fileSort == FileSort.SizeDescending ? TWEEN_NORMAL_BEGIN : TWEEN_INVERTED_BEGIN,
                end: presenter.fileSort == FileSort.SizeDescending ? TWEEN_NORMAL_END : TWEEN_INVERTED_END)
            .animate(iconRotationController),
        alignment: Alignment.center,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(presenter.fileSort == FileSort.SizeDescending ? ROTATION_INVERTED : ROTATION_NORMAL),
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
        turns: Tween(
                begin: presenter.fileSort == FileSort.NameDescending ? TWEEN_NORMAL_BEGIN : TWEEN_INVERTED_BEGIN,
                end: presenter.fileSort == FileSort.NameDescending ? TWEEN_NORMAL_END : TWEEN_INVERTED_END)
            .animate(iconRotationController),
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

  Widget getBody() => SafeArea(child: getBodyContent());

  Widget getBodyContent() {
    return Scrollbar(
      child: ListView.separated(
        separatorBuilder: (context, index) => Hack2sViewUtil.getDefaultListDivider(context),
        itemCount: presenter.files.length,
        itemBuilder: (context, index) {
          File file = presenter.files[index];
          return ListTile(
            title: Text(
              Hack2sFileUtil.getName(file, withExtension: true),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: FlurecConstant.COLOR_TEXT_DARK,
                fontSize: 18.0,
              ),
            ),
            subtitle: Text(
              FlurecViewUtil.getFileSubtitle(file),
              maxLines: 1,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: FlurecConstant.COLOR_TEXT_DARK_2,
                fontStyle: FontStyle.italic,
                fontSize: 12.0,
              ),
            ),
            selectedTileColor: FlurecConstant.COLOR_SECONDARY,
            onTap: () async => await presenter.onItemSelected(file),
            isThreeLine: false,
          );
        },
      ),
    );
  }

  @override
  Future<void> goToAudioDetail(File file) async =>
      FlurecNavigator.navigateToAudioDetail(context, file.path, false, () async => await presenter.onAppResume());

  @override
  Future<void> startViewRotation() async {
    iconRotationController.forward(from: ROTATION_FROM);
  }
}
