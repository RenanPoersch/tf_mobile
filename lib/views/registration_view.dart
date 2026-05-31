import 'package:flutter/material.dart';
import '../viewmodels/registration_viewmodel.dart';
import '../database/dao/user_dao.dart';
import '../database/dao/event_dao.dart';
import '../models/registration.dart';
import '../models/user.dart';
import '../models/event.dart';

class RegistrationView extends StatefulWidget {
  final RegistrationViewModel registrationViewModel;

  const RegistrationView({super.key, required this.registrationViewModel});

  @override
  State<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  final UserDao _userDao = UserDao();
  final EventDao _eventDao = EventDao();

  List<User> _users = [];
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    widget.registrationViewModel.loadRegistrations();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    _users = await _userDao.findAll();
    _events = await _eventDao.findAll();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.registrationViewModel,
      builder: (context, _) {
        final regs = widget.registrationViewModel.registrations;
        return Scaffold(
          appBar: AppBar(title: const Text('Inscrições')),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: regs.isEmpty
                ? const Center(child: Text('Sem inscrições ainda'))
                : ListView.separated(
                    itemCount: regs.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      final r = regs[i];
                        final userName =
                          _users.firstWhere((u) => u.id == r.userId, orElse: () => User(id: r.userId, name: 'Usuário ${r.userId}', email: '')).name;
                        final eventName =
                          _events.firstWhere((e) => e.id == r.eventId, orElse: () => Event(id: r.eventId, name: 'Evento ${r.eventId}', description: '', date: DateTime.now(), eventType: 0, image: '')).name;
                      return ListTile(
                        title: Text('$userName — $eventName'),
                        subtitle: Text(r.isConfirmed ? 'Confirmado' : 'Pendente'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: r.isConfirmed,
                              onChanged: (v) async {
                                await widget.registrationViewModel.updateConfirmation(r.id!, v);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(v ? 'Inscrição confirmada' : 'Inscrição marcada como pendente')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirmado = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Confirmar exclusão'),
                                    content: Text('Excluir inscrição de $userName no evento $eventName?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                                      ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Excluir')),
                                    ],
                                  ),
                                );
                                if (confirmado != true) return;
                                await widget.registrationViewModel.deleteRegistration(r.id!);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inscrição excluída')));
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                         
                        },
                      );
                    },
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context) {
    int? selectedUser = _users.isNotEmpty ? _users.first.id : null;
    int? selectedEvent = _events.isNotEmpty ? _events.first.id : null;
    bool confirmed = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Nova Inscrição'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedUser,
                items: _users.map((u) => DropdownMenuItem(value: u.id, child: Text(u.name))).toList(),
                onChanged: (v) => setState(() => selectedUser = v),
                decoration: const InputDecoration(labelText: 'Usuário'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedEvent,
                items: _events.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => selectedEvent = v),
                decoration: const InputDecoration(labelText: 'Evento'),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: confirmed,
                onChanged: (v) => setState(() => confirmed = v ?? false),
                title: const Text('Confirmado'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (selectedUser == null || selectedEvent == null) return;
                final reg = Registration(id: null, userId: selectedUser!, eventId: selectedEvent!, isConfirmed: confirmed);
                await widget.registrationViewModel.addRegistration(reg);
                Navigator.of(ctx).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}