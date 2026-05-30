import 'package:flutter/material.dart';
import 'views/home_view.dart';
import 'viewmodels/home_viewmodel.dart';

void main() {
  // Instância do ViewModel criada no ponto de entrada
  final homeViewModel = HomeViewModel();
  runApp(MyApp(homeViewModel: homeViewModel));
}

class MyApp extends StatelessWidget {
  final HomeViewModel homeViewModel;
  const MyApp({super.key, required this.homeViewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TF Mobile - Eventos',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Passa o ViewModel para a HomeView via construtor
      home: HomeView(homeViewModel: homeViewModel),
    );
  }
}
