import 'package:flurec/util/Constant.dart';
import 'package:flutter_sound/flutter_sound.dart';

class Settings {
  bool autoPlayWhenVisitingDetail;
  bool showDeleteSuccessInfo;
  bool showRenameSuccessInfoFiles;
  bool showConfirmationDeleteFiles;
  bool showConfirmationRenameFiles;
  Codec currentEncoderCodec;

  Settings({
    bool autoPlayWhenVisitingDetail = Constant.DEFAULT_AUTO_PLAY_WHEN_VISITING_DETAIL,
    bool showDeleteSuccessInfo = Constant.DEFAULT_SHOW_DELETE_SUCCESS_INFO,
    bool showRenameSuccessInfoFiles = Constant.DEFAULT_SHOW_RENAME_SUCCESS_INFO,
    bool showConfirmationDeleteFiles = Constant.DEFAULT_SHOW_CONFIRMATION_DELETE_FILES,
    bool showConfirmationRenameFiles = Constant.DEFAULT_SHOW_CONFIRMATION_RENAME_FILES,
    Codec currentEncoderCodec = Constant.DEFAULT_CURRENT_ENCODER_CODEC_INDEX,
  }) {
    assert(autoPlayWhenVisitingDetail != null);
    assert(showDeleteSuccessInfo != null);
    assert(showRenameSuccessInfoFiles != null);
    assert(showConfirmationDeleteFiles != null);
    assert(showConfirmationRenameFiles != null);
    assert(currentEncoderCodec != null);
    this.autoPlayWhenVisitingDetail = autoPlayWhenVisitingDetail;
    this.showDeleteSuccessInfo = showDeleteSuccessInfo;
    this.showRenameSuccessInfoFiles = showRenameSuccessInfoFiles;
    this.showConfirmationDeleteFiles = showConfirmationDeleteFiles;
    this.showConfirmationRenameFiles = showConfirmationRenameFiles;
    this.currentEncoderCodec = currentEncoderCodec;
  }

  @override
  String toString() {
    return 'Settings{autoPlayWhenVisitingDetail: $autoPlayWhenVisitingDetail, showDeleteSuccessInfo: $showDeleteSuccessInfo, showRenameSuccessInfoFiles: $showRenameSuccessInfoFiles, showConfirmationDeleteFiles: $showConfirmationDeleteFiles, showConfirmationRenameFiles: $showConfirmationRenameFiles, currentEncoderCodec: $currentEncoderCodec}';
  }
}
