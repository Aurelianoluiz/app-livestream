import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MediaLibrary extends StatelessWidget {
  const MediaLibrary({super.key});

  static const items = [
    ('Exemplo de Live', 'assets/images/example.jpg', 'Foto/preview principal'),
    ('Exemplo — Cenas', 'assets/illustrations/example-cenas.svg', 'Cena com câmera, produto e oferta'),
    ('Exemplo — Produtos', 'assets/illustrations/example-produtos.svg', 'Catálogo visual com preços e estoque'),
    ('Exemplo — Ofertas', 'assets/illustrations/example-ofertas.svg', 'Banner de promoção durante a Live'),
    ('Exemplo — Transmissões', 'assets/illustrations/example-transmissoes.svg', 'Agenda e status da transmissão'),
    ('Exemplo — Overlays', 'assets/illustrations/example-overlays.svg', 'Overlay aplicado na transmissão'),
    ('Logo principal', 'assets/branding/logo.svg', 'Identidade LIVE STUDIO ASR'),
    ('Logo reduzida', 'assets/branding/logo-small.svg', 'Versão compacta da marca'),
  ];

  Widget _visual(String path) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(path, fit: BoxFit.contain);
    }
    return Image.asset(path, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final studio = base.copyWith(
      cardTheme: base.cardTheme.copyWith(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(backgroundColor: const Color(0xFFFF7A00), foregroundColor: Colors.white),
    );

    return Theme(
      data: studio,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Biblioteca de mídia'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Chip(
                avatar: const Icon(Icons.video_library_outlined, size: 18),
                label: const Text('CENTRAL DE MÍDIA'),
              ),
            ),
          ],
        ),
        body: GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 340,
            mainAxisExtent: 300,
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
                      padding: const EdgeInsets.all(12),
                      child: _visual(item.$2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$1, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
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
      ),
    );
  }
}
