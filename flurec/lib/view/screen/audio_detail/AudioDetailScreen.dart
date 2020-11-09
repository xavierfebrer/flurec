import 'package:flurec/util/AudioPlayUtil.dart';
import 'package:flurec/util/Constant.dart';
import 'package:flurec/util/DebugUtil.dart';
import 'package:flurec/util/FileUtil.dart';
import 'package:flurec/view/navigation/FlurecNavigator.dart';
import 'package:flurec/view/screen/BaseScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';

class AudioDetailScreen extends BaseScreen {
  final String filePath;

  const AudioDetailScreen(this.filePath, {Key key}) : super(key: key);

  @override
  _AudioDetailScreenState createState() => _AudioDetailScreenState(filePath);
}

enum PlayState {
  NOT_INIT,
  INIT,
  PLAYING,
}

class PlayStateInfo {
  PlayState playState;
  String info;

  PlayStateInfo(this.playState, this.info);
}

class _AudioDetailScreenState extends BaseScreenState<AudioDetailScreen> {
  final String filePath;
  PlayStateInfo playStateInfo;
  FlutterSoundPlayer player;

  _AudioDetailScreenState(this.filePath) : super();

  @override
  void initState() {
    super.initState();
    playStateInfo = PlayStateInfo(PlayState.NOT_INIT, "Start Ok");
    player = FlutterSoundPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioPlayUtil.openAudioSession(player).then((result) {
        if (result) {
          DebugUtil.log("${Constant.LOG_TAG}", "openAudioSession OK");
          setState(() {
            playStateInfo = PlayStateInfo(PlayState.INIT, "Start Ok");
          });
        } else {
          onFailedToOpenPlayer();
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
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          onStopSelected();
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        "${FileUtil.getNameByPath(filePath)}",
        style: TextStyle(color: Constant.COLOR_TEXT_LIGHT),
      ),
      automaticallyImplyLeading: true,
      centerTitle: false,
      iconTheme: IconThemeData(color: Constant.COLOR_PRIMARY_LIGHT),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.share_rounded,
          ),
          onPressed: () {
            onShareSelected();
          },
        ),
      ],
    );
  }

  Widget getBody() {
    Widget button;
    if (playStateInfo.playState == PlayState.INIT) {
      button = getPlayButton();
    } else if (playStateInfo.playState == PlayState.PLAYING) {
      button = getStopButton();
    } else {
      button = Container();
    }
    Column column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [button, Text("${playStateInfo.info}")],
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
    AudioPlayUtil.disposePlayer(player);
    player = null;
    super.dispose();
  }

  Widget getPlayButton() {
    return Container(
      width: 100,
      height: 100,
      child: OutlinedButton(
        child: Icon(
          Icons.play_arrow_rounded,
          size: 48.0,
          color: Constant.COLOR_PRIMARY,
        ),
        onPressed: () {
          onPlaySelected();
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

  void onPlaySelected() async {
    DebugUtil.log("${Constant.LOG_TAG}", "onPlaySelected()");
    Codec codec = Codec.aacADTS;
    String extension = AudioPlayUtil.getExtensionForCodec(codec);
    if (extension == null) {
      onFailedToStartPlayer();
      return;
    }
    Duration duration = await AudioPlayUtil.startPlayer(player, filePath, codec: codec, onFinish: () {
      onStopSelected();
    });
    if (duration != null) {
      DebugUtil.log("${Constant.LOG_TAG}", "startPlayer OK");
      setState(() {
        playStateInfo = PlayStateInfo(PlayState.PLAYING, "Pressed play Ok");
      });
    } else {
      onFailedToStartPlayer();
    }
  }

  void onStopSelected() async {
    DebugUtil.log("${Constant.LOG_TAG}", "onStopSelected()");
    bool result = await AudioPlayUtil.stopPlayer(player);
    if (result) {
      DebugUtil.log("${Constant.LOG_TAG}", "stopPlayer OK");
      setState(() {
        playStateInfo = PlayStateInfo(PlayState.INIT, "Pressed stop Ok");
      });
    } else {
      DebugUtil.log("${Constant.LOG_TAG}", "stopPlayer Fail");
      setState(() {
        playStateInfo = PlayStateInfo(PlayState.INIT, "stopPlayer onFail");
      });
    }
  }

  void onFailedToOpenPlayer() async {
    DebugUtil.log("${Constant.LOG_TAG}", "onFailedToOpenPlayer()");
    setState(() {
      playStateInfo = PlayStateInfo(PlayState.NOT_INIT, "openAudioSession onFail");
    });
  }

  void onFailedToStartPlayer() async {
    DebugUtil.log("${Constant.LOG_TAG}", "onFailedToStartPlayer()");
    setState(() {
      playStateInfo = PlayStateInfo(PlayState.INIT, "startPlayer onFail");
    });
  }

  void onShareSelected() async {
    onStopSelected();
    // TODO
  }
}
