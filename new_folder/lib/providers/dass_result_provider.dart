// lib/providers/dass_result_provider.dart

import 'package:flutter/foundation.dart';
import 'package:serene_sense/models/dass_21_model.dart';

/// A provider responsible for managing the user's history of DASS-21 test results.
///
/// This class holds a list of all completed [DassTestRecord] objects for the current
/// user session and notifies any listening widgets when the list changes.
class DassResultProvider with ChangeNotifier {
  final List<DassTestRecord> _results = [];

  /// A public getter to access the list of test records,
  /// always sorted with the most recent result first.
  List<DassTestRecord> get results =>
      _results..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  /// Adds a new, fully formed [DassTestRecord] to the user's history.
  ///
  /// This is typically called from the [Dass21Screen] after the test
  /// has been completed and the final record has been created.
  void addRecord(DassTestRecord record) {
    _results.add(record);
    
    // Notify any widgets that are 'watching' this provider to rebuild themselves.
    notifyListeners();
  }

  /// In the future, you could add methods here to clear the results on logout
  /// or fetch them from a persistent database.
  // void clearResults() {
  //   _results.clear();
  //   notifyListeners();
  // }
}