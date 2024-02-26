/// A placeholder class that represents an entity or model.
class SampleItem {
  const SampleItem({required this.name, required this.url, required this.boundingBoxes});

   final String name;
  final String url;
  final List<Map<String, double>> boundingBoxes;
}
