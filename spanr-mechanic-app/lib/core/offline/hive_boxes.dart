import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  static const jobsBox = 'jobs_cache';
  static const syncQueueBox = 'sync_queue';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(jobsBox);
    await Hive.openBox(syncQueueBox);
  }

  static Box get jobs => Hive.box(jobsBox);
  static Box get syncQueue => Hive.box(syncQueueBox);
}
