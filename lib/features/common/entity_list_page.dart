import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/demo_list_provider.dart';

class EntityListPage extends ConsumerStatefulWidget {
  final String title;
  final StateNotifierProvider<DemoListNotifier, List<LiveRecord>> provider;
  final String singular;

  const EntityListPage({super.key, required this.title, required this.provider, required this.singular});

  @override
  ConsumerState<EntityListPage> createState() => _EntityListPageState();
}

class _EntityListPageState extends ConsumerState<EntityListPage> {
  final _search = TextEditingController();

  String get _asset {
    switch (widget.title) {
      case 'Cenas': return 'assets/illustrations/example-cenas.svg';
      case 'Produtos': return 'assets/illustrations/example-produtos.svg';
      case 'Ofertas': return 'assets/illustrations/example-ofertas.svg';
      case 'Transmissões': return 'assets/illustrations/example-transmissoes.svg';
      case 'Overlays': return 'assets/illustrations/example-overlays.svg';
      default: return 'assets/images/example.jpg';
    }
  }

  List<String> get _fields {
    switch (widget.title) {
      case 'Produtos': return ['SKU', 'Preço', 'Preço promocional', 'Estoque'];
      case 'Ofertas': return ['Preço original', 'Preço promocional', 'Início', 'Fim', 'Status'];
      case 'Transmissões': return ['Data/hora', 'Status', 'Cena', 'Duração'];
      case 'Overlays': return ['Tipo', 'Posição', 'Visibilidade'];
      default: return ['Descrição', 'Tipo', 'Duração'];
    }
  }

  String _key(String label) {
    switch (label) {
      case 'SKU': return 'sku';
      case 'Preço': return 'price';
      case 'Preço promocional': return 'promoPrice';
      case 'Estoque': return 'stock';
      case 'Preço original': return 'originalPrice';
      case 'Início': return 'start';
      case 'Fim': return 'end';
      case 'Status': return 'status';
      case 'Data/hora': return 'schedule';
      case 'Cena': return 'scene';
      case 'Duração': return 'duration';
      case 'Tipo': return 'type';
      case 'Posição': return 'position';
      case 'Visibilidade': return 'visible';
      default: return 'description';
    }
  }

  Widget _visual(String asset) => asset.endsWith('.svg') ? SvgPicture.asset(asset, fit: BoxFit.cover) : Image.asset(asset, fit: BoxFit.cover);

  Future<LiveRecord?> _editDialog({LiveRecord? initial}) async {
    final name = TextEditingController(text: initial?.name ?? '');
    final controllers = {for (final field in _fields) _key(field): TextEditingController(text: '${initial?.data[_key(field)] ?? ''}')};
    bool active = initial?.active ?? true;
    final result = await showDialog<LiveRecord>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) => AlertDialog(
        title: Text(initial == null ? 'Novo ${widget.singular}' : 'Editar ${widget.singular}'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: InputDecoration(labelText: widget.singular)),
          const SizedBox(height: 10),
          ...controllers.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: e.value, decoration: InputDecoration(labelText: e.key)))),
          SwitchListTile.adaptive(title: const Text('Ativo'), value: active, onChanged: (v) => setState(() => active = v)),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, LiveRecord(
            id: initial?.id ?? 'rec-${DateTime.now().microsecondsSinceEpoch}',
            name: name.text.trim(), active: active, imageAsset: initial?.imageAsset ?? _asset,
            data: {for (final e in controllers.entries) e.key: e.value.text.trim()},
          )), child: const Text('Salvar')),
        ],
      )),
    );
    for (final c in controllers.values) c.dispose();
    name.dispose();
    return result;
  }

  Future<void> _setTransmissionStatus(LiveRecord record, String status) async {
    final index = ref.read(widget.provider).indexWhere((r) => r.id == record.id);
    if (index < 0) return;
    final nextData = Map<String, dynamic>.from(record.data)..['status'] = status;
    await ref.read(widget.provider.notifier).replaceAt(index, record.copyWith(data: nextData, active: status != 'finished'));
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(widget.provider);
    final q = _search.text.trim().toLowerCase();
    final filtered = q.isEmpty ? items : items.where((r) => '${r.name} ${r.data.values.join(' ')}'.toLowerCase().contains(q)).toList();
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [IconButton(onPressed: () => ref.read(widget.provider.notifier).resetToSeed(), icon: const Icon(Icons.restore_outlined), tooltip: 'Restaurar exemplos')]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () async { final r = await _editDialog(); if (r != null && r.name.isNotEmpty) await ref.read(widget.provider.notifier).addItem(r); }, icon: const Icon(Icons.add), label: Text('Novo ${widget.singular}')),
      body: ListView(padding: const EdgeInsets.fromLTRB(20,16,20,100), children: [
        Card(clipBehavior: Clip.antiAlias, child: Column(children: [SizedBox(height: 220, width: double.infinity, child: _visual(_asset)), Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Icon(Icons.visibility_outlined), const SizedBox(width: 10), Expanded(child: Text('Exemplo de utilização — ${widget.title}', style: Theme.of(context).textTheme.titleMedium))]))])),
        const SizedBox(height: 16),
        TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Pesquisar...', border: const OutlineInputBorder())),
        const SizedBox(height: 14),
        if (filtered.isEmpty) const SizedBox(height: 200, child: Center(child: Text('Nenhum item encontrado.')))
        else ...filtered.map((record) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
          leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 72, height: 56, child: _visual(record.imageAsset))),
          title: Text(record.name),
          subtitle: Text(record.data.entries.map((e) => '${e.key}: ${e.value}').join(' • ')),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (widget.title == 'Transmissões') ...[
              IconButton(tooltip: 'Iniciar', onPressed: () => _setTransmissionStatus(record, 'running'), icon: const Icon(Icons.play_arrow)),
              IconButton(tooltip: 'Pausar', onPressed: () => _setTransmissionStatus(record, 'paused'), icon: const Icon(Icons.pause)),
              IconButton(tooltip: 'Finalizar', onPressed: () => _setTransmissionStatus(record, 'finished'), icon: const Icon(Icons.stop)),
            ],
            PopupMenuButton<String>(onSelected: (action) async {
              final notifier = ref.read(widget.provider.notifier);
              final index = items.indexWhere((r) => r.id == record.id);
              if (action == 'edit') { final r = await _editDialog(initial: record); if (r != null) await notifier.replaceAt(index, r); }
              if (action == 'duplicate') await notifier.addItem(record.copyWith(id: 'copy-${DateTime.now().microsecondsSinceEpoch}', name: '${record.name} (cópia)'));
              if (action == 'toggle') await notifier.toggleAt(index);
              if (action == 'delete') await notifier.deleteAt(index);
            }, itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'duplicate', child: Text('Duplicar')),
              PopupMenuItem(value: 'toggle', child: Text('Ativar / desativar')),
              PopupMenuItem(value: 'delete', child: Text('Excluir')),
            ]),
          ]),
        )))],
      ),
    );
  }
}
