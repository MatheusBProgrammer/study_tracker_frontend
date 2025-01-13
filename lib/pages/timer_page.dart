import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Classe TimerPage para controlar e enviar o tempo de estudo ao backend.
class TimerPage extends StatefulWidget {
  final String userId;
  final String examId;
  final String subjectId;

  const TimerPage({
    Key? key,
    required this.userId,
    required this.examId,
    required this.subjectId,
  }) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Timer? _timer;
  Duration _elapsed = Duration.zero; // tempo acumulado
  bool _isRunning = false; // se está rodando ou pausado

  /// Inicia o timer (conta 1 segundo por vez).
  void _startTimer() {
    if (_isRunning) return; // já está rodando
    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = _elapsed + const Duration(seconds: 1);
      });
    });
  }

  /// Pausa o timer.
  void _pauseTimer() {
    if (!_isRunning) return; // já está pausado
    setState(() => _isRunning = false);
    _timer?.cancel();
  }

  /// Finaliza o timer e faz PATCH no backend.
  Future<void> _stopTimerAndSend() async {
    // Para se estiver rodando
    if (_isRunning) {
      _pauseTimer();
    }

    // Tempo total em segundos (inteiro).
    final int totalSeconds = _elapsed.inSeconds;

    // Montagem das URLs (ajuste se precisar de HTTPS, IP, etc.).
    final dailyUrl = Uri.parse(
      'http://localhost:8080/api/subjects/'
      '${widget.userId}/${widget.examId}/${widget.subjectId}/daily-study-time'
      '?additionalTime=$totalSeconds',
    );

    final totalUrl = Uri.parse(
      'http://localhost:8080/api/subjects/'
      '${widget.userId}/${widget.examId}/${widget.subjectId}/study-time'
      '?additionalTime=$totalSeconds',
    );

    try {
      // Faz as duas requisições PATCH (você pode usar Future.wait se quiser paralelizar).
      final dailyResponse = await http.patch(dailyUrl);
      final totalResponse = await http.patch(totalUrl);

      if (dailyResponse.statusCode == 200 && totalResponse.statusCode == 200) {
        // Sucesso, zera o timer (opcional) e avisa o usuário
        setState(() {
          _elapsed = Duration.zero;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tempo enviado com sucesso!')),
          );
        }
      } else {
        // Caso algum retorne status code != 200
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erro ao enviar tempo: '
                'daily=${dailyResponse.statusCode}, '
                'total=${totalResponse.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Possível erro de conexão
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão: $e')),
        );
      }
    }

    // Retorna para a tela anterior após enviar
    if (mounted) Navigator.of(context).pop();
  }

  /// Formata o tempo como HH:MM:SS para exibir ao usuário.
  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    // Cancela o timer ao sair
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo roxo
      backgroundColor: Colors.deepPurple.shade600,

      body: SafeArea(
        child: Stack(
          children: [
            // Cronômetro no centro
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatDuration(_elapsed),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Botões Start / Pause / Stop
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // START
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                        ),
                        onPressed: _startTimer,
                        child:
                            const Icon(Icons.play_arrow, color: Colors.white),
                      ),
                      const SizedBox(width: 16),

                      // PAUSE
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                        ),
                        onPressed: _pauseTimer,
                        child: const Icon(Icons.pause, color: Colors.white),
                      ),
                      const SizedBox(width: 16),

                      // STOP
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                        ),
                        onPressed: _stopTimerAndSend,
                        child: const Icon(Icons.stop, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botão de fechar no topo
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, size: 32, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
