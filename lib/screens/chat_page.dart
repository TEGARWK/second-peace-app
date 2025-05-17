import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  int? _roomId;
  int? _chatUserId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final chatService = ChatService();
      final room = await chatService.getOrCreateRoom();

      if (room['room'] == null) throw Exception('Chat room tidak tersedia.');

      final parsedRoomId = int.tryParse(room['room']['id'].toString());
      final parsedUserId = int.tryParse(room['room']['user_id'].toString());

      if (parsedRoomId == null || parsedUserId == null) {
        throw Exception('Gagal konversi roomId atau userId.');
      }

      await chatService.markMessagesAsRead(parsedRoomId);
      final messages = await chatService.fetchMessages(parsedRoomId);

      setState(() {
        _roomId = parsedRoomId;
        _chatUserId = parsedUserId;
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error init chat: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _roomId == null) return;

    try {
      final chatService = ChatService();
      await chatService.sendMessage(roomId: _roomId!, message: text);
      _controller.clear();
      final messages = await chatService.fetchMessages(_roomId!);
      setState(() => _messages = messages);
    } catch (e) {
      print('❌ Gagal kirim pesan: $e');
    }
  }

  Future<void> _pickAndSendFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && _roomId != null) {
      try {
        final chatService = ChatService();
        await chatService.uploadMedia(pickedFile, _roomId!);

        final messages = await chatService.fetchMessages(_roomId!);
        setState(() => _messages = messages);
      } catch (e) {
        print('❌ Gagal kirim media: $e');
      }
    }
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final sender = msg['sender'];
    final isMe = sender != null && sender['id'] == _chatUserId;
    final time = DateFormat(
      'HH:mm',
    ).format(DateTime.tryParse(msg['created_at'] ?? '') ?? DateTime.now());
    final hasMedia = msg['media_path'] != null;
    final isImage = msg['media_type'] == 'image';
    final mediaUrl =
        hasMedia
            ? 'https://secondpeace.my.id/storage/${msg['media_path']}'
            : null;

    final bubbleColor = isMe ? const Color(0xFFDCF8C6) : Colors.white;
    final textColor = isMe ? Colors.black87 : Colors.black;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
      bottomRight: isMe ? Radius.zero : const Radius.circular(12),
    );

    Widget content =
        hasMedia
            ? isImage
                ? Image.network(mediaUrl!, width: 180, fit: BoxFit.cover)
                : const Text('[Video tidak ditampilkan]')
            : Text(
              msg['message'] ?? '',
              style: TextStyle(color: textColor, fontSize: 15),
            );

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(color: bubbleColor, borderRadius: radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            content,
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.done_all,
                      size: 16,
                      color:
                          (msg['is_read'].toString() == '1' ||
                                  msg['is_read'] == true)
                              ? Colors.blue
                              : Colors.grey,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat dengan Admin"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[_messages.length - 1 - index];
                        return _buildMessage(msg);
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black,
                  child: IconButton(
                    icon: const Icon(Icons.image, color: Colors.white),
                    onPressed: _pickAndSendFile,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.black,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
