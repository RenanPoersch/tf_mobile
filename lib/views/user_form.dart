import 'package:flutter/material.dart';
import '../models/user.dart';

typedef OnSaveUser = Future<void> Function(User user);

class UserFormDialog extends StatefulWidget {
  final User? initial;
  final OnSaveUser onSave;

  const UserFormDialog({super.key, this.initial, required this.onSave});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.initial?.email ?? '');
    _active = widget.initial?.active ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = User(
      id: widget.initial?.id,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      active: _active,
    );
    await widget.onSave(user);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Adicionar Usuário' : 'Editar'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Obrigatório';
                  final email = v.trim();
                  final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                  return regex.hasMatch(email) ? null : 'Email inválido';
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Ativo'),
                  const Spacer(),
                  Checkbox(value: _active, onChanged: (val) => setState(() => _active = val ?? true)),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _save, child: const Text('Salvar')),
      ],
    );
  }
}