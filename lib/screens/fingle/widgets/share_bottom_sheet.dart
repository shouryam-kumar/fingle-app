import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/video_models.dart';

class ShareBottomSheet extends StatelessWidget {
  final VideoPost video;
  final VoidCallback onClose;

  const ShareBottomSheet({
    super.key,
    required this.video,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(context),
          _buildShareOptions(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Share',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOptions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Direct share options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareOption(
                context,
                icon: Icons.message,
                label: 'Message',
                color: Colors.green,
                onTap: () => _handleShare(context, 'Message'),
              ),
              _buildShareOption(
                context,
                icon: Icons.share,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () => _handleShare(context, 'WhatsApp'),
              ),
              _buildShareOption(
                context,
                icon: Icons.camera_alt,
                label: 'Instagram',
                color: const Color(0xFFE4405F),
                onTap: () => _handleShare(context, 'Instagram'),
              ),
              _buildShareOption(
                context,
                icon: Icons.more_horiz,
                label: 'More',
                color: Colors.grey,
                onTap: () => _handleShare(context, 'More options'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Link copy section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Share Link',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'fingle.app/video/${video.id}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _copyLink(context),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Additional options
          _buildListOption(
            context,
            icon: Icons.bookmark_outline,
            title: 'Save to Collection',
            onTap: () => _handleAction(context, 'Saved to collection'),
          ),
          _buildListOption(
            context,
            icon: Icons.qr_code,
            title: 'QR Code',
            onTap: () => _handleAction(context, 'QR Code generated'),
          ),
          _buildListOption(
            context,
            icon: Icons.flag_outlined,
            title: 'Report',
            subtitle: 'Report inappropriate content',
            isDestructive: true,
            onTap: () => _handleReport(context),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDestructive
                    ? Colors.red.withOpacity(0.7)
                    : Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive
            ? Colors.red.withOpacity(0.5)
            : Colors.white.withOpacity(0.3),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  void _handleShare(BuildContext context, String platform) {
    Navigator.of(context).pop();
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing to $platform...'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyLink(BuildContext context) {
    Clipboard.setData(
        ClipboardData(text: 'https://fingle.app/video/${video.id}'));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard! 📋'),
        duration: Duration(seconds: 1),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleAction(BuildContext context, String message) {
    Navigator.of(context).pop();
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleReport(BuildContext context) {
    Navigator.of(context).pop();
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Report Content',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to report this content as inappropriate?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Content reported. Thank you for keeping our community safe.'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Report',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
