import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Pesquisar ${widget.title.toLowerCase()}...',
                suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.clear)),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(items.isEmpty ? 'Nenhum item cadastrado.' : 'Nenhum resultado encontrado.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, visibleIndex) {
                      final value = filtered[visibleIndex];
                      final originalIndex = items.indexOf(value);
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${visibleIndex + 1}')),
                          title: Text(value),
                          subtitle: const Text('Persistido localmente no dispositivo'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) async {
                              final notifier = ref.read(widget.provider.notifier);
                              switch (action) {
                                case 'edit':
                                  final edited = await _nameDialog(initial: value);
                                  if (edited != null && edited.isNotEmpty) await notifier.replaceAt(originalIndex, edited);
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
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
