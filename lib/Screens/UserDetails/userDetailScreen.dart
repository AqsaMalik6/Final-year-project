import 'dart:io';

import 'package:flutter/material.dart';
import 'package:measuremate/Screens/MeasurementDetails/measurementDetail.dart';

class UserDetailScreen extends StatelessWidget {
  final String userName;
  final String email;
  final Map<String, Map<String, dynamic>> sweatshirtSizes;
  final Map<String, Map<String, dynamic>> denimJeansSizes;
  final String? userImageUrl;

  const UserDetailScreen({
    Key? key,
    required this.userName,
    required this.email,
    required this.sweatshirtSizes,
    required this.denimJeansSizes,
    this.userImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('User Details', style: TextStyle(
              // fontFamily: 'CeraPro',
              letterSpacing: 3.5, fontWeight: FontWeight.bold),),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: userImageUrl != null && userImageUrl!.isNotEmpty
                            ? NetworkImage(userImageUrl!)
                            : null,
                        child: userImageUrl == null || userImageUrl!.isEmpty
                            ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: $userName',
                              style: const TextStyle(
                                // fontFamily: 'CeraPro',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Email: $email',
                              style: const TextStyle(fontSize: 16,
                                // fontFamily: 'CeraPro',
                              ),
                              overflow: TextOverflow.clip,
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: Theme.of(context).primaryColor,
                        indicatorColor: Theme.of(context).primaryColor,
                        tabs: const [
                          Tab(text: 'Sweatshirt Sizes'),
                          Tab(text: 'Denim Jeans Sizes'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildMeasurementList(context, sweatshirtSizes),
                            _buildMeasurementList(context, denimJeansSizes),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementList(
      BuildContext context, Map<String, Map<String, dynamic>> measurements) {
    return ListView.builder(
      itemCount: measurements.length,
      itemBuilder: (context, index) {
        String sizeKey = measurements.keys.elementAt(index);
String size = measurements[sizeKey]?['size']?.toString() ?? '';
String imageUrl = measurements[sizeKey]?['image']?.toString() ?? '';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MeasurementDetailScreen(
                  title: sizeKey,
                  size: size,
                  imageUrl: imageUrl,
                ),
              ),
            );
          },
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              // leading: ClipRRect(
              //   borderRadius: BorderRadius.circular(8),
              //   child: Image.network(
              //     imageUrl,
              //     fit: BoxFit.cover,
              //     width: 50,
              //     height: 50,
              //     errorBuilder: (context, error, stackTrace) {
              //       return const Icon(Icons.image_not_supported);
              //     },
              //   ),
              // ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.startsWith('http')
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported);
                  },
                )
                    : Image.file(
                  File(imageUrl),
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported);
                  },
                ),
              ),

              title: Text(sizeKey),
              subtitle: Text('Size: $size'),
            ),
          ),
        );
      },
    );
  }
}
