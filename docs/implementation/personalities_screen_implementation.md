# Personalities Screen Implementation

**Last Updated**: 2025-07-10
**Priority**: HIGH
**Estimated Time**: 3-4 hours

## Overview

The personalities screen is the main hub where users:
- View all their AI personalities
- Create new personalities
- Edit existing personalities
- Select a personality to chat with
- Manage conversations for each personality

## Implementation Steps

### Step 1: Create Personalities Screen

Create `lib/screens/personalities/personalities_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/personality.dart';
import '../../models/conversation.dart';
import '../../services/personality_service.dart';
import '../../services/database_service.dart';
import '../../widgets/personality_card.dart';
import '../chat/chat_screen.dart';
import '../settings/settings_screen.dart';
import 'create_personality_screen.dart';
import 'personality_detail_screen.dart';

class PersonalitiesScreen extends StatefulWidget {
  const PersonalitiesScreen({super.key});

  @override
  State<PersonalitiesScreen> createState() => _PersonalitiesScreenState();
}

class _PersonalitiesScreenState extends State<PersonalitiesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Personalities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<PersonalityService>(
        builder: (context, personalityService, _) {
          if (personalityService.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (personalityService.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading personalities',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    personalityService.error ?? 'Unknown error',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => personalityService.loadPersonalities(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final personalities = personalityService.personalities;

          if (personalities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(delay: 300.ms),
                  const SizedBox(height: 24),
                  Text(
                    'No personalities yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first AI personality to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => _createPersonality(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Personality'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => personalityService.loadPersonalities(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: personalities.length,
              itemBuilder: (context, index) {
                final personality = personalities[index];
                return PersonalityCard(
                  personality: personality,
                  onTap: () => _openPersonalityDetail(context, personality),
                  onStartChat: () => _startChat(context, personality),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: index * 100),
                  duration: 600.ms,
                ).slideX(
                  begin: 0.1,
                  end: 0,
                  delay: Duration(milliseconds: index * 100),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createPersonality(context),
        icon: const Icon(Icons.add),
        label: const Text('New Personality'),
      ).animate().scale(delay: 500.ms),
    );
  }

  void _createPersonality(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreatePersonalityScreen(),
      ),
    );
  }

  void _openPersonalityDetail(BuildContext context, Personality personality) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonalityDetailScreen(personality: personality),
      ),
    );
  }

  Future<void> _startChat(BuildContext context, Personality personality) async {
    try {
      // Set as current personality
      context.read<PersonalityService>().setCurrentPersonality(personality);
      
      // Create new conversation
      final conversation = await context.read<PersonalityService>().createConversation();
      
      // Navigate to chat
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversation: conversation,
              personality: personality,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start chat: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
```

### Step 2: Create Personality Card Widget

Create `lib/widgets/personality_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/personality.dart';

class PersonalityCard extends StatelessWidget {
  final Personality personality;
  final VoidCallback onTap;
  final VoidCallback onStartChat;

  const PersonalityCard({
    super.key,
    required this.personality,
    required this.onTap,
    required this.onStartChat,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Hero(
                tag: 'personality-avatar-${personality.id}',
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(personality.avatarColor),
                  child: Text(
                    personality.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personality.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      personality.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Chat button
              IconButton(
                onPressed: onStartChat,
                icon: const Icon(Icons.chat_bubble_outline),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Step 3: Create Personality Detail Screen

Create `lib/screens/personalities/personality_detail_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/personality.dart';
import '../../models/conversation.dart';
import '../../services/personality_service.dart';
import '../../services/database_service.dart';
import '../chat/chat_screen.dart';
import 'edit_personality_screen.dart';

class PersonalityDetailScreen extends StatefulWidget {
  final Personality personality;

  const PersonalityDetailScreen({
    super.key,
    required this.personality,
  });

  @override
  State<PersonalityDetailScreen> createState() => _PersonalityDetailScreenState();
}

class _PersonalityDetailScreenState extends State<PersonalityDetailScreen> {
  late Personality _personality;
  List<Conversation> _conversations = [];
  bool _isLoadingConversations = true;

  @override
  void initState() {
    super.initState();
    _personality = widget.personality;
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final conversations = await DatabaseService.instance.getConversations(
        _personality.id,
      );
      setState(() {
        _conversations = conversations;
        _isLoadingConversations = false;
      });
    } catch (e) {
      setState(() => _isLoadingConversations = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_personality.name),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(_personality.avatarColor),
                      Color(_personality.avatarColor).withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: 'personality-avatar-${_personality.id}',
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        _personality.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editPersonality,
              ),
              PopupMenuButton<String>(
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(Icons.archive),
                        SizedBox(width: 8),
                        Text('Archive'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Description
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_personality.description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_personality.description),
                    const SizedBox(height: 24),
                  ],
                  
