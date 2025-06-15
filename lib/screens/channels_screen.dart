import 'package:flutter/material.dart';
import '../widget/custom_top_bar.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../repositories/chat_repository.dart';
import '../repositories/auth_repository.dart';
import '../screens/create_chat_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/edit_chat_screen.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({super.key});

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  final ChatRepository _chatRepository = ChatRepository();
  final AuthRepository _authRepository = AuthRepository();

  UserModel? _currentUser;
  Stream<List<ChatModel>>? _chatsStream;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      print('Caricamento profilo utente...');
      final user = await _authRepository.getCurrentUserProfile();
      print('Profilo utente: ${user?.uid} - ${user?.name} - ${user?.role}');

      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
          _chatsStream = _chatRepository.getAccessibleChats(user.uid, user.role);
        });
        print('Stream chat configurato per utente: ${user.uid}');
      } else {
        print('Nessun utente trovato o widget non montato');
      }
    } catch (e) {
      print('Errore nel caricamento profilo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nel caricamento profilo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        actions: [
          IconButton(
            onPressed: _currentUser != null ? _showCreateChatScreen : null,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            tooltip: 'Crea nuova chat',
          ),
        ],
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : _buildChatsList(),
    );
  }

  Widget _buildChatsList() {
    return StreamBuilder<List<ChatModel>>(
      stream: _chatsStream,
      builder: (context, snapshot) {
        print('StreamBuilder stato: ${snapshot.connectionState}');
        if (snapshot.hasError) {
          print('Errore StreamBuilder: ${snapshot.error}');
        }
        if (snapshot.hasData) {
          print('Chat ricevute: ${snapshot.data?.length}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Errore nel caricamento delle chat',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadCurrentUser,
                  child: const Text('Riprova'),
                ),
              ],
            ),
          );
        }

        final chats = snapshot.data ?? [];

        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Nessuna chat disponibile',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Crea una nuova chat usando il pulsante +',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: chats.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) => _buildChatTile(chats[index]),
        );
      },
    );
  }

  Widget _buildChatTile(ChatModel chat) {
    final isCreator = chat.creatorId == _currentUser?.uid;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isCreator ? const Color(0xFF009E3D) : Colors.blue,
          child: Icon(
            isCreator ? Icons.edit : Icons.visibility,
            color: Colors.white,
          ),
        ),
        title: Text(
          chat.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chat.description.isNotEmpty) ...[
              Text(
                chat.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                Icon(
                  chat.accessType == ChatAccessType.role
                      ? Icons.group
                      : Icons.person_outline,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _getAccessDescription(chat),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: isCreator
            ? IconButton(
          onPressed: () => _showChatOptions(chat),
          icon: const Icon(Icons.more_vert),
          tooltip: 'Opzioni chat',
        )
            : null,
        onTap: () {
          print('Tap su chat: ${chat.title} (ID: ${chat.id})');
          _openChat(chat);
        },
      ),
    );
  }

  String _getAccessDescription(ChatModel chat) {
    if (chat.accessType == ChatAccessType.role) {
      if (chat.allowedRoles.length == 1) {
        return 'Ruolo: ${chat.allowedRoles.first}';
      } else {
        return 'Ruoli: ${chat.allowedRoles.length}';
      }
    } else {
      if (chat.allowedUserNames.length == 1) {
        return 'Utente: ${chat.allowedUserNames.first}';
      } else {
        return 'Utenti: ${chat.allowedUserNames.length}';
      }
    }
  }

  void _showCreateChatScreen() {
    if (_currentUser == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateChatScreen(
          creatorId: _currentUser!.uid,
          creatorName: _currentUser!.name,
        ),
      ),
    );
  }

  void _showChatOptions(ChatModel chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Modifica Chat'),
                onTap: () {
                  Navigator.pop(context);
                  _editChat(chat);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Elimina Chat', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteChat(chat);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editChat(ChatModel chat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditChatScreen(chatToEdit: chat),
      ),
    ).then((result) {
      if (result == true) {
        print('Chat modificata, ricaricamento lista...');
        _loadCurrentUser();
      }
    });
  }

  void _deleteChat(ChatModel chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Chat'),
        content: Text('Sei sicuro di voler eliminare la chat "${chat.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _chatRepository.deleteChat(chat.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chat eliminata')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openChat(ChatModel chat) {
    print('Tentativo di apertura chat: ${chat.title}');
    print('Chat ID: ${chat.id}');
    print('Context: $context');
    print('Mounted: $mounted');

    if (!mounted) {
      print('Widget non montato, impossibile navigare');
      return;
    }

    try {
      print('Navigazione verso ChatScreen...');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            print('Builder ChatScreen chiamato');
            return ChatScreen(chat: chat);
          },
        ),
      ).then((result) {
        print('Navigazione completata, risultato: $result');
      }).catchError((error) {
        print('Errore durante la navigazione: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore nell\'apertura della chat: $error')),
          );
        }
      });
    } catch (e) {
      print('Eccezione durante _openChat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nell\'apertura della chat: $e')),
        );
      }
    }
  }
}