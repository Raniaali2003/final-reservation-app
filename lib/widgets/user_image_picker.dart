import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
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

    final pickedImageFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 200,
    );

    if (pickedImageFile == null) {
      setState(() {
        _pickedImage = null;
        _base64ImageString = null;
      });
      widget.imagePickFn(null);
      return;
    }

    final imageFile = File(pickedImageFile.path);
    Uint8List imageBytes = await imageFile.readAsBytes();

    final encodedImage = base64Encode(imageBytes);

    setState(() {
      _pickedImage = pickedImageFile;
      _base64ImageString = encodedImage;
    });

    widget.imagePickFn(encodedImage);
  }

  @override
  Widget build(BuildContext context) {
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
                width: 150,
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
