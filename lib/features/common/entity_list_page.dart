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
    if (field == 'Estoque') {
      return [FilteringTextInputFormatter.digitsOnly];
    }
    return null;
  }

  Future<String?> _pickDateTime({String? current}) async {
    DateTime initial = DateTime.now();
    if (current != null) {
      initial = DateTime.tryParse(current) ?? initial;
    }
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

    for (final controller in controllers.values) {
      controller.dispose();
    }
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

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(widget.provider);
    final query = _search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? items
        : items.where((item) => '${item.name} ${item.data.values.join(' ')}'.toLowerCase().contains(query)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => ref.read(widget.provider.notifier).resetToSeed(),
            icon: const Icon(Icons.restore_outlined),
            tooltip: 'Restaurar exemplos',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final record = await _editDialog();
          if (record != null) await ref.read(widget.provider.notifier).addItem(record);
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
              children: [
                SizedBox(height: 220, width: double.infinity, child: _visual(_asset)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.visibility_outlined),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Exemplo de utilização — ${widget.title}', style: Theme.of(context).textTheme.titleMedium)),
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
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Pesquisar...', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            const SizedBox(height: 200, child: Center(child: Text('Nenhum item encontrado.')))
          else
            ...filtered.map(
              (record) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 72, height: 56, child: _visual(record.imageAsset))),
                  title: Text(record.name),
                  subtitle: Text(record.data.entries.map((entry) => '${entry.key}: ${entry.value}').join(' • ')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.title == 'Transmissões') ...[
                        IconButton(tooltip: 'Iniciar', onPressed: () => _setTransmissionStatus(record, 'running'), icon: const Icon(Icons.play_arrow)),
                        IconButton(tooltip: 'Pausar', onPressed: () => _setTransmissionStatus(record, 'paused'), icon: const Icon(Icons.pause)),
                        IconButton(tooltip: 'Finalizar', onPressed: () => _setTransmissionStatus(record, 'finished'), icon: const Icon(Icons.stop)),
                      ],
                      PopupMenuButton<String>(
                        onSelected: (action) async {
                          final notifier = ref.read(widget.provider.notifier);
                          final index = items.indexWhere((item) => item.id == record.id);
                          if (action == 'edit') {
                            final edited = await _editDialog(initial: record);
                            if (edited != null && index >= 0) await notifier.replaceAt(index, edited);
                          }
                          if (action == 'duplicate') {
                            await notifier.addItem(record.copyWith(id: 'copy-${DateTime.now().microsecondsSinceEpoch}', name: '${record.name} (cópia)'));
                          }
                          if (action == 'toggle' && index >= 0) await notifier.toggleAt(index);
                          if (action == 'delete' && index >= 0) await notifier.deleteAt(index);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Editar')),
                          PopupMenuItem(value: 'duplicate', child: Text('Duplicar')),
                          PopupMenuItem(value: 'toggle', child: Text('Ativar / desativar')),
                          PopupMenuItem(value: 'delete', child: Text('Excluir')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
