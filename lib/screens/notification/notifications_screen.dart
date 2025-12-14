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
      // Use BlocBuilder to react to state changes in the NotificationCubit
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          // Display a message if no notifications have been received
          if (state.notifications.isEmpty) {
            return const Center(child: Text("No notifications received yet"));
          }

          // Display the notifications in a scrollable list
          return ListView.builder(
            // Reverse the list to show the newest notification at the top
            itemCount: state.notifications.length,
            itemBuilder: (_, index) {
              // Get the current message, reversing the list for display order
              final msg = state.notifications.reversed.toList()[index];

              // Safely access notification title and body
              return ListTile(
                title: Text(msg.notification?.title ?? "New Message"),
                subtitle: Text(msg.notification?.body ??
                    (msg.data.isNotEmpty
                        ? 'Data Payload Received'
                        : 'No body')),
                // Example of displaying reservation data if available
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
