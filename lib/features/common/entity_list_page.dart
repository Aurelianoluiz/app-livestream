import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/demo_list_provider.dart';

class EntityListPage extends ConsumerStatefulWidget {
  final String title;
  final StateNotifierProvider<DemoListNotifier, List<String>> provider;
  final String singular;

  const EntityListPage({
    super.key,
    required this.title,
    required this.provider,
    required this.singular,
  });

  @override
  ConsumerState<EntityListPage> createState() => _EntityListPageState();
}

class _EntityListPageState extends ConsumerState<EntityListPage> {
  final _search = TextEditingController();

  String get _asset {
    switch (widget.title) {
      case 'Cenas':
        return 'assets/illustrations/example-cenas.svg';
      case 'Produtos':
        return 'assets/illustrations/example-produtos.svg';
      case 'Ofertas':
        return 'assets/illustrations/example-ofertas.svg';
      case 'Transmissões':
        return 'assets/illustrations/example-transmissoes.svg';
      case 'Overlays':
        return 'assets/illustrations/example-overlays.svg';
      default:
        return 'assets/images/example.jpg';
    }
  }

  Widget _visual({required double width, required double height}) {
    final isSvg = _asset.toLowerCase().endsWith('.svg');
    return isSvg
        ? SvgPicture.asset(_asset, width: width, height: height, fit: BoxFit.cover)
        : Image.asset(_asset, width: width, height: height, fit: BoxFit.cover);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<String?> _nameDialog({String? initial}) async {
    final controller = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initial == null ? 'Novo ${widget.singular}' : 'Editar ${widget.singular}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: widget.singular),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.pop(context, controller.text.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Salvar')),
        ],
      ),
    );
  }

  List<String> _filtered(List<String> items) {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items.where((item) => item.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(widget.provider);
    final filtered = _filtered(items);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Restaurar dados de demonstração',
            icon: const Icon(Icons.restore_outlined),
            onPressed: () => ref.read(widget.provider.notifier).resetToSeed(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final value = await _nameDialog();
          if (value != null && value.isNotEmpty) {
            await ref.read(widget.provider.notifier).addItem(value);
          }
        },
        icon: const Icon(Icons.add),
        label: Text('Novo ${widget.singular}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: _visual(width: double.infinity, height: 220),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Row(
                    children: [
                      const Icon(Icons.visibility_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Exemplo de utilização — ${widget.title}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Pesquisar ${widget.title.toLowerCase()}...',
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            SizedBox(
              height: 220,
              child: Center(child: Text(items.isEmpty ? 'Nenhum item cadastrado.' : 'Nenhum resultado encontrado.')),
            )
          else
            ...List.generate(filtered.length, (visibleIndex) {
              final value = filtered[visibleIndex];
              final originalIndex = items.indexOf(value);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _visual(width: 72, height: 56),
                  ),
                  title: Text(value),
                  subtitle: Text('Exemplo de uso em ${widget.title}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) async {
                      final notifier = ref.read(widget.provider.notifier);
                      switch (action) {
                        case 'edit':
                          final edited = await _nameDialog(initial: value);
                          if (edited != null && edited.isNotEmpty) {
                            await notifier.replaceAt(originalIndex, edited);
                          }
                          break;
                        case 'duplicate':
                          await notifier.addItem('$value (cópia)');
                          break;
                        case 'delete':
                          await notifier.deleteAt(originalIndex);
                          break;
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(value: 'duplicate', child: Text('Duplicar')),
                      PopupMenuItem(value: 'delete', child: Text('Excluir')),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
