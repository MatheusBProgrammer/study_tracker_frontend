import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_tracker_frontend/components/add_exam_modal.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showAddExamModal(BuildContext context, String? userId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AddExamModal(userId: userId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (ctx, authProvider, child) {
        final exams = authProvider.currentUser?.exams ?? [];
        final userId = authProvider.currentUser?.id;

        return Scaffold(
          // --------------------- APP BAR ---------------------
          appBar: AppBar(
            elevation: 0, // remove “sombra” do AppBar
            backgroundColor: Colors.deepPurple.shade600,
            centerTitle: true,
            title: const Text(
              'Provas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.only(left: 12),
              child: const Icon(
                Icons.school,
                size: 28,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  size: 26,
                  color: Colors.white,
                ),
                onPressed: () {
                  authProvider.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),

          // --------------------- FLOATING BUTTON ---------------------
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddExamModal(context, userId),
            backgroundColor: Colors.deepPurple.shade600,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            label: const Text(
              'Nova Prova',
              style: TextStyle(color: Colors.white),
            ),
          ),

          // --------------------- CORPO/CONTEÚDO ---------------------
          body: Container(
            // Fundo com um gradiente suave
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.shade50,
                  Colors.white,
                ],
              ),
            ),
            child: exams.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma prova cadastrada.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: exams.length,
                    itemBuilder: (ctx, index) {
                      final exam = exams[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/exam-details',
                              arguments: {
                                'examId': exam['examId'],
                                'userId': userId,
                                'name': exam['name'],
                                'subjects': exam['subjects'],
                              },
                            );
                          },
                          // Card com design arredondado e leve sombra
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            // Faz um gradiente de fundo dentro do Card
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.deepPurple.shade100.withOpacity(0.4),
                                    Colors.deepPurple.shade50.withOpacity(0.5),
                                  ],
                                ),
                              ),
                              // Conteúdo do Card
                              child: ListTile(
                                // Ícone circular com gradiente
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.deepPurple.shade400,
                                        Colors.deepPurple.shade600,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.description,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  exam['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Peso total: ${exam['totalWeight']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
