import 'package:flutter/material.dart';
import 'package:import_export_app/models/notification_model.dart';
import 'package:import_export_app/services/api_service.dart';
import 'package:import_export_app/widgets/verification/verification_request_card_content.dart';

import '../partenaire/command_verification_screen.dart';

class AgentImportVerificationRequestCard extends StatefulWidget {
  final PendingRequest request;
  final VoidCallback onRefresh;

  const AgentImportVerificationRequestCard({
    super.key,
    required this.request,
    required this.onRefresh,
  });

  @override
  State<AgentImportVerificationRequestCard> createState() =>
      _AgentImportVerificationRequestCardState();
}

class _AgentImportVerificationRequestCardState
    extends State<AgentImportVerificationRequestCard> {
  int _barsCount = 0;
  int _strapsCount = 0;
  bool _isLoading = false;
  bool _showRejectComment = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    if (widget.request.type != 'export') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Agent import: uniquement les demandes export partenaire sont autorisees',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
          'sourceTable': widget.request.sourceTable,
        },
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              decision == 'approved'
                  ? 'Demande export partenaire approuvee'
                  : 'Demande export partenaire refusee',
            ),
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
    return VerificationRequestCardContent(
      request: widget.request,
      barsCount: _barsCount,
      strapsCount: _strapsCount,
      isLoading: _isLoading,
      showRejectComment: _showRejectComment,
      commentController: _commentController,
      onOpenDetail: _openDetailScreen,
      onIncrementBars: _incrementBars,
      onDecrementBars: _decrementBars,
      onIncrementStraps: _incrementStraps,
      onDecrementStraps: _decrementStraps,
      onApprove: () => _handleDecision('approved'),
      onReject: () => _handleDecision('rejected'),
      onCancelReject: () {
        setState(() {
          _showRejectComment = false;
          _commentController.clear();
        });
      },
    );
  }
}
