import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageBox extends StatefulWidget {
  final Uint8List? image;
  final void Function({required String extension, Uint8List? data})? onChanged;
  final double width;
  final double height;

  const ImageBox(
      {super.key,
      this.image,
      this.onChanged,
      this.width = 110,
      this.height = 110});

  @override
  State<StatefulWidget> createState() => _ImageBox();
}

class _ImageBox extends State<ImageBox> {
  @override
  Widget build(BuildContext context) {
    var uiSettings = buildCropperUISettings(context);

    return AspectRatio(
        aspectRatio: 1,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: widget.image == null
              ? buildImageUploadButton(uiSettings: uiSettings)
              : Image.memory(
                  widget.image!,
                  fit: BoxFit.contain,
                  repeat: ImageRepeat.noRepeat,
                  width: 460,
                ),
        ));
  }

  FilledButton buildImageUploadButton(
      {List<PlatformUiSettings> uiSettings = const []}) {
    return FilledButton.tonalIcon(
      onPressed: () {
        onUploadImage(uiSettings: uiSettings);
      },
      icon: const Icon(
        Icons.add,
        size: 15,
      ),
      label: const Text(
        'Upload Image',
        style: TextStyle(fontSize: 12),
      ),
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0), side: const BorderSide()),
      ),
    );
  }

  void onUploadImage({
    List<PlatformUiSettings> uiSettings = const [],
  }) async {
    XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 460,
      maxWidth: 460,
    );

    if (image == null) {
      return null;
    }

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: uiSettings,
    );

    Uint8List? croppedData = await croppedFile?.readAsBytes();
    setState(() {
      widget.onChanged!(
        extension: ImageCompressFormat.jpg.name,
        data: croppedData,
      );
    });
  }

  List<PlatformUiSettings> buildCropperUISettings(BuildContext context) {
    return [
      AndroidUiSettings(
        toolbarTitle: 'Crop',
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      IOSUiSettings(
        title: 'Crop',
      ),
      WebUiSettings(
        context: context,
        initialAspectRatio: 1,
      ),
    ];
  }
}
