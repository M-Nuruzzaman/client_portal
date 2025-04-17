// message_screen.dart
import 'package:client_portal/utils/GradiantBackground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/bloc/websocket_bloc/websocket_bloc.dart';
import '../../presentation/widgets/custom_appbar.dart';

class MessageScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Websocket",
        titleColor: Colors.white,
        onLeadingButtonPressed: () {
          Navigator.pop(context);
        },
        showBackButton: true,
      ),
      body: GradientBackground(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<WebSocketCubit, List<String>>(
                builder: (context, messages) {
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(messages[index]),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(labelText: "Enter message"),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      context.read<WebSocketCubit>().sendMessage(_controller.text);
                      _controller.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
