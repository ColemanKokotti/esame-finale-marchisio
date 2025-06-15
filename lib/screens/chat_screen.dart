// screens/chat_screen.dart
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../repositories/message_repository.dart';
import '../repositories/auth_repository.dart';
import '../services/notification_service.dart'; // AGGIUNTO

class ChatScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatScreen({
    super.key,
    required this.chat,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageRepository _messageRepository = MessageRepository();
  final AuthRepository _authRepository = AuthRepository();
  final NotificationService _notificationService = NotificationService(); // AGGIUNTO

  UserModel? _currentUser;
  Stream<List<MessageModel>>? _messagesStream;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authRepository.getCurrentUserProfile();
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
          _messagesStream = _messageRepository.getChatMessages(widget.chat.id);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nel caricamento utente: $e')),
        );
      }
    }
  }

  bool get _canSendMessages {
    return _currentUser != null && _currentUser!.uid == widget.chat.creatorId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chat.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF009E3D),
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showChatInfo,
          ),
        ],
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Area messaggi
          Expanded(
            child: _buildMessagesList(),
          ),

          // Area input (solo per il creatore)
          if (_canSendMessages) _buildMessageInput(),

          // Messaggio per utenti che non possono scrivere
          if (!_canSendMessages) _buildReadOnlyNotice(),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<List<MessageModel>>(
      stream: _messagesStream,
      builder: (context, snapshot) {
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
                  'Errore nel caricamento messaggi',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red[400],
                  ),
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

        final messages = snapshot.data ?? [];

        // Crea la lista di messaggi con il messaggio neutrale del creatore all'inizio
        final displayMessages = <dynamic>[];

        // Aggiungi il messaggio neutrale del creatore come primo elemento
        displayMessages.add('creator_info');

        // Aggiungi tutti i messaggi reali
        displayMessages.addAll(messages);

        if (messages.isEmpty) {
          return Column(
            children: [
              // Messaggio neutrale del creatore
              _buildCreatorInfoMessage(),

              // Messaggio di chat vuota
              Expanded(
                child: Center(
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
                        'Nessun messaggio ancora',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_canSendMessages) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Inizia la conversazione scrivendo il primo messaggio',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        // Auto-scroll verso il basso quando arrivano nuovi messaggi
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: displayMessages.length,
          itemBuilder: (context, index) {
            if (displayMessages[index] == 'creator_info') {
              return _buildCreatorInfoMessage();
            } else {
              return _buildMessageTile(displayMessages[index] as MessageModel);
            }
          },
        );
      },
    );
  }

  Widget _buildCreatorInfoMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Chat creata da ${widget.chat.creatorName}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageTile(MessageModel message) {
    final isFromCreator = message.senderId == widget.chat.creatorId;
    final isFromCurrentUser = message.senderId == _currentUser?.uid;

    // Il messaggio va a destra se è dal creatore E dall'utente corrente
    // Oppure se l'utente corrente è il creatore (i suoi messaggi vanno sempre a destra)
    final showOnRight = isFromCurrentUser && isFromCreator;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: showOnRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar a sinistra (solo per messaggi a sinistra)
          if (!showOnRight) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: isFromCreator ? const Color(0xFF009E3D) : Colors.blue,
              child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Contenuto messaggio
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: showOnRight
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Nome e ruolo (solo per messaggi a sinistra)
                  if (!showOnRight)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.senderName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (isFromCreator) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF009E3D),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'CREATORE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                  if (!showOnRight) const SizedBox(height: 4),

                  // Bubble del messaggio
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: showOnRight
                          ? const Color(0xFF009E3D)  // Verde per messaggi a destra
                          : isFromCreator
                          ? const Color(0xFF009E3D).withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: showOnRight
                            ? const Radius.circular(12)
                            : const Radius.circular(4),
                        bottomRight: showOnRight
                            ? const Radius.circular(4)
                            : const Radius.circular(12),
                      ),
                      border: showOnRight
                          ? null
                          : Border.all(
                        color: isFromCreator
                            ? const Color(0xFF009E3D).withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 15,
                        color: showOnRight ? Colors.white : Colors.black,
                      ),
                    ),
                  ),

                  // Timestamp
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _formatDateTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Avatar a destra (solo per messaggi a destra)
          if (showOnRight) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF009E3D),
              child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Scrivi un messaggio...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF009E3D),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Questa è una chat di sola lettura. Solo il creatore può scrivere messaggi.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // METODO AGGIORNATO con notifiche dinamiche
  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final message = MessageModel(
        id: '', // Verrà generato da Firebase
        chatId: widget.chat.id,
        content: content,
        senderId: _currentUser!.uid,
        senderName: _currentUser!.name,
        timestamp: DateTime.now(),
      );

      await _messageRepository.sendMessage(message);

      // AGGIUNTO: Crea notifica dinamica dopo l'invio del messaggio
      _notificationService.addMessageNotification(
        _currentUser!.name,
        content,
        widget.chat.title,
      );

      _messageController.clear();

      // Scroll verso il basso dopo l'invio
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nell\'invio del messaggio: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showChatInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.chat.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.chat.description.isNotEmpty) ...[
              const Text(
                'Descrizione:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(widget.chat.description),
              const SizedBox(height: 16),
            ],
            const Text(
              'Creata da:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.chat.creatorName),
            const SizedBox(height: 16),
            const Text(
              'Ruoli con accesso:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.chat.allowedRoles.join(', ')),
            const SizedBox(height: 16),
            const Text(
              'Data creazione:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_formatDateTime(widget.chat.createdAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h fa';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m fa';
    } else {
      return 'Ora';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}