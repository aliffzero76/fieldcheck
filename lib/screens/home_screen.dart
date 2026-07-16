import 'package:flutter/material.dart';
import '../models/check_in.dart';
import '../services/storage_service.dart';
import '../widgets/check_in_card.dart';
import '../widgets/empty_state.dart';
import 'new_check_in_screen.dart';
import 'detail_screen.dart';

/// Screen 1 / 1b — Home / History list, with empty state.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CheckIn> _checkIns = [];

  @override
  void initState() {
    super.initState();
    _loadCheckIns();
  }

  void _loadCheckIns() {
    setState(() {
      _checkIns = StorageService.getAll();
    });
  }

  Future<void> _openNewCheckIn() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const NewCheckInScreen()),
    );
    if (saved == true) {
      _loadCheckIns();
    }
  }

  Future<void> _openDetail(CheckIn checkIn) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetailScreen(checkIn: checkIn)),
    );
    // Refresh in case a record was deleted from the detail screen.
    _loadCheckIns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FieldCheck')),
      body: _checkIns.isEmpty
          ? const EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: _checkIns.length,
              itemBuilder: (context, index) {
                final checkIn = _checkIns[index];
                return CheckInCard(
                  checkIn: checkIn,
                  onTap: () => _openDetail(checkIn),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewCheckIn,
        child: const Icon(Icons.add),
      ),
    );
  }
}
