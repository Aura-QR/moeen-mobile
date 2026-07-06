import 'package:flutter/material.dart';

class ChoseApp extends StatelessWidget {
  const ChoseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the Download Extension page
                Navigator.pushNamed(context, '/download_extension');
              },
              child: const Text('Download Extension'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Open in Quetta page
                Navigator.pushNamed(context, '/open_in_quetta');
              },
              child: const Text('Open in Quetta'),
            ),
          ],
        ),
      ),
    );
  }
}