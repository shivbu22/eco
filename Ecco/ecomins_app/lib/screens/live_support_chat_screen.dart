import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LiveSupportChatScreen extends StatelessWidget {
  const LiveSupportChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 20),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(backgroundColor: AppColors.surfaceContainerHighest, radius: 18, child: Icon(Icons.headset_mic, color: AppColors.onSurfaceVariant, size: 18)),
                Positioned(right: 0, bottom: 0, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: AppColors.surfaceContainerLow, width: 2))))),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Eco-Concierge Team', style: TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Typically replies in 2 mins', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Center(child: Text('Today 10:45 AM', style: TextStyle(color: Colors.grey, fontSize: 12))),
                const SizedBox(height: 24),
                _buildChatBubble('Hello! How can we help you make a greener impact today?', isMe: false),
                const SizedBox(height: 12),
                _buildChatBubble('I have a question about my recent bulk pickup order. The tracking says it is delayed.', isMe: true),
                const SizedBox(height: 12),
                _buildChatBubble('Can you provide the order ID?', isMe: false),
                const SizedBox(height: 12),
                _buildChatBubble('Sure, it is ECO-8832-MX', isMe: true),
                const SizedBox(height: 12),
                _buildChatBubble('Thank you. We are experiencing slightly higher traffic in your area for bulk recycling today, but our driver is en route. Expected delay is about 30 mins.', isMe: false),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow),
            child: SafeArea(
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(24)),
                      child: const TextField(
                        style: TextStyle(color: AppColors.onSurface),
                        decoration: InputDecoration(hintText: 'Type a message...', hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.send, color: AppColors.background, size: 18),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, {required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: isMe ? AppColors.background : AppColors.onSurface, fontSize: 14, height: 1.4, fontWeight: isMe ? FontWeight.w600 : FontWeight.normal),
        ),
      ),
    );
  }
}
