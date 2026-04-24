
// Import Flutter's Material Design widgets library
import 'package:flutter/material.dart';
// Import the notification model which contains the PendingRequest class
import 'package:import_export_app/models/notification_model.dart';
import 'package:import_export_app/services/api_service.dart';
import 'package:import_export_app/widgets/common/counter_row.dart'; // Import reusable widget
// Import intl package for date formatting (DateFormat class)
import 'package:intl/intl.dart';

// StatefulWidget: A widget that has mutable state (can change over time)
// This screen needs to track user inputs like counters and confirmation status
class CommandVerificationScreen extends StatefulWidget {
  // final: This property cannot be changed after initialization
  // PendingRequest: The data model containing all command/order information
  final PendingRequest request;

  // Constructor with named parameter 'request' which is required
  // Key: Used by Flutter to identify widgets in the widget tree for optimization
  const CommandVerificationScreen(
      {super.key,
      required this.request}); // Passes key to parent class constructor

  // Creates the mutable state for this widget
  // This method is called by Flutter framework when widget is inserted into tree
  @override
  State<CommandVerificationScreen> createState() =>
      _CommandVerificationScreenState();
}

// The State class contains the mutable state and build logic
// Underscore prefix (_) makes this class private to this file
class _CommandVerificationScreenState extends State<CommandVerificationScreen> {
  // State variables - these can change and trigger UI rebuilds

