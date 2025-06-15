import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TxtCardParser {
  /// Parses a TXT asset at [assetPath] and returns a map of card keys to challenges.
  static Future<Map<String, String>> parseAsset(String assetPath) async {
    final content = await rootBundle.loadString(assetPath);
    final lines = content.split(RegExp(r'\r?\n'));
    final map = <String, String>{};
    String? currentKey;
    for (final line in lines) {
      final trimmed = line.trim();
      // Card key pattern: e.g. 'A♥', '10♠', etc.
      if (RegExp(r'^(?:10|[A2-9JQK])[♠♥♦♣]$').hasMatch(trimmed)) {
        currentKey = trimmed;
        map[currentKey] = '';
      } else if (currentKey != null && trimmed.isNotEmpty) {
        if (map[currentKey]!.isEmpty) {
          map[currentKey] = trimmed;
        } else {
          map[currentKey] = map[currentKey]! + '\n' + trimmed;
        }
      }
    }
    return map;
  }

  /// Parses a TXT file from either assets or a user-selected file path.
  static Future<Map<String, String>> parseDynamic() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedFile = prefs.getString('selectedFile');
    String content;
    if (selectedFile != null &&
        selectedFile.isNotEmpty &&
        File(selectedFile).existsSync()) {
      content = await File(selectedFile).readAsString();
    } else {
      content = await rootBundle
          .loadString('lib/assets/data_input/52Sample.txt');
    }
    final lines = content.split(RegExp(r'\r?\n'));
    final map = <String, String>{};
    String? currentKey;
    for (final line in lines) {
      final trimmed = line.trim();
      if (RegExp(r'^(?:10|[A2-9JQK])[♠♥♦♣]$').hasMatch(trimmed)) {
        currentKey = trimmed;
        map[currentKey] = '';
      } else if (currentKey != null && trimmed.isNotEmpty) {
        if (map[currentKey]!.isEmpty) {
          map[currentKey] = trimmed;
        } else {
          map[currentKey] = map[currentKey]! + '\n' + trimmed;
        }
      }
    }
    return map;
  }
}
