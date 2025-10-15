import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/features/post/domain/entities/report.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Report.fromJson(data);
          }).toList();

          if (reports.isEmpty) {
            return const Center(child: Text('No reports yet'));
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                    'Report by ${report.reporterName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reason: ${report.reason}'),
                      if (report.details != null)
                        Text('Details: ${report.details}'),
                      Text(
                        'Reported at: ${report.timestamp.toString()}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onSelected: (value) async {
                      if (value == 'delete_report') {
                        // Delete the report
                        await FirebaseFirestore.instance
                            .collection('reports')
                            .doc(report.id)
                            .delete();
                      } else if (value == 'view_post') {
                        // Fetch and show post details
                        final postDoc = await FirebaseFirestore.instance
                            .collection('posts')
                            .doc(report.postId)
                            .get();
                        
                        if (!context.mounted) return;

                        if (!postDoc.exists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Post no longer exists'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Show post details in a dialog
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Reported Post'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Content: ${postDoc['content']}'),
                                  const SizedBox(height: 8),
                                  Text('Posted by: ${postDoc['userName']}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    // Delete post and its report
                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(report.postId)
                                        .delete();
                                    await FirebaseFirestore.instance
                                        .collection('reports')
                                        .doc(report.id)
                                        .delete();
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text(
                                    'Delete Post',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'view_post',
                        child: Text('View Post'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete_report',
                        child: Text('Dismiss Report'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}