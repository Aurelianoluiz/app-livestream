import 'package:flutter/material.dart';

class MediaLibrary extends StatelessWidget {
  const MediaLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Exemplo de Live', 'assets/images/example.jpg', 'Foto/preview principal'),
      ('Exemplo — Cenas', 'assets/illustrations/example-cenas.svg', 'Cena com câmera, produto e oferta'),
      ('Exemplo — Produtos', 'assets/illustrations/example-produtos.svg', 'Catálogo visual com preços e estoque'),
      ('Exemplo — Ofertas', 'assets/illustrations/example-ofertas.svg', 'Banner de promoção durante a Live'),
      ('Exemplo — Transmissões', 'assets/illustrations/example-transmissoes.svg', 'Agenda e status da transmissão'),
      ('Exemplo — Overlays', 'assets/illustrations/example-overlays.svg', 'Overlay aplicado na transmissão'),
      ('Logo principal', 'assets/branding/logo.svg', 'Identidade LIVE STUDIO ASR'),
      ('Logo reduzida', 'assets/branding/logo-small.svg', 'Versão compacta da marca'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca de mídia')),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 340,
          mainAxisExtent: 285,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Image.asset(item.$2, fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$1, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(item.$3, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.upload_file_outlined),
        label: const Text('Adicionar mídia'),
      ),
    );
  }
}