  // Counter for number of bars (equipment tracking)
  int _nombreBarres = 0;
  // Counter for number of straps (equipment tracking)
  int _nombreSangles = 0;
  int _nombreSuctionCups = 0;
  // TextEditingController: Manages text input field state
  // 'final' because the controller reference doesn't change, only its content
  final TextEditingController _commentaireController = TextEditingController();
  // Boolean flag to track if command is confirmed or not
  bool _estConfirme = false;
  // Loading state for API calls
  bool _isLoading = false;
  // Index of currently selected navigation item (0=home, 1=docs, 2=chat, 3=profile)
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize counters with data from request if available
    _nombreBarres = widget.request.barsCount ?? 0;
    _nombreSangles = widget.request.singlesCount ?? 0;
    _nombreSuctionCups= widget.request.suctionCupsCount ?? 0;
  }

  // dispose(): Called when this State object is removed permanently
  // Used to clean up resources to prevent memory leaks
  @override
  void dispose() {
    // Dispose the text controller to free up resources
    _commentaireController.dispose();
    // Always call super.dispose() at the end
    super.dispose();
  }

  // Increment the bars counter by 1
  // setState() notifies Flutter that state changed and UI needs rebuild
  void _incrementerBarres() {
    setState(() {
      _nombreBarres++; // Increment operator: adds 1 to current value
    });
  }

  // Decrement the bars counter, but only if > 0 (prevent negative values)
  void _decrementerBarres() {
    if (_nombreBarres > 0) {
      // Guard clause: only decrement if positive
      setState(() {
        _nombreBarres--; // Decrement operator: subtracts 1 from current value
      });
    }
  }

  // Increment the straps counter by 1
  void _incrementerSangles() {
    setState(() {
      _nombreSangles++;
    });
  }

  // Decrement the straps counter, but only if > 0
  void _decrementerSangles() {
    if (_nombreSangles > 0) {
      setState(() {
        _nombreSangles--;
      });
    }
  }
  void _incrementerSuctionCups() {
    setState(() {
      _nombreSuctionCups++;
    });
  }

  // Decrement the suction cups counter, but only if > 0
  void _decrementerSuctionCups() {
    if (_nombreSuctionCups > 0) {
      setState(() {
        _nombreSuctionCups--;
      });
    }
  }

  // Handler for "Confirm" button press
  // Sets confirmation status to true and shows feedback
  void _confirmer() {
    setState(() {
      _estConfirme = true;
    });
    // Show a brief notification at bottom of screen
    _showSnackBar('Commande confirmée !');
  }

  // Handler for "Not Confirmed" button press
  // Sets confirmation status to false and shows feedback
  void _nonConfirme() {
    setState(() {
      _estConfirme = false;
    });
    _showSnackBar('Commande non confirmée');
  }

  // Calculate number of days since the request was created
  // Used to show urgency/waiting time to user
  int _getDaysSinceCreation() {
    // DateTime.now(): Current date/time
    // difference(): Returns Duration between two dates
    // widget.request: Access the request passed to parent widget
    // inDays: Converts Duration to integer number of days
    return DateTime.now().difference(widget.request.createdAt).inDays;
  }

  // Handler for "Send" button - submits the verification data
  Future<void> _envoyer() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.handleDecision(
        requestType: widget.request.type,
        requestId: widget.request.id,
        decision: _estConfirme ? 'approved' : 'rejected',
        reason: _commentaireController.text,
        extraData: {
          'barsCount': _nombreBarres,
          'singlesCount': _nombreSangles,
          'suctionCupsCount': _nombreSuctionCups,
        },
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        _showSnackBar('Traitement effectué avec succès');
        // Delay slightly then close
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        _showDialog('Erreur', response['message'] ?? 'Une erreur est survenue');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showDialog('Erreur', 'Erreur de connexion');
      }
    }
  }

  // Display a SnackBar - a brief message at bottom of screen
  void _showSnackBar(String message) {
    // ScaffoldMessenger: Manages SnackBars for the current Scaffold
    // of(context): Gets the nearest ScaffoldMessenger from widget tree
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), // The message to display
        duration: const Duration(seconds: 1), // How long to show (1 second)
        backgroundColor: const Color(0xFF0C44A6),
      ),
    );
  }

  // Display an AlertDialog - a modal popup that requires user action
  void _showDialog(String title, String content) {
    showDialog(
      context: context, // Required to know where in widget tree to show dialog
      builder: (context) => AlertDialog(
        // builder: Function that returns the dialog widget
        title: Text(title), // Dialog title
        content: Text(content), // Dialog body content
        actions: [
          // List of action buttons at bottom of dialog
          TextButton(
            // Navigator.pop: Closes the dialog (removes from navigation stack)
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF0C44A6))),
          ),
        ],
      ),
    );
  }

  // build(): Main method that describes the UI
  // Called whenever setState() is called or widget needs to be rebuilt
  // Returns a Widget tree that Flutter renders on screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/backgrounds/login_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFF0C44A6),
                            size: 22,
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'AST',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Color(0xFF0C44A6),
                                  ),
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'Logitrack',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Color(0xFF0C44A6),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Commande à Vérifier',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0C44A6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'En cours · À valider',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 233, 244, 255),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time,
                              color: Colors.orange[700], size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'En cours',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.request.typeDisplayName} #${widget.request.id}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0C44A6),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy')
                                .format(widget.request.date),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (widget.request.transporter != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(Icons.local_shipping_outlined,
                                color: Colors.grey[500], size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.request.transporter!,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Icon(Icons.confirmation_number_outlined,
                            color: Colors.grey[500], size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'N° Remorque: ${widget.request.trailerNumber}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            color: Colors.grey[500], size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.request.entityName,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        Icon(Icons.access_time,
                            color: Colors.orange[400], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Validation attendue',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.orange[600], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Depuis ${_getDaysSinceCreation()}\njours',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange[600],
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: Colors.grey[500], size: 20),
                        const SizedBox(width: 10),
                        Text(
                          widget.request.country,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _confirmer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C44A6),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Confirmer',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _nonConfirme,
                            icon: const Icon(Icons.warning_amber_rounded,
                                size: 18),
                            label: const Text(
                              'Non confirmé',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB71C1C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    CounterRow(
                      title: 'Nombre de',
                      boldTitle: 'Barres',
                      value: _nombreBarres,
                      onIncrement: _incrementerBarres,
                      onDecrement: _decrementerBarres,
                    ),
                    const SizedBox(height: 16),
                    CounterRow(
                      title: 'Nombre de',
                      boldTitle: 'Sangles',
                      value: _nombreSangles,
                      onIncrement: _incrementerSangles,
                      onDecrement: _decrementerSangles,
                    ),
                    const SizedBox(height: 16),
                    CounterRow(
                      title: 'Nombre de',
                      boldTitle: 'Ventouses',
                      value: _nombreSuctionCups,
                      onIncrement: _incrementerSuctionCups,
                      onDecrement: _decrementerSuctionCups,
                    ),
                    const SizedBox(height: 24),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[800],
                        ),
                        children: const [
                          TextSpan(
                            text: 'Commentaire ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: '(optionnel)',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _commentaireController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        hintText: 'Ajouter une remarque...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF0C44A6),
                            width: 1.5,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _envoyer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C44A6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Envoyer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.home,
                      isSelected: _selectedNavIndex == 0,
                      onTap: () => setState(() => _selectedNavIndex = 0),
                    ),
                    _buildNavItemWithBadge(
                      icon: Icons.description_outlined,
                      badgeCount: 3,
                      isSelected: _selectedNavIndex == 1,
                      onTap: () => setState(() => _selectedNavIndex = 1),
                    ),
                    _buildNavItem(
                      icon: Icons.chat_bubble_outline,
                      isSelected: _selectedNavIndex == 2,
                      onTap: () => setState(() => _selectedNavIndex = 2),
                    ),
                    _buildNavItem(
                      icon: Icons.person_outline,
                      isSelected: _selectedNavIndex == 3,
                      onTap: () => setState(() => _selectedNavIndex = 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ HELPER METHOD: BUILD NAVIGATION ITEM ============
  // Creates a simple navigation icon button
  Widget _buildNavItem({
    required IconData icon, // IconData: Describes an icon from Material Icons
    required bool isSelected, // Whether this nav item is currently active
    required VoidCallback onTap, // Callback when tapped
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12), // Rounded ripple effect
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          // Conditional color: blue if selected, grey otherwise
          color: isSelected ? const Color(0xFF0C44A6) : Colors.grey[400],
          size: 26,
        ),
      ),
    );
  }

  // ============ HELPER METHOD: BUILD NAVIGATION ITEM WITH BADGE ============
  // Creates a navigation icon with a notification badge (red circle with number)
  Widget _buildNavItemWithBadge({
    required IconData icon,
    required int badgeCount, // Number to display on badge
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        // Stack: Overlays children on top of each other
        child: Stack(
          // Clip.none: Allow badge to extend outside Stack bounds
          clipBehavior: Clip.none,
          children: [
            // Base icon
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0C44A6) : Colors.grey[400],
              size: 26,
            ),
            // Badge (only shown if count > 0)
            if (badgeCount > 0)
              // Positioned: Places child at specific position within Stack
              Positioned(
                right: -8, // Offset to right of icon
                top: -6, // Offset above icon
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red, // Red notification color
                    shape: BoxShape.circle, // Circular shape
                  ),
                  // BoxConstraints: Minimum size constraints
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      '$badgeCount', // Display the count number
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
