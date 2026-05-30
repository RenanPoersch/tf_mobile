import 'package:flutter/material.dart';
import 'user_view.dart';
import 'event_view.dart';
// import 'registration_view.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/event_viewmodel.dart';
// import '../viewmodels/registration_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Manager'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Users'),
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
              title: const Text('Events'),
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
            // ListTile(
            //   title: const Text('Registrations'),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => RegistrationView(
            //           registrationViewModel: RegistrationViewModel(),
            //         ),
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Select an option from the menu'),
      ),
    );
  }
}