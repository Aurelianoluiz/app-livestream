import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Widget _visual(String asset) => asset.endsWith('.svg')
      ? SvgPicture.asset(asset, fit: BoxFit.cover)
      : Image.asset(asset, fit: BoxFit.cover);

  TextInputType _keyboard(String field) {
    if (['Preço', 'Preço promocional', 'Preço original', 'Estoque', 'Duração'].contains(field)) {
      return const TextInputType.numberWithOptions(decimal: true);
    }
    return TextInputType.text;
  }

  List<TextInputFormatter>? _formatters(String field) {
    if (['Preço', 'Preço promocional', 'Preço original'].contains(field)) {
      return [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.-]'))];
    }
    if (field == 'Estoque') return [FilteringTextInputFormatter.digitsOnly];
    return null;
  }

  Future<String?> _pickDateTime({String? current}) async {
    DateTime initial = DateTime.now();
    if (current != null) initial = DateTime.tryParse(current) ?? initial;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    final value = DateTime(date.year, date.month, date.day, time?.hour ?? initial.hour, time?.minute ?? initial.minute);
    return value.toIso8601String();
  }

  Future<LiveRecord?> _editDialog({LiveRecord? initial}) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: initial?.name ?? '');
    final controllers = {
      for (final field in _fields)
        _key(field): TextEditingController(text: '${initial?.data[_key(field)] ?? ''}')
    };
    bool active = initial?.active ?? true;

    final result = await showDialog<LiveRecord>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(initial == null ? 'Novo ${widget.singular}' : 'Editar ${widget.singular}'),
          content: SizedBox(
            width: 520,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: name,
                      autofocus: true,
                      decoration: InputDecoration(labelText: widget.singular, prefixIcon: const Icon(Icons.label_outline)),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: 12),
                    ...controllers.entries.map((entry) {
                      final field = _fields.firstWhere((label) => _key(label) == entry.key);
                      final isDate = ['Início', 'Fim', 'Data/hora'].contains(field);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          controller: entry.value,
                          readOnly: isDate,
                          keyboardType: _keyboard(field),
                          inputFormatters: _formatters(field),
                          maxLines: field == 'Descrição' ? 3 : 1,
                          decoration: InputDecoration(
                            labelText: field,
                            prefixIcon: Icon(isDate ? Icons.calendar_month_outlined : Icons.edit_outlined),
                            suffixIcon: isDate ? const Icon(Icons.event_available_outlined) : null,
                          ),
                          onTap: isDate
                              ? () async {
                                  final value = await _pickDateTime(current: entry.value.text);
                                  if (value != null) setState(() => entry.value.text = value);
                                }
                              : null,
                          validator: (value) {
                            if (['SKU', 'Preço', 'Preço original', 'Estoque'].contains(field) && (value == null || value.trim().isEmpty)) {
                              return 'Informe $field';
                            }
                            return null;
                          },
                        ),
                      );
                    }),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Ativo'),
                      subtitle: Text(active ? 'Disponível para utilização' : 'Oculto da operação'),
                      value: active,
                      onChanged: (value) => setState(() => active = value),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton.icon(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(
                  context,
                  LiveRecord(
                    id: initial?.id ?? 'rec-${DateTime.now().microsecondsSinceEpoch}',
                    name: name.text.trim(),
                    active: active,
                    imageAsset: initial?.imageAsset ?? _asset,
                    data: {for (final entry in controllers.entries) entry.key: entry.value.text.trim()},
                  ),
                );
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    for (final controller in controllers.values) controller.dispose();
    name.dispose();
    return result;
  }

  Future<void> _setTransmissionStatus(LiveRecord record, String status) async {
    final index = ref.read(widget.provider).indexWhere((item) => item.id == record.id);
    if (index < 0) return;
    final nextData = Map<String, dynamic>.from(record.data)..['status'] = status;
    await ref.read(widget.provider.notifier).replaceAt(index, record.copyWith(data: nextData, active: status != 'finished'));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget _recordCard(BuildContext context, LiveRecord record, List<LiveRecord> items) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final index = items.indexWhere((item) => item.id == record.id);
    final status = '${record.data['status'] ?? ''}'.toLowerCase();
    final statusColor = status == 'running' ? scheme.primary : status == 'paused' ? scheme.secondary : scheme.onSurfaceVariant;
    final statusLabel = status == 'running' ? 'AO VIVO' : status == 'paused' ? 'PAUSADA' : record.active ? 'ATIVO' : 'INATIVO';
    final detail = record.data.entries
        .where((entry) => '${entry.value}'.trim().isNotEmpty)
        .take(3)
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(' • ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(height: 145, width: double.infinity, child: _visual(record.imageAsset)),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(color: scheme.surface.withOpacity(0.92), borderRadius: BorderRadius.circular(999)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: statusColor),
                      const SizedBox(width: 6),
                      Text(statusLabel, style: text.labelSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: .7)),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: PopupMenuButton<String>(
                  onSelected: (action) async {
                    final notifier = ref.read(widget.provider.notifier);
                    if (action == 'edit') {
                      final edited = await _editDialog(initial: record);
                      if (edited != null && index >= 0) await notifier.replaceAt(index, edited);
                    } else if (action == 'duplicate') {
                      await notifier.addItem(record.copyWith(id: 'copy-${DateTime.now().microsecondsSinceEpoch}', name: '${record.name} (cópia)'));
                    } else if (action == 'toggle' && index >= 0) {
                      await notifier.toggleAt(index);
                    } else if (action == 'delete' && index >= 0) {
                      await notifier.deleteAt(index);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'duplicate', child: Text('Duplicar')),
                    PopupMenuItem(value: 'toggle', child: Text('Ativar / desativar')),
                    PopupMenuItem(value: 'delete', child: Text('Excluir')),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(detail.isEmpty ? 'Sem detalhes adicionais' : detail, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.35)),
                  const Spacer(),
                  if (widget.title == 'Transmissões')
                    Row(
                      children: [
                        Expanded(child: FilledButton.icon(onPressed: () => _setTransmissionStatus(record, 'running'), icon: const Icon(Icons.play_arrow_rounded, size: 18), label: const Text('Iniciar'))),
                        const SizedBox(width: 7),
                        IconButton(tooltip: 'Pausar', onPressed: () => _setTransmissionStatus(record, 'paused'), icon: const Icon(Icons.pause_rounded)),
                        IconButton(tooltip: 'Finalizar', onPressed: () => _setTransmissionStatus(record, 'finished'), icon: const Icon(Icons.stop_rounded)),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(onPressed: () async {
                        final edited = await _editDialog(initial: record);
                        if (edited != null && index >= 0) await ref.read(widget.provider.notifier).replaceAt(index, edited);
                      }, icon: const Icon(Icons.edit_outlined, size: 18), label: const Text('Abrir item')),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(widget.provider);
    final query = _search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? items
        : items.where((item) => '${item.name} ${item.data.values.join(' ')}'.toLowerCase().contains(query)).toList();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => ref.read(widget.provider.notifier).resetToSeed(),
              icon: const Icon(Icons.restore_outlined),
              tooltip: 'Restaurar exemplos',
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final record = await _editDialog();
          if (record != null) await ref.read(widget.provider.notifier).addItem(record);
        },
        icon: const Icon(Icons.add_rounded),
        label: Text('Novo ${widget.singular}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              children: [
                Container(width: 46, height: 46, decoration: BoxDecoration(color: scheme.primary.withOpacity(.12), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.dashboard_customize_outlined, color: scheme.primary)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${items.length} ${widget.title.toLowerCase()}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text('Biblioteca operacional do estúdio', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant))])),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: 'Pesquisar ${widget.title.toLowerCase()}...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), filled: true),
          ),
          const SizedBox(height: 18),
          if (filtered.isEmpty)
            const SizedBox(height: 220, child: Center(child: Text('Nenhum item encontrado.')))
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width >= 1180 ? 3 : width >= 760 ? 2 : 1;
                final spacing = 14.0;
                final cardWidth = (width - spacing * (columns - 1)) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: filtered.map((record) => SizedBox(width: cardWidth, height: 315, child: _recordCard(context, record, items))).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}
