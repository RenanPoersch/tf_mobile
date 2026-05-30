import 'package:flutter/material.dart';
import 'views/user_view.dart';
import 'viewmodels/user_viewmodel.dart';

void main() {
  // Instância do ViewModel criada no ponto de entrada
  final userViewModel = UserViewModel();
  runApp(MyApp(userViewModel: userViewModel));
}

class MyApp extends StatelessWidget {
  final UserViewModel userViewModel;
  const MyApp({super.key, required this.userViewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TF Mobile - Eventos',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Passa o ViewModel para a HomeView via construtor
      home: UserView(userViewModel: userViewModel),
    );
  }
}