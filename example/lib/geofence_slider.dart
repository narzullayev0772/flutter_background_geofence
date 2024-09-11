import 'package:flutter/material.dart';

class GeofenceSlider extends StatelessWidget {
  final String titlePrefix;
  final String? titleSuffix;
  final ValueNotifier<int> valueListenable;

  String? get _titleSuffix => (titleSuffix != null) ? " $titleSuffix" : null;

  const GeofenceSlider({
    super.key,
    required this.valueListenable,
    required this.titlePrefix,
    this.titleSuffix,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: valueListenable,
        builder: (context, value, child) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("$titlePrefix: ${value.round()}$_titleSuffix"),
            ),
            Slider.adaptive(
              value: value.toDouble(),
              label: value.round().toString(),
              max: 1000,
              divisions: 50,
              onChanged: (value) => valueListenable.value = value.round(),
            ),
          ],
        ),
      );
}
