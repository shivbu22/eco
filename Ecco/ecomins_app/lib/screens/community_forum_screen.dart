import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CommunityForumScreen extends StatelessWidget {
  const CommunityForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 20),
        ),
        title: const Text('Community Board', style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.edit_square, color: AppColors.primary)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: AppColors.onSurfaceVariant, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Search discussions...',
                      hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          _buildPostItem(
            author: 'EcoWarrior22',
            time: '2h ago',
            tag: 'Local Cleanup',
            title: 'Downtown Community Park Cleanup this Saturday!',
            body: 'Hey everyone, we are organizing a local cleanup at the central park. We already have 15 volunteers but need more hands. Trash bags and tools provided!',
            upvotes: 124,
            comments: 45,
            isHot: true,
          ),
          _buildPostItem(
            author: 'GreenThumb90',
            time: '5h ago',
            tag: 'Tips & Tricks',
            title: 'Composting in a small apartment without smells?',
            body: 'I really want to start composting but I live in a 1-bedroom. What are the best indoor bins that don\'t attract bugs or smell bad?',
            upvotes: 89,
            comments: 21,
            isHot: false,
          ),
          _buildPostItem(
            author: 'AlexB',
            time: '1d ago',
            tag: 'News',
            title: 'City council approves new solar subsidies',
            body: 'Great news for local residents, the council just approved the new energy bill giving massive subsidies for home solar panels.',
            upvotes: 342,
            comments: 112,
            isHot: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem({required String author, required String time, required String tag, required String title, required String body, required int upvotes, required int comments, required bool isHot}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isHot ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: AppColors.surfaceContainerHighest, radius: 16, child: Icon(Icons.person, color: AppColors.onSurfaceVariant, size: 16)),
              const SizedBox(width: 10),
              Text(author, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 8),
              Text('• $time', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(6)),
                child: Text(tag, style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(body, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInteraction(Icons.arrow_upward_rounded, upvotes.toString(), isHot ? AppColors.primary : AppColors.onSurfaceVariant),
              const SizedBox(width: 20),
              _buildInteraction(Icons.mode_comment_outlined, comments.toString(), AppColors.onSurfaceVariant),
              const Spacer(),
              Icon(Icons.share_outlined, color: AppColors.onSurfaceVariant, size: 18),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInteraction(IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(count, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
