import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MediaLibrary extends StatefulWidget {
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

  @override
  State<MediaLibrary> createState() => _MediaLibraryState();
}

class _MediaLibraryState extends State<MediaLibrary> {
  String _query = '';
  String _filter = 'Todos';

  Widget _visual(String path) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(path, fit: BoxFit.contain);
    }
    return Image.asset(path, fit: BoxFit.cover);
  }

  String _kind(String path) {
    return path.toLowerCase().endsWith('.svg') ? 'Vetor' : 'Imagem';
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final colors = base.colorScheme;
    final studio = base.copyWith(
      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: const Color(0xFFFF7A00),
        foregroundColor: Colors.white,
      ),
    );

    final filtered = MediaLibrary.items.where((item) {
      final matchesQuery = _query.isEmpty ||
          item.$1.toLowerCase().contains(_query.toLowerCase()) ||
          item.$3.toLowerCase().contains(_query.toLowerCase());
      final matchesFilter = _filter == 'Todos' || _kind(item.$2) == _filter;
      return matchesQuery && matchesFilter;
    }).toList();

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
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primaryContainer, colors.surfaceContainerHighest],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7A00),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.perm_media_outlined, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Assets do estúdio', style: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text('Organize previews, logos, cenas e artes usadas nas transmissões.', style: base.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      if (MediaLibrary.items.isNotEmpty)
                        Text('${MediaLibrary.items.length} assets', style: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) => setState(() => _query = value),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Buscar mídia, logo, cena...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'Todos', label: Text('Todos')),
                        ButtonSegment(value: 'Imagem', label: Text('Imagens')),
                        ButtonSegment(value: 'Vetor', label: Text('Vetores')),
                      ],
                      selected: {_filter},
                      onSelectionChanged: (selection) => setState(() => _filter = selection.first),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filtered[index];
                    final kind = _kind(item.$2);
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    color: colors.surfaceContainerHighest,
                                    padding: const EdgeInsets.all(12),
                                    child: _visual(item.$2),
                                  ),
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Chip(
                                      visualDensity: VisualDensity.compact,
                                      label: Text(kind),
                                      avatar: Icon(kind == 'Vetor' ? Icons.auto_awesome_mosaic_outlined : Icons.image_outlined, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 10, 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.$1, style: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                                        const SizedBox(height: 4),
                                        Text(item.$3, maxLines: 2, overflow: TextOverflow.ellipsis, style: base.textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Mais opções',
                                    onPressed: () {},
                                    icon: const Icon(Icons.more_vert),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 360,
                  mainAxisExtent: 320,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
              ),
            ),
          ],
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
