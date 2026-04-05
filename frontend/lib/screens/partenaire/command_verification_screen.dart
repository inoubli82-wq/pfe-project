// ===========================================
// COMMAND VERIFICATION SCREEN
// ===========================================
// This screen allows partners to verify and validate import/export commands
// It displays command details and lets users confirm or reject orders

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
        backgroundColor: Colors.blue[800], // Background color (dark blue)
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
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
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
    // Scaffold: Basic Material Design layout structure
    // Provides standard app structure with appbar, body, drawer, etc.
    return Scaffold(
      // Column: Arranges children vertically from top to bottom
      body: Column(
        children: [
          // ============ HEADER SECTION ============
          // Container: A convenience widget that combines common painting,
          // positioning, and sizing widgets
          Container(
            // BoxDecoration: Controls how to paint the container's box
            decoration: const BoxDecoration(
              // DecorationImage: Paints an image as the background
              image: DecorationImage(
                // AssetImage: Loads image from app's assets folder
                image: AssetImage(
                    'assets/images/backgrounds/login_background.jpg'),
                // BoxFit.cover: Scales image to fill container while preserving aspect ratio
                fit: BoxFit.cover,
              ),
            ),
            // SafeArea: Insets child to avoid OS intrusions (notch, status bar, etc.)
            child: SafeArea(
              bottom:
                  false, // Don't add padding at bottom (only top for status bar)
              // Column: Vertical arrangement of header elements
              child: Column(
                // CrossAxisAlignment.start: Align children to left edge
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============ CUSTOM APP BAR ============
                  // Padding: Adds empty space around child widget
                  Padding(
                    // EdgeInsets.symmetric: Same padding on opposite sides
                    // horizontal: left & right, vertical: top & bottom
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    // Row: Arranges children horizontally from left to right
                    child: Row(
                      children: [
                        // Back button to navigate to previous screen
                        IconButton(
                          // Arrow function: () => expression (shorthand for single statement)
                          // Navigator.pop: Go back to previous screen
                          onPressed: () => Navigator.pop(context),
                          // Icon widget with iOS-style back arrow
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Color(0xFF0C44A6), // Hex color: dark blue
                              size: 22),
                        ),
                        // Expanded: Takes up remaining horizontal space
                        Expanded(
                          // Center: Centers its child within available space
                          child: Center(
                            child: Row(
                              // MainAxisSize.min: Row shrinks to fit children
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // App name "AST" - bold style
                                Text(
                                  'AST',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, // Bold text
                                    fontSize: 22,
                                    color: Colors
                                        .blue[900], // Material blue shade 900
                                  ),
                                ),
                                const SizedBox(
                                    width: 2), // Small horizontal spacer
                                // App name continuation "Logitrack" - italic style
                                Text(
                                  'Logitrack',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.w500, // Medium weight
                                    fontSize: 18,
                                    color: Colors.blue[900],
                                    fontStyle: FontStyle.italic, // Italic text
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Empty box for symmetry (balances the back button width)
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // ============ TITLE SECTION ============
                  Padding(
                    // EdgeInsets.fromLTRB: Left, Top, Right, Bottom padding
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main title text
                        const Text(
                          'Commande à Vérifier', // "Order to Verify"
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E), // Indigo 900
                          ),
                        ),
                        const SizedBox(height: 4), // Vertical spacer
                        // Subtitle with status
                        Text(
                          'En cours · À valider', // "In progress · To validate"
                          style: TextStyle(
                            color: Colors.grey[600], // Grey shade 600
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

          // ============ MAIN CONTENT CARD ============
          // Expanded: Takes remaining vertical space in the Column
          Expanded(
            // Container for the white card content area
            child: Container(
              // double.infinity: Take full available width
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white, // White background
                // BorderRadius.only: Round specific corners only
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24), // Rounded top corners
                  topRight: Radius.circular(24),
                ),
              ),
              // SingleChildScrollView: Makes content scrollable if it overflows
              child: SingleChildScrollView(
                // EdgeInsets.all: Same padding on all 4 sides
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ============ STATUS BADGE ============
                    // "En cours" (In Progress) status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        // withOpacity: Makes color semi-transparent (0.1 = 10% opacity)
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20), // Pill shape
                        // Border.all: Same border on all sides
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        // MainAxisSize.min: Shrink to fit content
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Clock icon for "in progress" status
                          Icon(Icons.access_time,
                              color: Colors.orange[700], size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'En cours', // "In Progress"
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w600, // Semi-bold
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ============ ORDER HEADER ROW ============
                    Row(
                      // MainAxisAlignment.spaceBetween: Space children at ends
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Order type and ID (e.g., "Export #123")
                        // widget.request accesses data from parent widget
                        Text(
                          '${widget.request.typeDisplayName} #${widget.request.id}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        // Date badge container
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100], // Light grey background
                            borderRadius: BorderRadius.circular(6),
                            // Border with ! null assertion (we know grey[300] exists)
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            // DateFormat: Formats DateTime to string
                            // 'dd/MM/yyyy' = day/month/year format
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

                    // ============ TRANSPORTER INFO (CONDITIONAL) ============
                    // if statement: Only show this widget if transporter exists
                    // != null checks if transporter has a value
                    if (widget.request.transporter != null)
                      Padding(
                        // EdgeInsets.only: Padding on specific sides only
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            // Truck icon for transporter
                            Icon(Icons.local_shipping_outlined,
                                color: Colors.grey[500], size: 20),
                            const SizedBox(width: 10),
                            // Expanded: Text takes remaining space, can wrap if needed
                            Expanded(
                              child: Text(
                                // ! null assertion: We know it's not null from if check
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

                    // ============ TRAILER NUMBER ROW ============
                    Row(
                      children: [
                        // Confirmation number icon
                        Icon(Icons.confirmation_number_outlined,
                            color: Colors.grey[500], size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'N° Remorque: ${widget.request.trailerNumber}', // "Trailer #:"
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ============ CLIENT/SUPPLIER ROW WITH VALIDATION INFO ============
                    Row(
                      children: [
                        // Person icon for client/supplier
                        Icon(Icons.person_outline,
                            color: Colors.grey[500], size: 20),
                        const SizedBox(width: 10),
                        // Entity name (client or supplier name)
                        Expanded(
                          child: Text(
                            widget.request.entityName,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        // Clock icon for "waiting" status
                        Icon(Icons.access_time,
                            color: Colors.orange[400], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Validation attendue', // "Validation expected"
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Warning icon showing urgency
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.orange[600], size: 16),
                        const SizedBox(width: 4),
                        // Days waiting counter
                        Text(
                          'Depuis ${_getDaysSinceCreation()}\njours', // "Since X days"
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange[600],
                            height: 1.2, // Line height multiplier
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ============ LOCATION ROW ============
                    Row(
                      children: [
                        // Location pin icon
                        Icon(Icons.location_on_outlined,
                            color: Colors.grey[500], size: 20),
                        const SizedBox(width: 10),
                        Text(
                          widget.request.country, // Country name
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ============ CONFIRM/REJECT BUTTONS ROW ============
                    Row(
                      children: [
                        // Expanded: Button takes half the available width
                        Expanded(
                          // ElevatedButton: Raised button with elevation
                          child: ElevatedButton(
                            onPressed: _confirmer, // Callback when pressed
                            // styleFrom: Factory method to create button style
                            style: ElevatedButton.styleFrom(
                              // Ternary operator: condition ? valueIfTrue : valueIfFalse
                              // Both conditions return same color (could be simplified)
                              backgroundColor: _estConfirme
                                  ? const Color(0xFF0D47A1)
                                  : const Color(0xFF0D47A1), // Dark blue
                              foregroundColor: Colors.white, // Text/icon color
                              // RoundedRectangleBorder: Rectangle with rounded corners
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0, // No shadow
                            ),
                            child: const Text(
                              'Confirmer', // "Confirm"
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                            width: 12), // Horizontal space between buttons
                        // Second button (Not Confirmed)
                        Expanded(
                          // ElevatedButton.icon: Button with icon and label
                          child: ElevatedButton.icon(
                            onPressed: _nonConfirme,
                            // Warning icon
                            icon: const Icon(Icons.warning_amber_rounded,
                                size: 18),
                            label: const Text(
                              'Non confirmé', // "Not confirmed"
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFB71C1C), // Dark red
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

                    // ============ COUNTER SECTION - BARS ============
                    // Custom widget to display counter for "Barres" (bars)
                    CounterRow(
                      title: 'Nombre de', // "Number of"
                      boldTitle: 'Barres', // "Bars" (equipment)
                      value: _nombreBarres, // Current count
                      onIncrement: _incrementerBarres, // + button callback
                      onDecrement: _decrementerBarres, // - button callback
                    ),
                    const SizedBox(height: 16),

                    // ============ COUNTER SECTION - STRAPS ============
                    // Custom widget to display counter for "Sangles" (straps)
                    CounterRow(
                      title: 'Nombre de',
                      boldTitle: 'Sangles', // "Straps" (equipment)
                      value: _nombreSangles,
                      onIncrement: _incrementerSangles,
                      onDecrement: _decrementerSangles,
                    ),
                    const SizedBox(height: 24),

                    // ============ COMMENT SECTION LABEL ============
                    // RichText: Allows different styles within same text block
                    RichText(
                      // TextSpan: A segment of text with its own style
                      text: TextSpan(
                        // Default style for all text
                        style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                        children: const [
                          // First part: bold "Commentaire"
                          TextSpan(
                            text: 'Commentaire ', // "Comment"
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          // Second part: normal "(optionnel)"
                          TextSpan(
                            text: '(optionnel)', // "(optional)"
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ============ COMMENT TEXT INPUT FIELD ============
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
                              color: Color(0xFF0D47A1), width: 1.5),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ============ SEND BUTTON ============
                    // SizedBox: Fixed/constrained size widget
                    SizedBox(
                      width: double.infinity, // Full width button
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : _envoyer, // Submit callback
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1), // Dark blue
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
                                'Envoyer', // "Send"
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

          // ============ BOTTOM NAVIGATION BAR ============
          // Container with shadow for navigation bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              // BoxShadow: Adds shadow effect
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.05), // 5% black = subtle shadow
                  blurRadius: 10, // How spread out the shadow is
                  offset: const Offset(
                      0, -5), // Shadow position (x, y) - above container
                ),
              ],
            ),
            // SafeArea: Avoid bottom system UI (home indicator on iPhone X+)
            child: SafeArea(
              top: false, // Only add padding at bottom
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                // Row of navigation items
                child: Row(
                  // spaceAround: Equal space between and around items
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Home nav item (index 0)
                    _buildNavItem(
                      icon: Icons.home,
                      // Check if this item is currently selected
                      isSelected: _selectedNavIndex == 0,
                      // Update selected index when tapped
                      onTap: () => setState(() => _selectedNavIndex = 0),
                    ),
                    // Documents nav item with notification badge (index 1)
                    _buildNavItemWithBadge(
                      icon: Icons.description_outlined,
                      badgeCount: 3, // Number shown on badge
                      isSelected: _selectedNavIndex == 1,
                      onTap: () => setState(() => _selectedNavIndex = 1),
                    ),
                    // Chat nav item (index 2)
                    _buildNavItem(
                      icon: Icons.chat_bubble_outline,
                      isSelected: _selectedNavIndex == 2,
                      onTap: () => setState(() => _selectedNavIndex = 2),
                    ),
                    // Profile nav item (index 3)
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
          color: isSelected ? const Color(0xFF0D47A1) : Colors.grey[400],
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
              color: isSelected ? const Color(0xFF0D47A1) : Colors.grey[400],
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
