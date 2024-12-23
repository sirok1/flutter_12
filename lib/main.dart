import 'package:flutter/material.dart';
import 'package:flutter_4/page_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://obefbpwlzytuecqcljxq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9iZWZicHdsenl0dWVjcWNsanhxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5NjE3NjcsImV4cCI6MjA1MDUzNzc2N30.LqTr73TxOfsZWpdchiBef1bhSltEtxgPJBY9umXJWNs',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: PageWrapper(),
    );
  }
}
