import 'dart:io';

import 'package:flutter/material.dart';

class MeasurementDetailScreen extends StatelessWidget {
  final String title;
  final String size;
  final String imageUrl;

  const MeasurementDetailScreen({
    Key? key,
    required this.title,
    required this.size,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(title, style:
          TextStyle(
              // fontFamily: 'CeraPro',
              letterSpacing: 3.5),),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return 
                      (imageUrl!=null)?
            Image.file(File(imageUrl!)) :
           
                        const Icon(
                          Icons.image_not_supported,
                          size: 100,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Size Details',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'CeraPro'),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Size: $size',
                        style: const TextStyle(
                          fontSize: 18,
                          // fontFamily: 'CeraPro'
                          // fontWeight: FontWeight.bold,
                        ),
                      ),

                    ],
                  ),
                ),
              )


            ],
          ),
        ),
      ),
    );
  }
}
