import 'dart:io';
import 'dart:convert'; // Required for base64Encode
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Required for Uint8List
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  // Modified: imagePickFn now accepts a String (the Base64 encoded image)
  const UserImagePicker(this.imagePickFn, {super.key});

  final void Function(String? pickedImageString) imagePickFn;

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  XFile? _pickedImage;
  String? _base64ImageString;

  void _pickImage() async {
    FocusScope.of(context).unfocus();

    // 1. Pick the image with compression to keep the Firestore document size down
    final pickedImageFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 200,
    );

    if (pickedImageFile == null) {
      // If the user cancels picking an image, clear the old one
      setState(() {
        _pickedImage = null;
        _base64ImageString = null;
      });
      widget.imagePickFn(null); // Pass null back
      return;
    }

    // 2. Read the image file as bytes
    final imageFile = File(pickedImageFile.path);
    Uint8List imageBytes = await imageFile.readAsBytes();

    // 3. Encode the bytes into a Base64 string
    final encodedImage = base64Encode(imageBytes);

    // 4. Update the state for local preview and callback
    setState(() {
      _pickedImage = pickedImageFile;
      _base64ImageString = encodedImage;
    });
    
    // 5. Pass the Base64 string back to the parent widget for saving
    widget.imagePickFn(encodedImage);
  }

  @override
  Widget build(BuildContext context) {
    // We use Image.file() for the local preview since we still have the file path.
    // This is the simplest way to show the image immediately after picking it.
    return Column(
      children: <Widget>[
        if (_pickedImage != null)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(
                File(_pickedImage!.path),
                width: 150, // Match the max width for consistent preview
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: Icon(
            Icons.image, 
            color: Theme.of(context).primaryColor,
          ),
          label: Text(
            _pickedImage == null ? 'Add Image' : 'Change Image',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}