// lib/screens/coordinator/coordinator_dashboard_refactored.dart
import 'package:brainmoto_app/screens/coordinator/create_school_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/coordinator_provider.dart';

class CoordinatorDashboardRefactored extends StatelessWidget {
  const CoordinatorDashboardRefactored({super.key});

  @override
  Widget build(BuildContext context) {
    return _CoordinatorDashboardContent();
  }
}

class _CoordinatorDashboardContent extends StatelessWidget {
  const _CoordinatorDashboardContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinator Dashboard'),
        actions: [
          _buildConnectivityIndicator(),
          _buildMenuButton(context),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBanner(),
          _buildHeader(context),
          Expanded(child: _buildSchoolsList()),
        ],
      ),
    );
  }

  Widget _buildConnectivityIndicator() {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            connectivity.isOnline ? Icons.wifi : Icons.wifi_off,
            color: connectivity.isOnline ? Colors.white : Colors.red,
          ),
        );
      },
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        if (value == 'logout') {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          await authProvider.signOut();
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      },
    );
  }

  Widget _buildStatusBanner() {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: connectivity.isOnline ? Colors.green : Colors.orange,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                connectivity.isOnline ? Icons.cloud_done : Icons.cloud_off,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                connectivity.isOnline
                    ? 'Online - Full Access'
                    : 'Limited Offline Access',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Managed Schools',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4e3f8a),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateSchoolScreenRefactored(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add School'),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolsList() {
    return Consumer<CoordinatorProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${provider.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.clearError();
                    provider.loadSchools();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.schools.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: provider.schools.length,
          itemBuilder: (context, index) {
            final school = provider.schools[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF4e3f8a),
                  child: Text(
                    school.code.substring(0, 2).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  school.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle:
                    Text('${school.city}, ${school.area} • ${school.code}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  final coordinatorProvider =
                      Provider.of<CoordinatorProvider>(context, listen: false);

                  coordinatorProvider.selectSchool(school);

                  Navigator.pushNamed(context, '/school-detail');
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No schools added yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateSchoolScreenRefactored(),
                ),
              );
            },
            child: const Text('Add Your First School'),
          ),
        ],
      ),
    );
  }
}
