import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/registration_viewmodel.dart';
import '../database/dao/user_dao.dart';
import '../models/registration.dart';
import './user_view.dart';
import './event_view.dart';
import './registration_view.dart';
import './tabbed_pages_view.dart';
import './event_form.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final EventViewModel _eventViewModel = EventViewModel();
  final RegistrationViewModel _registrationViewModel = RegistrationViewModel();
  final PageController _pageController = PageController(viewportFraction: 0.88);
  Timer? _carouselTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _eventViewModel.loadEvents();
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final events = _eventViewModel.events;
      if (!mounted || events.length < 2) {
        return;
      }

      final currentPage = _pageController.hasClients ? (_pageController.page?.round() ?? _currentIndex) : _currentIndex;
      final nextPage = (currentPage + 1) % events.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildEventImage(String image) {
    if (image.trim().isEmpty) {
      return const Center(child: Icon(Icons.event, size: 48));
    }

    final uri = Uri.tryParse(image.trim());
    final isNetworkImage = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: isNetworkImage
          ? Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Color(0xFFE0E0E0),
                child: Center(child: Icon(Icons.broken_image)),
              ),
            )
          : Image.asset(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Color(0xFFE0E0E0),
                child: Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
    );
  }

  Widget _buildCarouselCard(BuildContext context, Event event) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openEventDetails(event),
        child: Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: _buildEventImage(event.image),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEventDetails(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final formattedDate = DateFormat('dd/MM/yyyy').format(event.date);

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 180,
                  child: _buildEventImage(event.image),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                event.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Tipo: ${event.eventTypeLabel}'),
              Text('Data: $formattedDate'),
              const SizedBox(height: 12),
              Text(event.description),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Fechar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await Future.delayed(const Duration(milliseconds: 120));
                        _showRegisterDialog(event);
                      },
                      child: const Text('Inscrever-se'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRegisterDialog(Event event) async {
    final UserDao userDao = UserDao();
    List users = await userDao.findAll();

    if (users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhum usuário disponível para inscrição')));
      return;
    }

    int? selectedUser = users.isNotEmpty ? users.first.id : null;
    bool confirmed = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Inscrever em evento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedUser,
                items: users.map<DropdownMenuItem<int>>((u) => DropdownMenuItem(value: u.id, child: Text(u.name))).toList(),
                onChanged: (v) => setState(() => selectedUser = v),
                decoration: const InputDecoration(labelText: 'Usuário'),
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
                if (selectedUser == null || event.id == null) return;
                final reg = Registration(id: null, userId: selectedUser!, eventId: event.id!, isConfirmed: confirmed);
                await _registrationViewModel.addRegistration(reg);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inscrição criada')));
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots(int itemCount, int activeIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }

  void _openPage(Widget page) {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    });
  }

  void _openEventForm() {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      showDialog(
        context: context,
        builder: (_) => EventFormDialog(
          onSave: (event) async {
            await _eventViewModel.addEvent(event);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciador de Eventos'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Usuários'),
              onTap: () => _openPage(UserView(userViewModel: UserViewModel())),
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Eventos'),
              onTap: () => _openPage(EventView(eventViewModel: EventViewModel())),
            ),
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Inscrições'),
              onTap: () => _openPage(RegistrationView(registrationViewModel: RegistrationViewModel())),
            ),
            ListTile(
              leading: const Icon(Icons.tab),
              title: const Text('Abas'),
              onTap: () => _openPage(const TabbedPagesView()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Novo Evento'),
              onTap: _openEventForm,
            ),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: _eventViewModel,
        builder: (context, _) {
          final events = _eventViewModel.events;
          final activeIndex = events.isEmpty ? 0 : _currentIndex.clamp(0, events.length - 1).toInt();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo ao Gerenciador de Eventos',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 20),
                Text(
                  'Próximos eventos:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: events.isEmpty
                      ? const Center(child: Text('Sem eventos cadastrados'))
                      : Column(
                          children: [
                            Expanded(
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: events.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final event = events[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: _buildCarouselCard(context, event),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDots(events.length, activeIndex),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