                  // System Prompt
                  Text(
                    'System Prompt',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _personality.systemPrompt,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Conversations Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Conversations',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _startNewChat,
                        icon: const Icon(Icons.add),
                        label: const Text('New Chat'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Conversations List
          if (_isLoadingConversations)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_conversations.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    const Text('No conversations yet'),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _startNewChat,
                      icon: const Icon(Icons.add),
                      label: const Text('Start First Chat'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final conversation = _conversations[index];
                  return ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(conversation.displayTitle),
                    subtitle: conversation.lastMessage != null
                        ? Text(
                            conversation.lastMessage!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: Text(
                      conversation.getRelativeTime(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () => _openConversation(conversation),
                  );
                },
                childCount: _conversations.length,
              ),
            ),
        ],
      ),
    );
  }

  void _editPersonality() async {
    final result = await Navigator.push<Personality>(
      context,
      MaterialPageRoute(
        builder: (_) => EditPersonalityScreen(personality: _personality),
      ),
    );
    
    if (result != null) {
      setState(() {
        _personality = result;
      });
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'archive':
        _archivePersonality();
        break;
      case 'delete':
        _deletePersonality();
        break;
    }
  }

  Future<void> _archivePersonality() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Personality'),
        content: Text('Archive "${_personality.name}"? You can restore it later from settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    
    if (confirm == true && mounted) {
      try {
        await context.read<PersonalityService>().archivePersonality(_personality.id);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to archive: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deletePersonality() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Personality'),
        content: Text(
          'Delete "${_personality.name}"? This will permanently delete '
          'the personality and all its conversations. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true && mounted) {
      try {
        await context.read<PersonalityService>().deletePersonality(_personality.id);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _startNewChat() async {
    try {
      context.read<PersonalityService>().setCurrentPersonality(_personality);
      final conversation = await context.read<PersonalityService>().createConversation();
      
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversation: conversation,
              personality: _personality,
            ),
          ),
        );
        _loadConversations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start chat: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _openConversation(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversation: conversation,
          personality: _personality,
        ),
      ),
    );
  }
}
```

### Step 4: Create Personality Creation Screen

Create `lib/screens/personalities/create_personality_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/personality_service.dart';
import '../../config/constants.dart';

class CreatePersonalityScreen extends StatefulWidget {
  const CreatePersonalityScreen({super.key});

  @override
  State<CreatePersonalityScreen> createState() => _CreatePersonalityScreenState();
}

class _CreatePersonalityScreenState extends State<CreatePersonalityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _systemPromptController = TextEditingController();
  
  Color _selectedColor = Colors.blue;
  bool _isCreating = false;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.indigo,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  Future<void> _createPersonality() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isCreating = true);
    
    try {
      await context.read<PersonalityService>().createPersonality(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        systemPrompt: _systemPromptController.text.trim(),
        avatarColor: _selectedColor.value,
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personality created successfully!'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create personality: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Personality'),
        actions: [
          TextButton(
            onPressed: _isCreating ? null : _createPersonality,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Color Selection
            Text(
              'Avatar Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableColors.length,
                itemBuilder: (context, index) {
                  final color = _availableColors[index];
                  final isSelected = color == _selectedColor;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () => setState(() => _selectedColor = color),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3,
                                )
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., Creative Writer',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: AppConstants.maxPersonalityNameLength,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Brief description of this personality',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
              maxLength: AppConstants.maxPersonalityDescriptionLength,
            ),
            const SizedBox(height: 16),
            
            // System Prompt Field
            TextFormField(
              controller: _systemPromptController,
              decoration: const InputDecoration(
                labelText: 'System Prompt',
                hintText: 'Define how this AI personality should behave...',
                prefixIcon: Icon(Icons.psychology),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              maxLength: AppConstants.maxSystemPromptLength,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a system prompt';
                }
                if (value.trim().length < 10) {
                  return 'System prompt must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Examples
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'System Prompt Examples',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExample(
                      'Professional Assistant',
                      'You are a professional assistant. Be formal, concise, and helpful. '
                      'Focus on providing accurate information and practical solutions.',
                    ),
                    const SizedBox(height: 8),
                    _buildExample(
                      'Creative Writer',
                      'You are a creative writing assistant. Be imaginative and encouraging. '
                      'Help with storytelling, character development, and creative ideas.',
                    ),
                    const SizedBox(height: 8),
                    _buildExample(
                      'Coding Helper',
                      'You are a programming assistant. Provide clear code examples and explanations. '
                      'Help with debugging, best practices, and technical questions.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExample(String title, String prompt) {
    return InkWell(
      onTap: () {
        _systemPromptController.text = prompt;
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              prompt,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 5: Create Edit Personality Screen

The edit screen will be similar to create but with pre-filled values:

```dart
// lib/screens/personalities/edit_personality_screen.dart
// Similar to CreatePersonalityScreen but with:
// - Pre-filled values from existing personality
// - Update instead of create
// - Different title and confirmation
```

## Implementation Checklist

- [ ] Personalities list displays correctly
- [ ] Empty state shows when no personalities
- [ ] Create personality flow works
- [ ] Edit personality updates correctly
- [ ] Delete confirmation and action work
- [ ] Archive functionality works
- [ ] Conversations list in detail screen
- [ ] Navigation to chat works
- [ ] Color selection works properly
- [ ] Form validation works
- [ ] Loading states display correctly
- [ ] Error states handled gracefully
- [ ] Animations are smooth

## Next Steps

After implementing personalities screens:
1. Move to [Navigation Implementation](navigation_implementation.md)
2. Then proceed to [Settings Screen Implementation](settings_screen_implementation.md)