import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;
  bool _isLocked = false; // Indica se a tela está bloqueada

  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = _elapsed + const Duration(seconds: 1);
      });
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;
    setState(() => _isRunning = false);
    _timer?.cancel();
  }

  Future<void> _stopTimerAndSend() async {
    if (_isRunning) _pauseTimer();
    final int totalSeconds = _elapsed.inSeconds;

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
      final dailyResponse = await http.patch(dailyUrl);
      final totalResponse = await http.patch(totalUrl);

      if (dailyResponse.statusCode == 200 && totalResponse.statusCode == 200) {
        setState(() {
          _elapsed = Duration.zero;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tempo enviado com sucesso!')),
          );
        }
      } else {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão: $e')),
        );
      }
    }

    if (mounted) Navigator.of(context).pop();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _toggleLockScreen() {
    setState(() => _isLocked = !_isLocked);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9900CC),
      body: SafeArea(
        child: Stack(
          children: [
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
                  if (!_isLocked)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                    )
                  else
                    const Icon(
                      Icons.lock,
                      size: 48,
                      color: Color(0xFF9900CC),
                    ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, size: 32, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: _isLocked ? Colors.grey : Colors.white,
                onPressed: _toggleLockScreen,
                child: Icon(
                  _isLocked ? Icons.lock_open : Icons.lock,
                  color: Color(0xFF9900CC),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
