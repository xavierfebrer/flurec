import 'package:auto_size_text/auto_size_text.dart';
import 'package:flurec/model/settings.dart';
import 'package:flurec/util/constant.dart';
import 'package:flurec/util/file_util.dart';
import 'package:flurec/util/settings_util.dart';
import 'package:flurec/util/view_util.dart';
import 'package:flurec/view/navigation/flurec_navigator.dart';
import 'package:flurec/view/screen/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:hack2s_flutter_util/util/audio_record_util.dart';
import 'package:hack2s_flutter_util/util/audio_util.dart';
import 'package:hack2s_flutter_util/util/debug_util.dart';
import 'package:hack2s_flutter_util/util/util.dart';

class AudioRecordScreen extends BaseScreen {
  @override
  _AudioRecordScreenState createState() => _AudioRecordScreenState();
}

enum RecordState {
  NOT_INIT,
  INIT,
  RECORDING,
}

class RecordStateInfo {
  RecordState state;
  String info;

  RecordStateInfo(this.state, this.info);
}

class _AudioRecordScreenState extends BaseScreenState<AudioRecordScreen> {
  late RecordStateInfo recordStateInfo;
  FlutterSoundRecorder? recorder;
  late Settings settings;

  @override
  void initState() {
    super.initState();
    recordStateInfo = RecordStateInfo(RecordState.NOT_INIT, "Start Ok");
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await initializeRecorder();
    });
  }

  @override
  Widget build(BuildContext context) {
    Hack2sDebugUtil.log("$FlurecConstant.LOG_TAG", "COLOR_PRIMARY_LIGHT ${FlurecConstant.COLOR_PRIMARY_LIGHT.toHex()}");
    Hack2sDebugUtil.log("$FlurecConstant.LOG_TAG", "COLOR_PRIMARY_DARK ${FlurecConstant.COLOR_PRIMARY_DARK.toHex()}");
    Hack2sDebugUtil.log("$FlurecConstant.LOG_TAG", "COLOR_SECONDARY_LIGHT ${FlurecConstant.COLOR_SECONDARY_LIGHT.toHex()}");
    Hack2sDebugUtil.log("$FlurecConstant.LOG_TAG", "COLOR_SECONDARY_DARK ${FlurecConstant.COLOR_SECONDARY_DARK.toHex()}");
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
    return AppBar(
      title: Text(
        FlurecConstant.APP_NAME,
        style: TextStyle(color: FlurecConstant.COLOR_TEXT_LIGHT),
      ),
      automaticallyImplyLeading: true,
      centerTitle: false,
      iconTheme: IconThemeData(color: FlurecConstant.COLOR_PRIMARY_LIGHT),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.list_rounded,
          ),
          onPressed: () {
            onShowRecordingsSelected();
          },
        ),
        IconButton(
          icon: Icon(
            Icons.settings,
          ),
          onPressed: () {
            onSettingsSelected();
          },
        ),
      ],
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
      return getBodyWithData();
    });
  }

  Widget getBodyWithData() {
    List<Widget> widgetsBody = [];
    widgetsBody.add(Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(FlurecConstant.PADDING_IN_VIEW, FlurecConstant.PADDING_IN_VIEW, FlurecConstant.PADDING_IN_VIEW, 50),
      child: AutoSizeText("${recordStateInfo.info}"),
    ));
    if (recordStateInfo.state == RecordState.INIT) {
      widgetsBody.add(getRecordButton());
    } else if (recordStateInfo.state == RecordState.RECORDING) {
      widgetsBody.add(getStopButton());
    }
    return Stack(
      children: widgetsBody,
    );
  }

  Widget getRecordButton() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(FlurecConstant.PADDING_IN_VIEW),
      child: SizedBox(
        width: FlurecConstant.SIZE_BUTTON_RECORD,
        height: FlurecConstant.SIZE_BUTTON_RECORD,
        child: OutlinedButton(
          style: FlurecViewUtil.getPlayerButtonStyle(false),
          child: Icon(
            Icons.mic_rounded,
            size: 96.0,
          ),
          onPressed: () async {
            Hack2sDebugUtil.log("${FlurecConstant.LOG_TAG}", "getRecordButton() onPressed");
            await onRecordSelected();
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
          width: FlurecConstant.SIZE_BUTTON_RECORD,
          height: FlurecConstant.SIZE_BUTTON_RECORD,
          child: OutlinedButton(
            style: FlurecViewUtil.getPlayerButtonStyle(true),
            child: Icon(
              Icons.stop_rounded,
              size: 96.0,
            ),
            onPressed: () async {
              Hack2sDebugUtil.log("${FlurecConstant.LOG_TAG}", "getRecordButton() onPressed");
              await onStopSelected();
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
    await initializeRecorder();
    await onRefreshData();
  }

  Future<void> onPause() async {
    await onStopSelected();
    await disposeRecorder();
  }

  @override
  void dispose() {
    disposeRecorder();
    super.dispose();
  }

  Future<bool> initializeRecorder() async {
    await disposeRecorder();
    recorder = FlutterSoundRecorder();
    if (await Hack2sAudioRecordUtil.openAudioSession(recorder!)) {
      setState(() {
        recordStateInfo = RecordStateInfo(RecordState.INIT, "");
      });
      return true;
    } else {
      await onFailedToOpenRecorder();
    }
    return false;
  }

  Future<bool> disposeRecorder() async {
    bool result = await Hack2sAudioRecordUtil.disposeRecorder(recorder);
    recorder = null;
    return result;
  }

  Future<void> onRecordSelected() async {
    Codec selectedCodec = settings.currentEncoderCodec;
    TargetPlatform platform = Theme.of(context).platform;
    var availablePlatformCodecs = await Hack2sAudioUtil.getAvailableEncoderCodecs(platform);
    String extension = Hack2sAudioUtil.getExtensionForCodec(selectedCodec);
    String filePath =
        await FlurecFileUtil.getNewRecordingFilePath(FlurecConstant.APP_NAME, FlurecConstant.FOLDER_NAME_RECORDINGS, FlurecConstant.FILE_NAME_RECORDING_BASE, extension);
    Hack2sDebugUtil.log("${FlurecConstant.LOG_TAG}", "onRecordSelected() 6");
    Hack2sDebugUtil.log("${FlurecConstant.LOG_TAG}",
        "onRecordSelected ${recorder!.isStopped} codec: $selectedCodec, extension: $extension, filePath: $filePath, availableCodecs ($platform): ${availablePlatformCodecs.join(", ")}");
    if (!(availablePlatformCodecs).contains(selectedCodec)) {
      onFailedToStartRecorder(
          "The selected codec: $selectedCodec, is not supported. Supported encoder codecs: ${availablePlatformCodecs.join(", ")}");
    } else {
      bool result = await Hack2sAudioRecordUtil.startRecorder(recorder!, filePath, codec: selectedCodec);
      if (result) {
        setState(() {
          recordStateInfo = RecordStateInfo(RecordState.RECORDING, "");
        });
      } else {
        onFailedToStartRecorder("Cannot record sound.");
      }
    }
  }

  Future<void> onStopSelected() async {
    bool result = await Hack2sAudioRecordUtil.stopRecorder(recorder!);
    if (result) {
      setState(() {
        recordStateInfo = RecordStateInfo(RecordState.INIT, "");
      });
    } else {
      setState(() {
        recordStateInfo = RecordStateInfo(RecordState.INIT, "Error");
      });
    }
  }

  Future<void> onFailedToOpenRecorder() async {
    setState(() {
      recordStateInfo = RecordStateInfo(RecordState.NOT_INIT, "Error");
    });
  }

  Future<void> onFailedToStartRecorder(String message) async {
    setState(() {
      recordStateInfo = RecordStateInfo(RecordState.INIT, message);
    });
  }

  Future<void> onShowRecordingsSelected() async {
    onStopSelected();
    FlurecNavigator.navigateToAudioList(context, false, () {
      onStopSelected();
      onRefreshData();
    });
  }

  Future<void> onSettingsSelected() async {
    onStopSelected();
    FlurecNavigator.navigateToSettings(context, false, () {
      onStopSelected();
      onRefreshData();
    });
  }

  Future<void> onRefreshData() async {
    setState(() {});
  }
}
