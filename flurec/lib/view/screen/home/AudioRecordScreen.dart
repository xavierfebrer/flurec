import 'package:auto_size_text/auto_size_text.dart';
import 'package:flurec/util/Util.dart';
import 'package:flurec/model/Settings.dart';
import 'package:flurec/util/AppUtil.dart';
import 'package:flurec/util/AudioRecordUtil.dart';
import 'package:flurec/util/Constant.dart';
import 'package:flurec/util/DebugUtil.dart';
import 'package:flurec/util/FileUtil.dart';
import 'package:flurec/util/ViewUtil.dart';
import 'package:flurec/view/navigation/FlurecNavigator.dart';
import 'package:flurec/view/screen/BaseScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';

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
  RecordStateInfo recordStateInfo;
  FlutterSoundRecorder recorder;
  Settings settings;

  @override
  void initState() {
    super.initState();
    recordStateInfo = RecordStateInfo(RecordState.NOT_INIT, "Start Ok");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initializeRecorder();
    });
  }

  @override
  Widget build(BuildContext context) {
    DebugUtil.log("$Constant.LOG_TAG", "COLOR_PRIMARY_LIGHT ${Constant.COLOR_PRIMARY_LIGHT.toHex()}");
    DebugUtil.log("$Constant.LOG_TAG", "COLOR_PRIMARY_DARK ${Constant.COLOR_PRIMARY_DARK.toHex()}");
    DebugUtil.log("$Constant.LOG_TAG", "COLOR_ACCENT_LIGHT ${Constant.COLOR_ACCENT_LIGHT.toHex()}");
    DebugUtil.log("$Constant.LOG_TAG", "COLOR_ACCENT_DARK ${Constant.COLOR_ACCENT_DARK.toHex()}");
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
    return AppBar(
      title: Text(
        Constant.APP_NAME,
        style: TextStyle(color: Constant.COLOR_TEXT_LIGHT),
      ),
      automaticallyImplyLeading: true,
      centerTitle: false,
      iconTheme: IconThemeData(color: Constant.COLOR_PRIMARY_LIGHT),
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
    return ViewUtil.getLoadingWidget(AppUtil.getSettingsModel(), onLoadData: (context, data, isInitialData) {
      settings = data;
      return getBodyWithData();
    });
  }

  Widget getBodyWithData() {
    List<Widget> widgetsBody = [];
    widgetsBody.add(Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(Constant.PADDING_IN_VIEW, Constant.PADDING_IN_VIEW, Constant.PADDING_IN_VIEW, 50),
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
      padding: EdgeInsets.all(Constant.PADDING_IN_VIEW),
      child: SizedBox(
        width: Constant.SIZE_BUTTON_RECORD,
        height: Constant.SIZE_BUTTON_RECORD,
        child: OutlinedButton(
          style: ViewUtil.getPlayerButtonStyle(false),
          child: Icon(
            Icons.mic_rounded,
            size: 96.0,
          ),
          onPressed: () async {
            DebugUtil.log("${Constant.LOG_TAG}","getRecordButton() onPressed");
            await onRecordSelected();
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
          width: Constant.SIZE_BUTTON_RECORD,
          height: Constant.SIZE_BUTTON_RECORD,
          child: OutlinedButton(
            style: ViewUtil.getPlayerButtonStyle(true),
            child: Icon(
              Icons.stop_rounded,
              size: 96.0,
            ),
            onPressed: () async {
              DebugUtil.log("${Constant.LOG_TAG}","getRecordButton() onPressed");
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
    if (await AudioRecordUtil.openAudioSession(recorder)) {
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
    bool result = await AudioRecordUtil.disposeRecorder(recorder);
    recorder = null;
    return result;
  }

  Future<void> onRecordSelected() async {
    Codec selectedCodec = settings.currentEncoderCodec;
    TargetPlatform platform = Theme.of(context).platform;
    var availablePlatformCodecs = await AppUtil.getAvailableEncoderCodecs(platform);
    String extension = AppUtil.getExtensionForCodec(selectedCodec);
    String filePath = await FileUtil.getNewRecordingFilePath(extension);
    DebugUtil.log("${Constant.LOG_TAG}","onRecordSelected() 6");
    DebugUtil.log("${Constant.LOG_TAG}",
        "onRecordSelected ${recorder.isInited} codec: $selectedCodec, extension: $extension, filePath: $filePath, availableCodecs ($platform): ${availablePlatformCodecs.join(", ")}");
    if (extension == null) {
      onFailedToStartRecorder("File extension not available for selected codec: $selectedCodec");
    } else if (!(availablePlatformCodecs).contains(selectedCodec)) {
      onFailedToStartRecorder("The selected codec: $selectedCodec, is not supported. Supported encoder codecs: ${availablePlatformCodecs.join(", ")}");
    } else {
      bool result = await AudioRecordUtil.startRecorder(recorder, filePath, codec: selectedCodec);
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
    bool result = await AudioRecordUtil.stopRecorder(recorder);
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
    FlurecNavigator.getInstance().navigateToAudioList(context, false, () {
      onStopSelected();
      onRefreshData();
    });
  }

  Future<void> onSettingsSelected() async {
    onStopSelected();
    FlurecNavigator.getInstance().navigateToSettings(context, false, () {
      onStopSelected();
      onRefreshData();
    });
  }

  Future<void> onRefreshData() async {
    setState(() {});
  }
}
