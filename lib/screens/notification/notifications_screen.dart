import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/notification/notification_cubit.dart';
import '../../cubit/notification/notification_state.dart';

class NotificationsScreen extends StatelessWidget {
  static const String routeName = '/notifications';
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state.notifications.isEmpty) {
            return const Center(child: Text("No notifications received yet"));
          }

          return ListView.builder(
            itemCount: state.notifications.length,
            itemBuilder: (_, index) {
              final msg = state.notifications.reversed.toList()[index];

              return ListTile(
                title: Text(msg.notification?.title ?? "New Message"),
                subtitle: Text(msg.notification?.body ??
                    (msg.data.isNotEmpty
                        ? 'Data Payload Received'
                        : 'No body')),
                trailing: Text(msg.data['timeSlot'] ?? ''),
                isThreeLine: false,
              );
            },
          );
        },
      ),
    );
  }
}
