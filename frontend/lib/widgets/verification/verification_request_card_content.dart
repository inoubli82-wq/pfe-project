import 'package:flutter/material.dart';
import 'package:import_export_app/models/notification_model.dart';
import 'package:import_export_app/widgets/common/counter_row.dart';
import 'package:import_export_app/widgets/widgets.dart';

class VerificationRequestCardContent extends StatelessWidget {
  final PendingRequest request;
  final int barsCount;
  final int strapsCount;
  final bool isLoading;
  final bool showRejectComment;
  final TextEditingController commentController;
  final VoidCallback onOpenDetail;
  final VoidCallback onIncrementBars;
  final VoidCallback onDecrementBars;
  final VoidCallback onIncrementStraps;
  final VoidCallback onDecrementStraps;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onCancelReject;

  const VerificationRequestCardContent({
    super.key,
    required this.request,
    required this.barsCount,
    required this.strapsCount,
    required this.isLoading,
    required this.showRejectComment,
    required this.commentController,
    required this.onOpenDetail,
    required this.onIncrementBars,
    required this.onDecrementBars,
    required this.onIncrementStraps,
    required this.onDecrementStraps,
    required this.onApprove,
    required this.onReject,
    required this.onCancelReject,
  });

  @override
  Widget build(BuildContext context) {
    return RequestCard(
      type: request.type,
      trailerNumber: request.trailerNumber,
      entityName: request.entityName,
      country: request.country,
      date: request.date,
      status: request.status,
      approvalStatus: request.approvalStatus,
      createdByName: request.createdByName,
      onTap: onOpenDetail,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 24),
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
                  value: barsCount,
                  onIncrement: onIncrementBars,
                  onDecrement: onDecrementBars,
                ),
                const SizedBox(height: 12),
                CounterRow(
                  title: 'Nombre de',
                  boldTitle: 'Sangles',
                  value: strapsCount,
                  onIncrement: onIncrementStraps,
                  onDecrement: onDecrementStraps,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (showRejectComment) ...[
            TextField(
              controller: commentController,
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
          LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxWidth < 560;

              final approveButton = ElevatedButton.icon(
                onPressed: isLoading ? null : onApprove,
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
              );

              final rejectButton = ElevatedButton.icon(
                onPressed: isLoading ? null : onReject,
                icon: const Icon(Icons.close, size: 20),
                label: Text(
                  showRejectComment
                      ? (compact ? 'Confirmer' : 'Confirmer le refus')
                      : 'Refuser',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!showRejectComment) approveButton,
                    if (!showRejectComment) const SizedBox(height: 10),
                    if (showRejectComment)
                      TextButton(
                        onPressed: onCancelReject,
                        child: const Text(
                          'Annuler',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    if (showRejectComment) const SizedBox(height: 10),
                    rejectButton,
                  ],
                );
              }

              return Row(
                children: [
                  if (!showRejectComment) Expanded(child: approveButton),
                  if (!showRejectComment) const SizedBox(width: 12),
                  if (showRejectComment)
                    Expanded(
                      child: TextButton(
                        onPressed: onCancelReject,
                        child: const Text(
                          'Annuler',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  if (showRejectComment) const SizedBox(width: 12),
                  Expanded(child: rejectButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
