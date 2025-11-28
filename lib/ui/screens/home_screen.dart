import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/bottom_nav.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'categories_screen.dart';
import 'transaction_form_screen.dart';
import '../../models/transaction.dart' as models;
import '../../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Inicia no Dashboard (centro)
  String? _activeUserId;
  final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadActiveUser();
  }

  Future<void> _loadActiveUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _activeUserId = prefs.getString(AppConstants.prefKeyActiveUserId);
    });
  }

  Future<void> _setActiveUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefKeyActiveUserId, userId);
    setState(() {
      _activeUserId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildMenuScreen(),
          DashboardScreen(key: _dashboardKey, activeUserId: _activeUserId),
          ProfileScreen(
            activeUserId: _activeUserId,
            onUserChanged: _setActiveUser,
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTabChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onDashboardRefresh: () {
          _dashboardKey.currentState?.loadData();
        },
      ),
    );
  }

  // Tela de menu (botão esquerdo) - Placeholder
  Widget _buildMenuScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Menu com Botões Animados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (_activeUserId == null || _activeUserId!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Crie e selecione um usuário primeiro na tela Perfil'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  // Mudar para a tela de perfil
                  setState(() {
                    _currentIndex = 2;
                  });
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionFormScreen(
                      type: models.TransactionType.income,
                      activeUserId: _activeUserId!,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_upward),
              label: const Text('Nova Entrada'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (_activeUserId == null || _activeUserId!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Crie e selecione um usuário primeiro na tela Perfil'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  // Mudar para a tela de perfil
                  setState(() {
                    _currentIndex = 2;
                  });
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionFormScreen(
                      type: models.TransactionType.outcome,
                      activeUserId: _activeUserId!,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_downward),
              label: const Text('Nova Saída'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoriesScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.category),
              label: const Text('Gerenciar Categorias'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
