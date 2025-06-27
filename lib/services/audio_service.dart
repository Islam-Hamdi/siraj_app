import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/fanar_api.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final FanarApiService _fanarApi = FanarApiService();

  // Text-to-Speech for long text with chunking
  Future<void> playLongTts(String fullText) async {
    try {
      // Split text into manageable chunks
      final chunks = _splitTextIntoChunks(fullText);
      
      for (int i = 0; i < chunks.length; i++) {
        final chunk = chunks[i];
        
        // Get audio for this chunk
        final audioBytes = await _fanarApi.textToSpeech(text: chunk);
        
        // Save audio to temporary file
        final tempDir = await getTemporaryDirectory();
        final audioFile = File('${tempDir.path}/tts_chunk_${i}_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await audioFile.writeAsBytes(audioBytes);
        
        // Play audio and wait for completion
        await _audioPlayer.play(DeviceFileSource(audioFile.path));
        
        // Wait for audio to finish playing before playing next chunk
        await _waitForAudioCompletion();
        
        // Clean up temporary file
        await audioFile.delete();
      }
    } catch (e) {
      throw AudioServiceException('Long TTS playback failed: $e');
    }
  }

  // Split text into manageable chunks for TTS
  List<String> _splitTextIntoChunks(String text, {int maxChunkLength = 500}) {
    final chunks = <String>[];
    
    // Split by sentences first
    final sentences = text.split(RegExp(r'[.!?؟]'));
    
    String currentChunk = '';
    
    for (final sentence in sentences) {
      final trimmedSentence = sentence.trim();
      if (trimmedSentence.isEmpty) continue;
      
      // If adding this sentence would exceed the limit, save current chunk
      if (currentChunk.isNotEmpty && 
          (currentChunk.length + trimmedSentence.length + 1) > maxChunkLength) {
        chunks.add(currentChunk.trim());
        currentChunk = trimmedSentence;
      } else {
        if (currentChunk.isNotEmpty) {
          currentChunk += '. ';
        }
        currentChunk += trimmedSentence;
      }
    }
    
    // Add the last chunk if it's not empty
    if (currentChunk.trim().isNotEmpty) {
      chunks.add(currentChunk.trim());
    }
    
    // If no chunks were created (no sentence delimiters), split by words
    if (chunks.isEmpty) {
      chunks.addAll(_splitByWords(text, maxChunkLength));
    }
    
    return chunks;
  }

  // Split text by words if sentence splitting doesn't work
  List<String> _splitByWords(String text, int maxChunkLength) {
    final chunks = <String>[];
    final words = text.split(' ');
    
    String currentChunk = '';
    
    for (final word in words) {
      if (currentChunk.isNotEmpty && 
          (currentChunk.length + word.length + 1) > maxChunkLength) {
        chunks.add(currentChunk.trim());
        currentChunk = word;
      } else {
        if (currentChunk.isNotEmpty) {
          currentChunk += ' ';
        }
        currentChunk += word;
      }
    }
    
    if (currentChunk.trim().isNotEmpty) {
      chunks.add(currentChunk.trim());
    }
    
    return chunks;
  }

  // Wait for audio to finish playing
  Future<void> _waitForAudioCompletion() async {
    while (true) {
      final state = await _audioPlayer.getCurrentPosition();
      final duration = await _audioPlayer.getDuration();
      
      if (state == null || duration == null) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }
      
      if (state >= duration) {
        break;
      }
      
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Add a small delay to ensure audio has fully stopped
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // Text-to-Speech
  Future<void> playTextToSpeech(String text) async {
    try {
      final audioBytes = await _fanarApi.textToSpeech(text: text);
      
      // Save audio to temporary file
      final tempDir = await getTemporaryDirectory();
      final audioFile = File('${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await audioFile.writeAsBytes(audioBytes);
      
      // Play audio
      await _audioPlayer.play(DeviceFileSource(audioFile.path));
    } catch (e) {
      throw AudioServiceException('TTS playback failed: $e');
    }
  }

  // Speech-to-Text
  Future<String> recordAndTranscribe() async {
    try {
      // Request microphone permission
      final permission = await Permission.microphone.request();
      if (!permission.isGranted) {
        throw AudioServiceException('Microphone permission denied');
      }

      // Check if recording is supported
      if (!await _audioRecorder.hasPermission()) {
        throw AudioServiceException('Recording permission not granted');
      }

      // Start recording
      final tempDir = await getTemporaryDirectory();
      final recordingPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          bitRate: 128000,
        ),
        path: recordingPath,
      );

      // Wait for user to stop recording (this would be controlled by UI)
      await Future.delayed(const Duration(seconds: 5)); // Example duration
      
      // Stop recording
      await _audioRecorder.stop();
      
      // Transcribe audio
      final audioFile = File(recordingPath);
      if (!audioFile.existsSync()) {
        throw AudioServiceException('Recording file not found');
      }

      final transcriptionResult = await _fanarApi.speechToText(audioFile: audioFile);
      
      // Clean up temporary file
      await audioFile.delete();
      
      return transcriptionResult['text'] ?? '';
    } catch (e) {
      throw AudioServiceException('STT failed: $e');
    }
  }

  // Start recording (for manual control)
  Future<void> startRecording() async {
    try {
      final permission = await Permission.microphone.request();
      if (!permission.isGranted) {
        throw AudioServiceException('Microphone permission denied');
      }

      if (!await _audioRecorder.hasPermission()) {
        throw AudioServiceException('Recording permission not granted');
      }

      final tempDir = await getTemporaryDirectory();
      final recordingPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          bitRate: 128000,
        ),
        path: recordingPath,
      );
    } catch (e) {
      throw AudioServiceException('Failed to start recording: $e');
    }
  }

  // Stop recording and get transcription
  Future<String> stopRecordingAndTranscribe() async {
    try {
      final recordingPath = await _audioRecorder.stop();
      
      if (recordingPath == null) {
        throw AudioServiceException('No recording found');
      }

      final audioFile = File(recordingPath);
      if (!audioFile.existsSync()) {
        throw AudioServiceException('Recording file not found');
      }

      final transcriptionResult = await _fanarApi.speechToText(audioFile: audioFile);
      
      // Clean up temporary file
      await audioFile.delete();
      
      return transcriptionResult['text'] ?? '';
    } catch (e) {
      throw AudioServiceException('Failed to transcribe: $e');
    }
  }

  // Check if currently recording
  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }

  // Stop audio playback
  Future<void> stopPlayback() async {
    await _audioPlayer.stop();
  }

  // Dispose resources
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.dispose();
  }
}

class AudioServiceException implements Exception {
  final String message;
  
  AudioServiceException(this.message);
  
  @override
  String toString() => 'AudioServiceException: $message';
}

// Providers
final audioServiceProvider = Provider<AudioService>((ref) => AudioService());

// Audio state providers
final isRecordingProvider = StateProvider<bool>((ref) => false);
final isPlayingProvider = StateProvider<bool>((ref) => false);

