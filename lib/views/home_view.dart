import 'package:flutter/material.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeView extends StatelessWidget {
  final HomeViewModel homeViewModel;
  const HomeView({super.key, required this.homeViewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(homeViewModel.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        // AnimatedBuilder reconstrói apenas a subtree quando o ViewModel dispara notifyListeners()
        child: AnimatedBuilder(
          animation: homeViewModel,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  homeViewModel.subtitle,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Ativo:'),
                    Checkbox(
                      value: homeViewModel.isActive,
                      onChanged: (value) => homeViewModel.toggleActive(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: homeViewModel.toggleActive,
                  child: const Text('Alternar status'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
