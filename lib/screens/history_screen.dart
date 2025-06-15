import 'package:flutter/material.dart';
import 'package:card_random/services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final historyItems = HistoryService().items;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9A9E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: historyItems.length,
        itemBuilder: (context, index) {
          final item = historyItems[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  item.card,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: item.card.contains('♥') || item.card.contains('♦')
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: RichText(
                    text: _buildChallengeTextSpan(item.challenge, item.card),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  TextSpan _buildChallengeTextSpan(String text, String card) {
    // Extract the suit from the card string
    String? suit;
    if (card.contains('♠')) suit = '♠';
    else if (card.contains('♥')) suit = '♥';
    else if (card.contains('♦')) suit = '♦';
    else if (card.contains('♣')) suit = '♣';
    // Extract the category part (in []) and the rest as content
    final categoryMatch = RegExp(r'^(\[[^\]]+\])').firstMatch(text);
    String categoryPart = '';
    String remainingText = text;
    if (categoryMatch != null) {
      categoryPart = categoryMatch.group(1)!;
      remainingText = text.substring(categoryPart.length).trim();
    }
    final categoryColor = _getCategoryColor(suit);
    return TextSpan(
      children: [
        TextSpan(
          text: categoryPart + '\n',
          style: TextStyle(
            fontSize: 16,
            color: categoryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: remainingText,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String? suit) {
    switch (suit) {
      case '♠':
        return Colors.black;   // spades: Thể chất
      case '♦':
        return Colors.orange; // diamonds: Trí tuệ
      case '♥':
        return Colors.red;    // hearts: Tình cảm
      case '♣':
        return Colors.green; // clubs: Kỹ năng
      default:
        return Colors.black;
    }
  }
}
