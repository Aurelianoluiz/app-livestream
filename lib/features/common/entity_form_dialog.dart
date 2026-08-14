import 'package:flutter/material.dart';
import '../../providers/demo_list_provider.dart';

class FieldSpec {
  final String keyName;
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final bool multiline;

  const FieldSpec({
    required this.keyName,
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.multiline = false,
  });
}

Future<LiveRecord?> showLiveRecordForm({
  required BuildContext context,
  required String singular,
  required String imageAsset,
  required List<FieldSpec> fields,
  LiveRecord? initial,
}) async {
  final controllers = <String, TextEditingController>{};
  for (final field in fields) {
    controllers[field.keyName] = TextEditingController(
      text: initial?.data[field.keyName]?.toString() ?? '',
    );
  }

  final result = await showDialog<LiveRecord>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(initial == null ? 'Novo $singular' : 'Editar $singular'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controllers['_name'] ??= TextEditingController(text: initial?.name ?? ''),
                decoration: const InputDecoration(labelText: 'Nome'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              ...fields.map((field) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: controllers[field.keyName]!,
                      keyboardType: field.keyboardType,
                      maxLines: field.multiline ? 4 : 1,
                      decoration: InputDecoration(labelText: field.label, hintText: field.hint),
                    ),
                  )),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            final name = controllers['_name']!.text.trim();
            if (name.isEmpty) return;
            final data = <String, dynamic>{
              for (final field in fields) field.keyName: controllers[field.keyName]!.text.trim(),
            };
            Navigator.pop(
              dialogContext,
              LiveRecord(
                id: initial?.id ?? 'record-${DateTime.now().microsecondsSinceEpoch}',
                name: name,
                active: initial?.active ?? true,
                imageAsset: imageAsset,
                data: data,
              ),
            );
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );

  for (final controller in controllers.values) {
    controller.dispose();
  }
  return result;
}
