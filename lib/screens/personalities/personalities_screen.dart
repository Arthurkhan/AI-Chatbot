import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/personality.dart';
import '../../services/personality_service.dart';
import '../chat/chat_screen.dart';

class PersonalitiesScreen extends StatelessWidget {
  const PersonalitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose AI Personality'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: Consumer<PersonalityService>(
        builder: (context, personalityService, child) {
          final personalities = personalityService.personalities;
          
          if (personalities.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: personalities.length,
            itemBuilder: (context, index) {
              final personality = personalities[index];
              return _PersonalityCard(personality: personality);
            },
          );
        },
      ),
    );
  }
}

class _PersonalityCard extends StatelessWidget {
  final Personality personality;

  const _PersonalityCard({required this.personality});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(personality: personality),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconForPersonality(personality.name),
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                personality.name,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                personality.description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForPersonality(String name) {
    switch (name.toLowerCase()) {
      case 'friendly assistant':
        return Icons.emoji_emotions;
      case 'technical expert':
        return Icons.code;
      case 'creative writer':
        return Icons.edit_note;
      case 'life coach':
        return Icons.psychology;
      case 'study buddy':
        return Icons.school;
      default:
        return Icons.smart_toy;
    }
  }
}