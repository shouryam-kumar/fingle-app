import 'package:flutter/material.dart';

enum PostActionType { 
  report, 
  invite, 
  unfollow, 
  mute 
}

class PostAction {
  final PostActionType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;
  
  const PostAction({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
  });
}