// ===========================================
// DIALOG WIDGETS
// ===========================================

import 'package:flutter/material.dart';

// ===========================================
// CONFIRMATION DIALOG
// ===========================================
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirmer',
    this.cancelText = 'Annuler',
    this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

// ===========================================
// REJECTION REASON DIALOG
// ===========================================
class RejectionReasonDialog extends StatefulWidget {
  final Function(String reason) onSubmit;

  const RejectionReasonDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<RejectionReasonDialog> createState() => _RejectionReasonDialogState();

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Raison du refus'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Entrez la raison du refus...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = controller.text.trim();
                if (reason.isNotEmpty) {
                  Navigator.pop(context, reason);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Refuser'),
            ),
          ],
        );
      },
    );
  }
}

class _RejectionReasonDialogState extends State<RejectionReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Raison du refus'),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Entrez la raison du refus...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            final reason = _controller.text.trim();
            if (reason.isNotEmpty) {
              widget.onSubmit(reason);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Refuser'),
        ),
      ],
    );
  }
}

// ===========================================
// LOADING DIALOG
// ===========================================
class LoadingDialog {
  static void show(BuildContext context, {String message = 'Chargement...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

// ===========================================
// SUCCESS/ERROR SNACKBAR
// ===========================================
class AppSnackBar {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF0C44A6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}

// ===========================================
// REQUEST DETAIL DIALOG
// ===========================================
class RequestDetailDialog extends StatelessWidget {
  final String type;
  final String trailerNumber;
  final String entityName;
  final String country;
  final String? transporter;
  final String date;
  final String status;
  final String approvalStatus;
  final String? createdByName;
  final String? notes;
  final bool showApprovalButtons;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const RequestDetailDialog({
    super.key,
    required this.type,
    required this.trailerNumber,
    required this.entityName,
    required this.country,
    this.transporter,
    required this.date,
    required this.status,
    required this.approvalStatus,
    this.createdByName,
    this.notes,
    this.showApprovalButtons = false,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isExport = type == 'export';
    final color = isExport ? Colors.green : const Color(0xFF0C44A6);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isExport ? Icons.upload : Icons.download,
            color: color,
          ),
          const SizedBox(width: 10),
          Text('Détails ${isExport ? "Export" : "Import"}'),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailItem('N° Remorque', trailerNumber),
            _buildDetailItem(
              isExport ? 'Client' : 'Fournisseur',
              entityName,
            ),
            _buildDetailItem('Pays', country),
            if (transporter != null && transporter!.isNotEmpty)
              _buildDetailItem('Transporteur', transporter!),
            _buildDetailItem('Date', date),
            _buildDetailItem('Statut', status),
            _buildDetailItem('Approbation', _getApprovalText()),
            if (createdByName != null)
              _buildDetailItem('Créé par', createdByName!),
            if (notes != null && notes!.isNotEmpty)
              _buildDetailItem('Notes', notes!),
          ],
        ),
      ),
      actions: [
        if (showApprovalButtons && approvalStatus == 'pending') ...[
          TextButton(
            onPressed: onReject,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Refuser'),
          ),
          ElevatedButton(
            onPressed: onApprove,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approuver'),
          ),
        ] else
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _getApprovalText() {
    switch (approvalStatus) {
      case 'approved':
        return 'Approuvé ✅';
      case 'rejected':
        return 'Refusé ❌';
      default:
        return 'En attente ⏳';
    }
  }
}
