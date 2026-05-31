import 'package:flutter/material.dart';
import 'user_view.dart';
import 'event_view.dart';
import 'registration_view.dart';
import '../models/event.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/registration_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final EventViewModel _eventViewModel = EventViewModel();
  final PageController _pageController = PageController(viewportFraction: 0.86);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _eventViewModel.loadEvents();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildEventImage(String image) {
    if (image.trim().isEmpty) {
      return const Center(child: Icon(Icons.event, size: 64));
    }

    final uri = Uri.tryParse(image.trim());
    final isNetworkImage = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: isNetworkImage
          ? Image.network(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Color(0xFFE0E0E0),
                child: Center(child: Icon(Icons.broken_image, size: 56)),
              ),
            )
          : Image.asset(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Color(0xFFE0E0E0),
                child: Center(child: Icon(Icons.image_not_supported, size: 56)),
              ),
            ),
    );
  }

  void _openEventSheet(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) {
        final dateText = event.date.toLocal().toString().split(' ').first;

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 180,
                child: _buildEventImage(event.image),
              ),
              const SizedBox(height: 16),
              Text(
                event.name,
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(event.description),
              const SizedBox(height: 12),
              Text('Data: $dateText'),
              Text('Tipo: ${event.eventTypeLabel}'),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildDots(int count) {
    return List.generate(count, (index) {
      final active = index == _currentPage;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: active ? 18 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: active ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(999),
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
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Usuários'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserView(
                      userViewModel: UserViewModel(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Eventos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventView(
                      eventViewModel: EventViewModel(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Inscrições'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegistrationView(
                      registrationViewModel: RegistrationViewModel(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: _eventViewModel,
        builder: (context, _) {
          final events = _eventViewModel.events;

          if (events.isEmpty) {
            return const Center(child: Text('Sem eventos cadastrados'));
          }

          return Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Eventos em destaque',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: events.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final event = events[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: GestureDetector(
                        onTap: () => _openEventSheet(event),
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _buildEventImage(event.image),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.75),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 20,
                                right: 20,
                                bottom: 24,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      event.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      event.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildDots(events.length),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}