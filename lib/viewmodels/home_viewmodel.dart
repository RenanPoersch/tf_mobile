import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {

  String title = 'Gerenciamento de Eventos';
  String subtitle = 'Bem-vindo ao sistema de gestão de eventos';
  bool isActive = true;

  void toggleActive() {
    isActive = !isActive;
    notifyListeners();
  }
}
