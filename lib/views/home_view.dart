import 'package:flutter/material.dart';
import 'user_view.dart';
import 'event_view.dart';
import 'registration_view.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/registration_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

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
      body: const Center(
        child: Text('Bem-vindo'),
      ),
    );
  }
}