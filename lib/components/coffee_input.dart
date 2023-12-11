import 'dart:io';
import 'dart:typed_data';

import 'package:coffee_picker/components/scaffold.dart';
import 'package:coffee_picker/providers/coffeesIndex.dart';
import 'package:coffee_picker/repositories/coffee_images.dart';
import 'package:coffee_picker/repositories/taste_notes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../repositories/coffees.dart';
import '../services/coffee.dart';
import '../services/finance.dart';
import '../utils/forms.dart';
import '../utils/uuid.dart';
import 'coffees.dart';

class CoffeeInput extends ConsumerStatefulWidget {
  var originFields = [
    (
      origin: TextEditingController(),
      originPercentage: TextEditingController(),
    )
  ];

  CoffeeInput({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CoffeeInput();
}

class _CoffeeInput extends ConsumerState<CoffeeInput> {
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final tasteNotes = TextfieldTagsController();
  final cost = TextEditingController();
  final weight = TextEditingController();
  final startingFormFieldsCount = 6;
  final endingFormFieldsCount = 2;
  bool isOrganic = false;
  bool isFairTrade = false;
  Uint8List? _image;
  CroppedFile? _croppedFile;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var formFieldsCount = startingFormFieldsCount +
        widget.originFields.length +
        endingFormFieldsCount;

    var inputForm = Form(
        key: _formKey,
        child: ListView.builder(
          itemCount: formFieldsCount,
          itemBuilder: (context, index) {
            return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: getFormField(
                  index: index,
                  formFieldsCount: formFieldsCount,
                  context: context,
                  theme: theme,
                  uiSettings: buildCropperUISettings(context),
                ));
          },
        ));
    return ScaffoldBuilder(
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: inputForm));
  }

  Widget getFormField({
    required int index,
    required int formFieldsCount,
    required BuildContext context,
    required ThemeData theme,
    List<PlatformUiSettings> uiSettings = const [],
  }) {
    if (index == formFieldsCount - 1) {
      return buildSubmitButton(context);
    } else if (index == formFieldsCount - 2) {
      return buildAddOriginButton(context);
    } else if (index == 0) {
      return buildFormFieldText(
          controller: name,
          label: 'Coffee Name',
          hint: 'Tasty Coffee',
          validationText: () => 'Enter a coffee');
    } else if (index == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            child: SizedBox(
              width: 110,
              height: 110,
              child: _image == null
                  ? buildImageUploadButton(uiSettings: uiSettings)
                  : Image.memory(
                      _image!,
                      fit: BoxFit.scaleDown,
                      repeat: ImageRepeat.noRepeat,
                      width: 256,
                    ),
            ),
          ),
          const Spacer(flex: 2)
        ],
      );
    } else if (index == 2) {
      return buildMultiTagField(
        controller: tasteNotes,
        label: 'Tasting notes',
        hintText: 'chocolate',
        tagColor: theme.primaryColor,
        theme: theme,
      );
    } else if (index == 3) {
      return buildFormFieldDouble(
          controller: cost,
          label: 'Cost of beans/grounds (\$)',
          hint: '20',
          validationText: () => 'Enter an amount');
    } else if (index == 4) {
      return buildFormFieldDouble(
          controller: weight,
          label: 'Weight of beans/grounds (oz)',
          hint: '10',
          validationText: () => 'Enter an amount');
    } else if (index == 5) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildCheckboxField(
              isChecked: isOrganic,
              label: 'USDA Organic',
              onChanged: (isChecked) {
                setState(() {
                  isOrganic = isChecked ?? false;
                });
              }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: buildCheckboxField(
                isChecked: isFairTrade,
                label: 'Fair Trade',
                onChanged: (isChecked) {
                  setState(() {
                    isFairTrade = isChecked ?? false;
                  });
                }),
          ),
        ],
      );
    } else {
      return buildOriginField(index);
    }
  }

  FilledButton buildImageUploadButton(
      {List<PlatformUiSettings> uiSettings = const []}) {
    return FilledButton.tonalIcon(
      onPressed: () {
        onUploadImage();
      },
      icon: const Icon(Icons.add, size: 15,),
      label: const Text('Upload Image', style: TextStyle(fontSize: 12),),
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
      maxHeight: 256,
      maxWidth: 256,
    );

    if (image == null) {
      return null;
    }

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      uiSettings: uiSettings,
    );

    var croppedData = await croppedFile?.readAsBytes();
    setState(() {
      _croppedFile = croppedFile;
      _image = croppedData;
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
      ),
    ];
  }

  Row buildOriginField(int index) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Expanded(
        flex: 5,
        child: buildFormFieldText(
            controller:
                widget.originFields[index - startingFormFieldsCount].origin,
            label: 'Origin',
            hint: 'Brazil',
            validationText: () => 'Enter an origin country'),
      ),
      const Spacer(flex: 1),
      Flexible(
        flex: 2,
        child: buildFormFieldDouble(
            controller: widget
                .originFields[index - startingFormFieldsCount].originPercentage,
            label: '%',
            hint: '100',
            validationText: () => 'Enter a percentage 1-100'),
      ),
      TextButton(
          onPressed: () {
            setState(() {
              widget.originFields.removeAt(index - startingFormFieldsCount);
            });
          },
          child: const Icon(Icons.close))
    ]);
  }

  Widget buildAddOriginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            widget.originFields.add((
              origin: TextEditingController(),
              originPercentage: TextEditingController(),
            ));
          });
        },
        child: const Text('Add another origin'),
      ),
    );
  }

  Padding buildSubmitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: FilledButton(
        onPressed: () {
          submitCoffee(context);
        },
        child: const Text('Submit'),
      ),
    );
  }

  void submitCoffee(BuildContext context) {
    var costValue = double.parse(cost.value.text);
    var weightValue = double.parse(weight.value.text);
    var costPerOz = toPrecision(calculateCostPerOz(costValue, weightValue));
    var origins = widget.originFields
        .map((e) => CoffeeOrigin(
              origin: e.origin.text,
              percentage: double.parse(e.originPercentage.text),
            ))
        .toList();

    String uploadedPath = '';
    if (_croppedFile != null) {
      var croppedPath = _croppedFile!.path;
      String fileExt = croppedPath.split('.').last;
      uploadedPath = "${uuidV4()}/thumbnail.$fileExt";
      uploadImage(
          File(croppedPath),
          uploadedPath
      );
    }

    var coffeeName = name.value.text;
    addCoffee(CoffeeCreateReq(
      name: coffeeName,
      costPerOz: costPerOz,
      tastingNotes: tasteNotes.getTags ?? [],
      usdaOrganic: isOrganic,
      fairTrade: isFairTrade,
      thumbnailPath: uploadedPath,
      origins: origins,
    ));

    upsertCoffeeIndex(coffeeName);

    ref.invalidate(coffeeIndexProvider);

    tasteNotes.getTags?.forEach((element) {
      addTastingNote(element);
    });

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Coffees(),
        ));
  }
}
