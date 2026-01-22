import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

/// Service for playing tasbih counting sounds
class TasbihSoundService {
  static final TasbihSoundService _instance = TasbihSoundService._internal();
  factory TasbihSoundService() => _instance;
  TasbihSoundService._internal();

  AudioPlayer? _clickPlayer;
  AudioPlayer? _completePlayer;
  bool _isInitialized = false;
  String? _clickSoundPath;
  String? _completeSoundPath;

  /// Initialize the audio players with generated beep sounds
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get temp directory
      final tempDir = await getTemporaryDirectory();

      // Generate and save click sound
      final clickWav = _generateBeepWav(frequency: 880, durationMs: 30, volume: 0.4);
      _clickSoundPath = '${tempDir.path}/tasbih_click.wav';
      await File(_clickSoundPath!).writeAsBytes(clickWav);

      // Generate and save completion sound
      final completeWav = _generateBeepWav(frequency: 1320, durationMs: 100, volume: 0.5);
      _completeSoundPath = '${tempDir.path}/tasbih_complete.wav';
      await File(_completeSoundPath!).writeAsBytes(completeWav);

      // Initialize players
      _clickPlayer = AudioPlayer();
      _completePlayer = AudioPlayer();

      await _clickPlayer?.setFilePath(_clickSoundPath!);
      await _completePlayer?.setFilePath(_completeSoundPath!);

      _isInitialized = true;
    } catch (e) {
      // Silently fail - sound is optional
      _isInitialized = false;
    }
  }

  /// Generate a simple sine wave beep as WAV data
  Uint8List _generateBeepWav({
    required int frequency,
    required int durationMs,
    required double volume,
  }) {
    const sampleRate = 44100;
    final numSamples = (sampleRate * durationMs / 1000).round();
    final samples = Int16List(numSamples);

    // Generate sine wave with envelope
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;

      // Apply envelope (fade in/out) to prevent clicks
      double envelope = 1.0;
      final fadeLength = (numSamples * 0.15).round();
      if (i < fadeLength) {
        envelope = i / fadeLength;
      } else if (i > numSamples - fadeLength) {
        envelope = (numSamples - i) / fadeLength;
      }

      final sample = (32767 * volume * envelope *
              math.sin(2 * math.pi * frequency * t))
          .round();
      samples[i] = sample.clamp(-32767, 32767);
    }

    return _buildWavFile(samples, sampleRate);
  }

  Uint8List _buildWavFile(Int16List samples, int sampleRate) {
    final numSamples = samples.length;
    final dataSize = numSamples * 2; // 16-bit samples
    final fileSize = 44 + dataSize;

    final buffer = ByteData(fileSize);
    int offset = 0;

    // RIFF header
    buffer.setUint8(offset++, 0x52); // 'R'
    buffer.setUint8(offset++, 0x49); // 'I'
    buffer.setUint8(offset++, 0x46); // 'F'
    buffer.setUint8(offset++, 0x46); // 'F'
    buffer.setUint32(offset, fileSize - 8, Endian.little);
    offset += 4;
    buffer.setUint8(offset++, 0x57); // 'W'
    buffer.setUint8(offset++, 0x41); // 'A'
    buffer.setUint8(offset++, 0x56); // 'V'
    buffer.setUint8(offset++, 0x45); // 'E'

    // fmt chunk
    buffer.setUint8(offset++, 0x66); // 'f'
    buffer.setUint8(offset++, 0x6D); // 'm'
    buffer.setUint8(offset++, 0x74); // 't'
    buffer.setUint8(offset++, 0x20); // ' '
    buffer.setUint32(offset, 16, Endian.little); // Chunk size
    offset += 4;
    buffer.setUint16(offset, 1, Endian.little); // Audio format (PCM)
    offset += 2;
    buffer.setUint16(offset, 1, Endian.little); // Num channels (mono)
    offset += 2;
    buffer.setUint32(offset, sampleRate, Endian.little); // Sample rate
    offset += 4;
    buffer.setUint32(offset, sampleRate * 2, Endian.little); // Byte rate
    offset += 4;
    buffer.setUint16(offset, 2, Endian.little); // Block align
    offset += 2;
    buffer.setUint16(offset, 16, Endian.little); // Bits per sample
    offset += 2;

    // data chunk
    buffer.setUint8(offset++, 0x64); // 'd'
    buffer.setUint8(offset++, 0x61); // 'a'
    buffer.setUint8(offset++, 0x74); // 't'
    buffer.setUint8(offset++, 0x61); // 'a'
    buffer.setUint32(offset, dataSize, Endian.little);
    offset += 4;

    // Sample data
    for (int i = 0; i < numSamples; i++) {
      buffer.setInt16(offset, samples[i], Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  /// Play click sound for each count
  Future<void> playClickSound() async {
    if (!_isInitialized || _clickPlayer == null) {
      // Fallback to system sound
      await SystemSound.play(SystemSoundType.click);
      return;
    }

    try {
      await _clickPlayer!.seek(Duration.zero);
      await _clickPlayer!.play();
    } catch (e) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /// Play completion sound when loop finishes
  Future<void> playLoopCompleteSound() async {
    if (!_isInitialized || _completePlayer == null) {
      await SystemSound.play(SystemSoundType.alert);
      return;
    }

    try {
      await _completePlayer!.seek(Duration.zero);
      await _completePlayer!.play();
    } catch (e) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  /// Dispose audio players
  void dispose() {
    _clickPlayer?.dispose();
    _completePlayer?.dispose();
    _clickPlayer = null;
    _completePlayer = null;
    _isInitialized = false;
  }
}
