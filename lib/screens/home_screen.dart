import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:card_random/services/txt_card_parser.dart';
import 'package:card_random/services/history_service.dart';

class CardChallengeScreen extends StatefulWidget {
  const CardChallengeScreen({super.key});

  @override
  State<CardChallengeScreen> createState() => _CardChallengeScreenState();
}

class _CardChallengeScreenState extends State<CardChallengeScreen> with TickerProviderStateMixin {
  String challengeText = '[Nội dung thử thách]';
  bool overlayVisible = false;
  String overlayCard = '';
  String overlayChallenge = '';
  bool showMenu = false;
  Map<String, String> cardChallenges = {};

  // Store the current suit for proper coloring
  String? currentSuit;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _cardAppearController;
  late Animation<double> _cardAppearAnimation;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    // Rung đều từ đầu đến cuối bằng Curves.linear
    _shakeAnimation = Tween<double>(begin: 0, end: 4).chain(CurveTween(curve: Curves.linear)).animate(_shakeController);
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });
    // Card appear animation
    _cardAppearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _cardAppearAnimation = Tween<double>(begin: 200, end: 0).chain(CurveTween(curve: Curves.easeOutBack)).animate(_cardAppearController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _cardAppearController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenges() async {
    final map = await TxtCardParser.parseDynamic();
    setState(() {
      cardChallenges = map;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDefault = challengeText == '[Nội dung thử thách]';
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9A9E),
        elevation: 0,
        leadingWidth: 150,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () => setState(() => showMenu = !showMenu),
            ),
            if (showMenu) ...[
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: _openSettings,
              ),
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/history'),
              ),
            ],
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Bấm 2 lần vào bộ bài\nđể nhận thử thách',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFe6B6B),
                    height: 1.3,
                    shadows: [
                      Shadow(offset: Offset(-0.5, -0.5), color: Color(0xFFF39595)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: GestureDetector(
                    onDoubleTap: _onDeckDoubleTap,
                    child: AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value * (DateTime.now().millisecond % 2 == 0 ? 1 : -1), 0),
                          child: child,
                        );
                      },
                      child: Image.asset(
                        'lib/assets/images/deck.png',
                        width: 220,
                        height: 250,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 0),
                Container(
                  width: double.infinity,
                  height: 255,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: isDefault
                        ? TextSpan(
                            text: challengeText,
                            style: GoogleFonts.robotoCondensed(
                              fontSize: 22,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.normal,
                            ),
                          )
                        : _buildChallengeTextSpan(challengeText),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          if (overlayVisible) Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: const Color.fromRGBO(0, 0, 0, 0.5)),
            ),
          ),
          if (overlayVisible) Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AnimatedBuilder(
                animation: _cardAppearController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _cardAppearAnimation.value),
                    child: Opacity(
                      opacity: 1 - (_cardAppearAnimation.value / 100).clamp(0, 1),
                      child: child,
                    ),
                  );
                },
                child: Image.asset(overlayCard, width: 220, height: 250),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: _buildChallengeTextSpan(overlayChallenge),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() => overlayVisible = false),
                child: const Text('Close'),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _showChallenge() {
    if (cardChallenges.isEmpty) return;
    final suits = ['♣','♦','♥','♠'];
    final ranks = ['A','2','3','4','5','6','7','8','9','10','J','Q','K'];
    final suit = suits[DateTime.now().second % suits.length];
    final rank = ranks[DateTime.now().millisecond % ranks.length];
    final cardKey = '$rank$suit';
    final challenge = cardChallenges[cardKey] ?? '[Không có thử thách cho lá này]';
    final cardPath = 'lib/assets/images/cards/${_suitName(suit)}_$rank.png';

    final categoryInfo = _getCategoryInfo(suit);
    final categoryText = categoryInfo['text'];
    final displayChallenge = '$categoryText $challenge';

    setState(() {
      currentSuit = suit;
      challengeText = displayChallenge;
      overlayChallenge = displayChallenge;
      overlayCard = cardPath;
      overlayVisible = true;
    });
    _cardAppearController.reset();
    _cardAppearController.forward();

    HistoryService().add(cardKey, displayChallenge);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🎉 Bạn đã nhận được thử thách mới!'),
        backgroundColor: const Color(0xFFFF9A9E),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _openSettings() async {
    final result = await Navigator.pushNamed(context, '/settings');
    if (result == true) {
      _loadChallenges();
    }
  }

  String _suitName(String suit) {
    switch (suit) {
      case '♣': return 'clubs';
      case '♦': return 'diamonds';
      case '♥': return 'hearts';
      case '♠': return 'spades';
      default: return 'unknown';
    }
  }

  // Helper method to get category text and color based on suit
  Map<String, dynamic> _getCategoryInfo(String suit) {
    switch (suit) {
      case '♠':
        return {'text': '[Thể chất]', 'color': Colors.black};
      case '♦':
        return {'text': '[Trí tuệ]', 'color': Colors.orange}; // diamond: Trí tuệ
      case '♥':
        return {'text': '[Tình cảm]', 'color': Colors.red};
      case '♣':
        return {'text': '[Kỹ năng]', 'color': Colors.green}; // clubs: Kỹ năng
      default:
        return {'text': '', 'color': Colors.black};
    }
  }

  TextSpan _buildChallengeTextSpan(String text) {
    if (currentSuit == null) {
      return TextSpan(
        text: text,
        style: GoogleFonts.robotoCondensed(
          fontSize: 22,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    // Extract the category part (in []) and the rest as content
    final categoryMatch = RegExp(r'^(\[[^\]]+\])').firstMatch(text);
    String categoryPart = '';
    String remainingText = text;
    if (categoryMatch != null) {
      categoryPart = categoryMatch.group(1)!;
      remainingText = text.substring(categoryPart.length).trim();
    }
    final categoryColor = _getCategoryInfo(currentSuit!)['color'];
    return TextSpan(
      children: [
        TextSpan(
          text: categoryPart + '\n',
          style: GoogleFonts.robotoCondensed(
            fontSize: 22,
            color: categoryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: remainingText,
          style: GoogleFonts.robotoCondensed(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
      style: GoogleFonts.robotoCondensed(fontSize: 22),
    );
  }

  void _onDeckDoubleTap() {
    _shakeController.forward();
    Future.delayed(const Duration(milliseconds: 1500), () {
      _showChallenge();
    });
  }
}
