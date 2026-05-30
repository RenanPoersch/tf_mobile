import 'package:flutter/material.dart';
import '../viewmodels/user_viewmodel.dart';
import './user_form.dart';

class UserView extends StatefulWidget {
  final UserViewModel userViewModel;

  const UserView({super.key, required this.userViewModel});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  @override
  void initState() {
    super.initState();
    widget.userViewModel.loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.userViewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Usuários'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: widget.userViewModel.setSearchQuery,
                  decoration: const InputDecoration(
                    labelText: 'Buscar',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.userViewModel.users.length,
                    itemBuilder: (context, index) {
                      final user = widget.userViewModel.users[index];
                      return ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user.active ? Icons.check_circle : Icons.cancel,
                              color: user.active ? Colors.green : Colors.red,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Confirmar'),
                                    content: Text('Deletar usuário "${user.name}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: const Text('Deletar'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed != true) return;

                                await widget.userViewModel.deleteUser(user);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Usuário deletado')),
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => UserFormDialog(
                              initial: user,
                              onSave: (u) async => await widget.userViewModel.updateUser(u),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => UserFormDialog(
                  onSave: (user) async {
                    await widget.userViewModel.addUser(user);
                  },
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}