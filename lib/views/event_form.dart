import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

typedef OnSaveEvent = Future<void> Function(Event event);

class EventFormDialog extends StatefulWidget {
  final Event? initial;
  final OnSaveEvent onSave;

  const EventFormDialog({
    super.key,
    this.initial,
    required this.onSave,
  });

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _dateCtrl;
  int? _selectedType;
  late final TextEditingController _imageCtrl;

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
    _descriptionCtrl = TextEditingController(text: widget.initial?.description ?? '');
    _selectedDate = widget.initial?.date;
    _dateCtrl = TextEditingController(
      text: widget.initial != null ? DateFormat('dd/MM/yyyy').format(widget.initial!.date) : '',
    );
    _selectedType = widget.initial?.eventType ?? EventType.presencial.value;
    _imageCtrl = TextEditingController(text: widget.initial?.image ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _dateCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _dateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) return;

    final event = Event(
      id: widget.initial?.id,
      name: _nameCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      date: _selectedDate!,
      eventType: _selectedType ?? EventType.presencial.value,
      image: _imageCtrl.text.trim(),
    );

    await widget.onSave(event);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Adicionar Evento' : 'Editar Evento'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Obrigatório';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Data',
                  hintText: 'Selecione a data',
                ),
                validator: (value) {
                  if (_selectedDate == null) {
                    return 'Obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Column(
                children: EventType.values.map((t) {
                  return RadioListTile<int>(
                    title: Text(t.label),
                    value: t.value,
                    groupValue: _selectedType,
                    onChanged: (v) => setState(() => _selectedType = v),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imageCtrl,
                decoration: const InputDecoration(labelText: 'Imagem'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Obrigatório';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}