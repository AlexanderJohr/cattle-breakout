import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import 'sample_item.dart';
import 'sample_item_details_view.dart';

/// Displays a list of SampleItems.
class SampleItemListView extends StatelessWidget {
  const SampleItemListView(
      {super.key,
      this.items = const [
        SampleItem(
            name: "Zaun Infrarot-Kamera",
            url: "http://172.31.40.92:8080/get_image?port=1",
            boundingBoxes: []),
        SampleItem(
            name: "Zaun Kamera",
            url: "http://172.31.40.92:8080/get_image?port=0",
            boundingBoxes: []),
        SampleItem(
            name: "Testbild Katze",
            url: "https://http.cat/images/100.jpg",
            boundingBoxes: [
              {
                "x": 310,
                "y": 50,
                "width": 300,
                "height": 300,
              }
            ]),
        SampleItem(
            name: "Testbild Kuh",
            url: "http://172.31.40.92:8080/test_image",
            boundingBoxes: [])
      ]});

  static const routeName = '/';

  final List<SampleItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'sampleItemListView',
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];

          return ListTile(
              title: Text(item.name),
              leading: const CircleAvatar(
                // Display the Flutter Logo image asset.
                foregroundImage: AssetImage('assets/images/flutter_logo.png'),
              ),
              onTap: () {
                // Navigate to the details page. If the user leaves and returns to
                // the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.restorablePushNamed(
                    context, SampleItemDetailsView.routeName, arguments: {
                  "url": item.url,
                  "boundingBoxes": item.boundingBoxes
                });
              });
        },
      ),
    );
  }
}
