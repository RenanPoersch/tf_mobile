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
                        title: Text(event.name),
                        subtitle: Text(event.description),
                        trailing: Icon(
                          Icons.event,
                          color: Theme.of(context).colorScheme.primary,
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