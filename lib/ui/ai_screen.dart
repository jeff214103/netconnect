import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:netconnect/provider/data_provider.dart';
import 'package:netconnect/services/gemini_service.dart';
import 'package:provider/provider.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final _queryController = TextEditingController();
  String? _answer;
  String? _dupeResult;
  bool _isLoading = false;
  bool _isCheckingDupes = false;

  Future<void> _handleAsk() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _answer = null;
    });

    final provider = context.read<DataProvider>();
    final result = await GeminiService.searchNaturalLanguage(
      query: query,
      contacts: provider.contacts,
      events: provider.events,
    );

    setState(() {
      _answer = result;
      _isLoading = false;
    });
  }

  Future<void> _handleCheckDuplicates() async {
    setState(() {
      _isCheckingDupes = true;
      _dupeResult = null;
    });

    final provider = context.read<DataProvider>();
    final result = await GeminiService.checkDuplicates(
      contacts: provider.contacts,
    );

    setState(() {
      _dupeResult = result;
      _isCheckingDupes = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ask AI',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  // Maintenance Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.indigo.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.cleaning_services,
                                color: Colors.indigo.shade900),
                            const SizedBox(width: 8),
                            Text(
                              'Maintenance',
                              style: TextStyle(
                                  color: Colors.indigo.shade900,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use AI to scan your contact list for fuzzy duplicates.',
                          style: TextStyle(color: Colors.indigo.shade700),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed:
                                _isCheckingDupes ? null : _handleCheckDuplicates,
                            child: Text(_isCheckingDupes
                                ? 'Scanning...'
                                : 'Check Duplicates'),
                          ),
                        ),
                        if (_dupeResult != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.indigo.shade100),
                            ),
                            child: MarkdownBody(data: _dupeResult!),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Answer Section
                  if (_answer != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI ANSWER',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                          const SizedBox(height: 8),
                          MarkdownBody(data: _answer!),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Input Section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: InputDecoration(
                      hintText:
                          "Ask: 'Who did I meet at the React Summit?' or 'Who works as a designer?'",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onSubmitted: (_) => _handleAsk(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: _isLoading ? null : _handleAsk,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
