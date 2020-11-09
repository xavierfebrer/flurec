import 'package:flurec/util/AudioRecordUtil.dart';
import 'package:flurec/util/Constant.dart';
import 'package:flurec/util/DebugUtil.dart';
import 'package:flurec/util/FileUtil.dart';
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
  RecordState recordState;
  String info;

  RecordStateInfo(this.recordState, this.info);
}

class _AudioRecordScreenState extends BaseScreenState<AudioRecordScreen> {
  RecordStateInfo recordStateInfo;
  FlutterSoundRecorder recorder;

  @override
  void initState() {
    super.initState();
    recordStateInfo = RecordStateInfo(RecordState.NOT_INIT, "Start Ok");
    recorder = FlutterSoundRecorder();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioRecordUtil.openAudioSession(recorder).then((result) {
        if (result) {
          DebugUtil.log("${Constant.LOG_TAG}", "openAudioSession OK");
          setState(() {
            recordStateInfo = RecordStateInfo(RecordState.INIT, "Start Ok");
          });
        } else {
          onFailedToOpenRecorder();
        }
        return result;
      });
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
    Widget button;
    if (recordStateInfo.recordState == RecordState.INIT) {
      button = getRecordButton();
    } else if (recordStateInfo.recordState == RecordState.RECORDING) {
      button = getStopButton();
    } else {
      button = Container();
    }
    Column column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [button, Text("${recordStateInfo.info}")],
    );
    return SafeArea(
      child: Container(
        alignment: Alignment.center,
        child: Center(
          child: column,
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    onStopSelected();
  }

  @override
  void dispose() {
    AudioRecordUtil.disposeRecorder(recorder);
    recorder = null;
    super.dispose();
  }

  Widget getRecordButton() {
    return Container(
      width: 100,
      height: 100,
      child: OutlinedButton(
        child: Icon(
          Icons.mic_rounded,
          size: 48.0,
          color: Constant.COLOR_PRIMARY,
        ),
        onPressed: () {
          onRecordSelected();
        },
      ),
    );
  }

  Widget getStopButton() {
    return Container(
      width: 100,
      height: 100,
      child: OutlinedButton(
        child: Icon(
          Icons.stop_rounded,
          size: 48.0,
          color: Constant.COLOR_ACCENT,
        ),
        onPressed: () {
          onStopSelected();
        },
      ),
    );
  }

  void onRecordSelected() async {
    DebugUtil.log("${Constant.LOG_TAG}", "onRecordSelected()");
    Codec codec = Codec.aacADTS;
    String extension = AudioRecordUtil.getExtensionForCodec(codec);
    if (extension == null) {
      onFailedToStartRecorder();
      return;
    }
    String filePath = await FileUtil.getNewRecordingFilePath(extension);
    bool result = await AudioRecordUtil.startRecorder(recorder, filePath, codec: codec);
    if (result) {
      DebugUtil.log("${Constant.LOG_TAG}", "startRecorder OK");
      setState(() {
        recordStateInfo = RecordStateInfo(RecordState.RECORDING, "Pressed record Ok");
      });
    } else {
      onFailedToStartRecorder();
    }
  }

  void onStopSelected() async {
    DebugUtil.log("${Constant.LOG_TAG}", "onStopSelected()");
    bool result = await AudioRecordUtil.stopRecorder(recorder);
    if (result) {
      DebugUtil.log("${Constant.LOG_TAG}", "stopRecorder OK");
      setState(() {
        recordStateInfo = RecordStateInfo(RecordState.INIT, "Pressed stop Ok");
      });
    } else {
      DebugUtil.log("${Constant.LOG_TAG}", "stopRecorder Fail");
      setState(() {
        recordStateInfo = RecordStateInfo(RecordState.INIT, "stopRecorder onFail");
      });
    }
  }

  void onFailedToOpenRecorder() async {
    DebugUtil.log("${Constant.LOG_TAG}", "onFailedToOpenRecorder()");
    setState(() {
      recordStateInfo = RecordStateInfo(RecordState.NOT_INIT, "openAudioSession onFail");
    });
  }

  void onFailedToStartRecorder() async {
    DebugUtil.log("${Constant.LOG_TAG}", "onFailedToStartRecorder()");
    setState(() {
      recordStateInfo = RecordStateInfo(RecordState.INIT, "startRecorder onFail");
    });
  }

  void onShowRecordingsSelected() async {
    onStopSelected();
    FlurecNavigator.getInstance().navigateToAudioList(context, false);
  }

  void onSettingsSelected() async {
    onStopSelected();
    FlurecNavigator.getInstance().navigateToSettings(context, false);
  }
}
