import 'package:flutter/material.dart';

class MediaLibrary extends StatelessWidget {
  const MediaLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Exemplo de Live', 'assets/images/example.jpg', Icons.live_tv_outlined),
      ('Logo principal', 'assets/branding/logo.svg', Icons.branding_watermark_outlined),
      ('Logo reduzida', 'assets/branding/logo-small.svg', Icons.crop_free_outlined),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca de mídia')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.upload_file_outlined),
        label: const Text('Adicionar mídia'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 320,
          mainAxisExtent: 250,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSvg = item.$2.endsWith('.svg');
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    padding: const EdgeInsets.all(16),
                    child: isSvg
                        ? Center(child: Icon(item.$3, size: 54))
                        : Image.asset(item.$2, fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Row(
                    children: [
                      Expanded(child: Text(item.$1, style: Theme.of(context).textTheme.titleMedium)),
                      const Icon(Icons.more_horiz),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
