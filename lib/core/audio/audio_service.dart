import 'package:flutter/services.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();
  AudioService._internal();

  bool soundEnabled = true;
  bool musicEnabled = true;
  bool hapticsEnabled = true;

  void updateSettings({bool? sound, bool? music, bool? haptics}) {
    if (sound != null) soundEnabled = sound;
    if (music != null) musicEnabled = music;
    if (haptics != null) hapticsEnabled = haptics;
  }

  void playShoot() {
    if (hapticsEnabled) HapticFeedback.selectionClick();
  }

  void playPop() {
    if (hapticsEnabled) HapticFeedback.lightImpact();
  }

  void playCombo() {
    if (hapticsEnabled) HapticFeedback.mediumImpact();
  }

  void playWin() {
    if (hapticsEnabled) HapticFeedback.heavyImpact();
  }

  void playLose() {
    if (hapticsEnabled) HapticFeedback.vibrate();
  }

  void playButtonClick() {
    if (hapticsEnabled) HapticFeedback.selectionClick();
  }
}
