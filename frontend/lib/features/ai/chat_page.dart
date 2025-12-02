import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  final int petId;
  const ChatPage({super.key, required this.petId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _content = TextEditingController();
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(chatHistoryProvider(widget.petId));
    final send = ref.watch(chatSenderProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('AI互动')),
      body: Column(
        children: [
          Expanded(
            child: history.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const Center(child: Text('加载失败')),
              data: (list) => ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final m = list[i];
                  final isMe = m.role == 'user';
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.teal.shade100 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(m.content),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _content, decoration: const InputDecoration(hintText: '说点什么'))),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _sending ? null : () async {
                    setState(() { _sending = true; });
                    await send(widget.petId, _content.text);
                    _content.clear();
                    if (mounted) setState(() { _sending = false; });
                  },
                  child: _sending ? const CircularProgressIndicator() : const Text('发送'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

