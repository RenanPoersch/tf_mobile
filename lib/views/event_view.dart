import 'package:flutter/material.dart';
import '../viewmodels/event_viewmodel.dart';
import './event_form.dart';

class EventView extends StatefulWidget {
  final EventViewModel eventViewModel;

  const EventView({super.key, required this.eventViewModel});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  @override
  void initState() {
    super.initState();
    widget.eventViewModel.loadEvents();
  }

  Widget _buildEventImage(String image) {
    if (image.trim().isEmpty) {
      return const CircleAvatar(child: Icon(Icons.event));
    }

    final uri = Uri.tryParse(image.trim());
    final isNetworkImage = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 56,
        height: 56,
        child: isNetworkImage
            ? Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFE0E0E0),
                  child: Icon(Icons.broken_image),
                ),
              )
            : Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFE0E0E0),
                  child: Icon(Icons.image_not_supported),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.eventViewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Eventos'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: widget.eventViewModel.setSearchQuery,
                  decoration: const InputDecoration(
                    labelText: 'Buscar',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.eventViewModel.events.length,
                    itemBuilder: (context, index) {
                      final event = widget.eventViewModel.events[index];
                      return ListTile(
                        leading: _buildEventImage(event.image),
                        title: Text(event.name),
                        subtitle: Text(event.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Confirmar'),
                                    content: Text('Deletar evento "${event.name}"?'),
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

                                await widget.eventViewModel.deleteEvent(event.id!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Evento deletado')),
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => EventFormDialog(
                              initial: event,
                              onSave: (e) async {
                                await widget.eventViewModel.updateEvent(e);
                              },
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
                builder: (_) => EventFormDialog(
                  onSave: (event) async {
                    await widget.eventViewModel.addEvent(event);
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