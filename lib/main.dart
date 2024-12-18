import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';

Future<void> main() async {
  await dotenv.load(fileName: 'lib/.env.production');
  await Supabase.initialize(
      url: dotenv.get('PROJECT_URL'),
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlybGNrcHJodWt2bnlpcmppZmFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA3OTQ0MDAsImV4cCI6MjA0NjM3MDQwMH0.urOlStI0xrTNUFZOxqOgkSN1bBhxwjTqd8_mWZxopnk');
  runApp(const MyApp());
}
