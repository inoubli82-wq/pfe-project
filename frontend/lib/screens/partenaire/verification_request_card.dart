import 'package:flutter/material.dart';
import 'package:import_export_app/models/notification_model.dart';
import 'package:import_export_app/services/api_service.dart';
import 'package:import_export_app/widgets/common/counter_row.dart';
import 'package:import_export_app/widgets/widgets.dart';

import 'command_verification_screen.dart';

class VerificationRequestCard extends StatefulWidget {
  final PendingRequest request;
  final VoidCallback onRefresh;

  const VerificationRequestCard({
    super.key,
    required this.request,
    required this.onRefresh,
  });

  @override
  State<VerificationRequestCard> createState() =>
      _VerificationRequestCardState();
}

class _VerificationRequestCardState extends State<VerificationRequestCard> {
  int _barsCount = 0;
  int _strapsCount = 0;
  bool _isLoading = false;
  bool _showRejectComment = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with data from the request if available
    _barsCount = widget.request.barsCount ?? 0;
    _strapsCount = widget.request.singlesCount ?? 0;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _incrementBars() => setState(() => _barsCount++);
  void _decrementBars() {
    if (_barsCount > 0) setState(() => _barsCount--);
  }

  void _incrementStraps() => setState(() => _strapsCount++);
  void _decrementStraps() {
    if (_strapsCount > 0) setState(() => _strapsCount--);
  }

  Future<void> _handleDecision(String decision) async {
    if (decision == 'rejected') {
      if (!_showRejectComment) {
        setState(() => _showRejectComment = true);
        return;
      }
      if (_commentController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez entrer une raison de refus'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.handleDecision(
        requestType: widget.request.type,
        requestId: widget.request.id,
        decision: decision,
        reason: decision == 'rejected' ? _commentController.text.trim() : null,
        extraData: {
          'barsCount': _barsCount,
          'singlesCount': _strapsCount,
        },
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(decision == 'approved'
                ? 'Demande approuvée'
                : 'Demande refusée'),
            backgroundColor: decision == 'approved' ? Colors.green : Colors.red,
          ),
        );
        widget.onRefresh();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Erreur'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur connexion')),
        );
      }
    }
  }

  void _openDetailScreen() {
    // If we want to pass the drafted values, we handle it here
    // or just open for details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CommandVerificationScreen(request: widget.request),
      ),
    ).then((_) => widget.onRefresh());
  }

  @override
  Widget build(BuildContext context) {
    // We use the existing RequestCard but enhance the trailing section
    return RequestCard(
      type: widget.request.type,
      trailerNumber: widget.request.trailerNumber,
      entityName: widget.request.entityName,
      country: widget.request.country,
      date: widget.request.date,
      status: widget.request.status,
      approvalStatus: widget.request.approvalStatus,
      createdByName: widget.request.createdByName,
      onTap: _openDetailScreen,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 24),
          // Counters Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                CounterRow(
                  title: 'Nombre de',
                  boldTitle: 'Barres',
                  value: _barsCount,
                  onIncrement: _incrementBars,
                  onDecrement: _decrementBars,
                ),
                const SizedBox(height: 12),
                CounterRow(
                  title: 'Nombre de',
                  boldTitle: 'Sangles',
                  value: _strapsCount,
                  onIncrement: _incrementStraps,
                  onDecrement: _decrementStraps,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Reason input (conditionally shown)
          if (_showRejectComment) ...[
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Motif du refus',
                hintText: 'Saisissez la raison...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.red[50],
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
          ],
          // Action Buttons
          Row(
            children: [
              if (!_showRejectComment)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isLoading ? null : () => _handleDecision('approved'),
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Approuver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              if (!_showRejectComment) const SizedBox(width: 12),
              if (_showRejectComment)
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showRejectComment = false;
                        _commentController.clear();
                      });
                    },
                    child: const Text('Annuler',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
              if (_showRejectComment) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _isLoading ? null : () => _handleDecision('rejected'),
                  icon: const Icon(Icons.close, size: 20),
                  label: Text(
                      _showRejectComment ? 'Confirmer le refus' : 'Refuser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .red, // Updated to match user expectation (red button)
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
