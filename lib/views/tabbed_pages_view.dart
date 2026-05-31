import 'package:flutter/material.dart';

import '../database/dao/event_dao.dart';
import '../database/dao/registration_dao.dart';
import '../database/dao/user_dao.dart';
import '../models/event.dart';
import '../models/registration.dart';
import '../models/user.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/registration_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import './event_view.dart';
import './registration_view.dart';
import './user_view.dart';

class TabbedPagesView extends StatefulWidget {
  const TabbedPagesView({super.key});

  @override
  State<TabbedPagesView> createState() => _TabbedPagesViewState();
}

class _TabbedPagesViewState extends State<TabbedPagesView> {
  final UserViewModel _userViewModel = UserViewModel();
  final EventViewModel _eventViewModel = EventViewModel();
  final RegistrationViewModel _registrationViewModel = RegistrationViewModel();

  final UserDao _userDao = UserDao();
  final EventDao _eventDao = EventDao();
  final RegistrationDao _registrationDao = RegistrationDao();

  List<User> _users = [];
  List<Event> _events = [];
  List<Registration> _registrations = [];

  @override
  void initState() {
    super.initState();
    _userViewModel.loadUsers();
    _eventViewModel.loadEvents();
    _registrationViewModel.loadRegistrations();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    final results = await Future.wait([
      _userDao.findAll(),
      _eventDao.findAll(),
      _registrationDao.findAll(),
    ]);

    if (!mounted) {
      return;
    }

    setState(() {
      _users = results[0] as List<User>;
      _events = results[1] as List<Event>;
      _registrations = results[2] as List<Registration>;
    });
  }

  Future<void> _openFullPage(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    if (!mounted) {
      return;
    }

    await Future.wait([
      _userViewModel.loadUsers(),
      _eventViewModel.loadEvents(),
      _registrationViewModel.loadRegistrations(),
      _loadLookups(),
    ]);
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildSummaryCard({required String label, required String value, required IconData icon}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return AnimatedBuilder(
      animation: _userViewModel,
      builder: (context, _) {
        final users = _userViewModel.users;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Usuários'),
            const SizedBox(height: 12),
            _buildSummaryCard(label: 'Total de usuários', value: users.length.toString(), icon: Icons.people),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _openFullPage(UserView(userViewModel: UserViewModel())),
              child: const Text('Abrir tela de usuários'),
            ),
            const SizedBox(height: 16),
            ...users.map(
              (user) => Card(
                child: ListTile(
                  leading: Icon(user.active ? Icons.check_circle : Icons.cancel, color: user.active ? Colors.green : Colors.red),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventsTab() {
    return AnimatedBuilder(
      animation: _eventViewModel,
      builder: (context, _) {
        final events = _eventViewModel.events;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Eventos'),
            const SizedBox(height: 12),
            _buildSummaryCard(label: 'Total de eventos', value: events.length.toString(), icon: Icons.event),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _openFullPage(EventView(eventViewModel: EventViewModel())),
              child: const Text('Abrir tela de eventos'),
            ),
            const SizedBox(height: 16),
            ...events.map(
              (event) => Card(
                child: ListTile(
                  leading: const Icon(Icons.event_note),
                  title: Text(event.name),
                  subtitle: Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRegistrationsTab() {
    return AnimatedBuilder(
      animation: _registrationViewModel,
      builder: (context, _) {
        final registrations = _registrationViewModel.registrations;

        String nameForUser(int userId) {
          return _users.firstWhere(
                (user) => user.id == userId,
                orElse: () => User(id: userId, name: 'Usuário $userId', email: ''),
              ).name;
        }

        String nameForEvent(int eventId) {
          return _events.firstWhere(
                (event) => event.id == eventId,
                orElse: () => Event(id: eventId, name: 'Evento $eventId', description: '', date: DateTime.now(), eventType: 0, image: ''),
              ).name;
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Inscrições'),
            const SizedBox(height: 12),
            _buildSummaryCard(label: 'Total de inscrições', value: registrations.length.toString(), icon: Icons.app_registration),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _openFullPage(RegistrationView(registrationViewModel: RegistrationViewModel())),
              child: const Text('Abrir tela de inscrições'),
            ),
            const SizedBox(height: 16),
            ...registrations.map(
              (registration) => Card(
                child: ListTile(
                  leading: Icon(registration.isConfirmed ? Icons.verified : Icons.pending),
                  title: Text('${nameForUser(registration.userId)} • ${nameForEvent(registration.eventId)}'),
                  subtitle: Text(registration.isConfirmed ? 'Confirmado' : 'Pendente'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tabbed Pages'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Usuários'),
              Tab(icon: Icon(Icons.event), text: 'Eventos'),
              Tab(icon: Icon(Icons.app_registration), text: 'Inscrições'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUsersTab(),
            _buildEventsTab(),
            _buildRegistrationsTab(),
          ],
        ),
      ),
    );
  }
}