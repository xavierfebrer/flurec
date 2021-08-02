import 'package:flurec/util/constant.dart';
import 'package:flutter_sound/flutter_sound.dart';

class Settings {
  late bool autoPlayWhenVisitingDetail;
  late bool showDeleteSuccessInfo;
  late bool showRenameSuccessInfoFiles;
  late bool showConfirmationDeleteFiles;
  late bool showConfirmationRenameFiles;
  late Codec currentEncoderCodec;

  Settings({
    this.autoPlayWhenVisitingDetail = FlurecConstant.DEFAULT_AUTO_PLAY_WHEN_VISITING_DETAIL,
    this.showDeleteSuccessInfo = FlurecConstant.DEFAULT_SHOW_DELETE_SUCCESS_INFO,
    this.showRenameSuccessInfoFiles = FlurecConstant.DEFAULT_SHOW_RENAME_SUCCESS_INFO,
    this.showConfirmationDeleteFiles = FlurecConstant.DEFAULT_SHOW_CONFIRMATION_DELETE_FILES,
    this.showConfirmationRenameFiles = FlurecConstant.DEFAULT_SHOW_CONFIRMATION_RENAME_FILES,
    this.currentEncoderCodec = FlurecConstant.DEFAULT_CURRENT_ENCODER_CODEC_INDEX,
  });

  @override
  String toString() {
    return 'Settings{autoPlayWhenVisitingDetail: $autoPlayWhenVisitingDetail, showDeleteSuccessInfo: $showDeleteSuccessInfo, showRenameSuccessInfoFiles: $showRenameSuccessInfoFiles, showConfirmationDeleteFiles: $showConfirmationDeleteFiles, showConfirmationRenameFiles: $showConfirmationRenameFiles, currentEncoderCodec: $currentEncoderCodec}';
  }
}
