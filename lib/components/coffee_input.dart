import 'dart:io';
import 'dart:typed_data';

import 'package:coffee_picker/components/scaffold.dart';
import 'package:coffee_picker/providers/coffeesIndex.dart';
import 'package:coffee_picker/providers/originsIndex.dart';
import 'package:coffee_picker/providers/roastersIndex.dart';
import 'package:coffee_picker/providers/tasteNotes.dart';
import 'package:coffee_picker/repositories/coffee_images.dart';
import 'package:coffee_picker/repositories/origins.dart';
import 'package:coffee_picker/repositories/roasters.dart';
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
import 'coffee.dart';
import 'coffees.dart';

class CoffeeInput extends ConsumerStatefulWidget {
  const CoffeeInput({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CoffeeInput();
}

class _CoffeeInput extends ConsumerState<CoffeeInput> {
  final _formKey = GlobalKey<FormState>();
  final roasterName = TextEditingController();
  final roasterFocusNode = FocusNode();
  final name = TextEditingController();
  final tasteNotesController = TextfieldTagsController();
  final cost = TextEditingController();
  final weight = TextEditingController();

  var originFields = [
    (
      origin: TextEditingController(),
      originPercentage: TextEditingController(),
      focusNode: FocusNode(),
    )
  ];
  bool isOrganic = false;
  bool isFairTrade = false;
  Uint8List? _image;
  CroppedFile? _croppedFile;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    AsyncValue<List<String>> tasteNotes = ref.watch(tasteNotesProvider);
    AsyncValue<List<String>> roastersIndex = ref.watch(roastersIndexProvider);
    var uiSettings = buildCropperUISettings(context);

    const itemPadding = EdgeInsets.symmetric(vertical: 5, horizontal: 5);
    var inputForm = Form(
        key: _formKey,
        child: ListView(
          padding: itemPadding,
          children: [
            Padding(
              padding: itemPadding,
              child: buildFormFieldTextAutocomplete(
                controller: roasterName,
                focusNode: roasterFocusNode,
                label: 'Roaster Name',
                hint: 'Stumptown',
                validationText: () => 'Enter a roaster',
                autocompleteOptions: roastersIndex.value ?? [],
              ),
            ),
            Padding(
              padding: itemPadding,
              child: buildFormFieldText(
                  controller: name,
                  label: 'Coffee Name',
                  hint: 'Holler Mountain',
                  validationText: () => 'Enter a coffee'),
            ),
            Padding(
              padding: itemPadding,
              child: buildImageUploadBox(uiSettings),
            ),
            Padding(
              padding: itemPadding,
              child: buildMultiTagField(
                  controller: tasteNotesController,
                  label: 'Tasting notes',
                  hintText: 'chocolate',
                  tagColor: theme.primaryColor,
                  theme: theme,
                  autocompleteOptions: tasteNotes.value ?? []),
            ),
            Padding(
              padding: itemPadding,
              child: buildFormFieldDouble(
                  controller: cost,
                  label: 'Cost of beans/grounds (\$)',
                  hint: '20',
                  validationText: () => 'Enter an amount'),
            ),
            Padding(
              padding: itemPadding,
              child: buildFormFieldDouble(
                  controller: weight,
                  label: 'Weight of beans/grounds (oz)',
                  hint: '10',
                  validationText: () => 'Enter an amount'),
            ),
            Padding(
              padding: itemPadding,
              child: buildCertificationsCheckboxes(),
            ),
            ...buildOriginFields(),
            Padding(
              padding: itemPadding,
              child: buildAddOriginButton(context),
            ),
            Padding(
              padding: itemPadding,
              child: buildSubmitButton(context),
            ),
          ],
        ));
    return ScaffoldBuilder(
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: inputForm));
  }

  Row buildCertificationsCheckboxes() {
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
  }

  Row buildImageUploadBox(List<PlatformUiSettings> uiSettings) {
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
  }

  FilledButton buildImageUploadButton(
      {List<PlatformUiSettings> uiSettings = const []}) {
    return FilledButton.tonalIcon(
      onPressed: () {
        onUploadImage();
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

  List<Widget> buildOriginFields() {
    AsyncValue<List<String>> originsWatch = ref.watch(originIndexProvider);

    return originFields
        .map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 5,
                    child: buildFormFieldTextAutocomplete(
                      controller: e.origin,
                      focusNode: e.focusNode,
                      label: 'Origin',
                      hint: 'Brazil',
                      validationText: () => 'Enter an origin country',
                      autocompleteOptions: originsWatch.value ?? [],
                    ),
                  ),
                  const Spacer(flex: 1),
                  Flexible(
                    flex: 2,
                    child: buildFormFieldDouble(
                        controller: e.originPercentage,
                        label: '%',
                        hint: '100',
                        validationText: () => 'Enter a percentage 1-100'),
                  ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          originFields.removeAt(originFields.indexOf(e));
                        });
                      },
                      child: const Icon(Icons.close))
                ])))
        .toList();
  }

  Widget buildAddOriginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            originFields.add((
              origin: TextEditingController(),
              originPercentage: TextEditingController(),
              focusNode: FocusNode(),
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
          submitCoffee(context).then((coffee) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CoffeeInfo(coffee: coffee),
                ));
          });
        },
        child: const Text('Submit'),
      ),
    );
  }

  Future<Coffee> submitCoffee(BuildContext context) async {
    _formKey.currentState?.validate();

    var costValue = double.parse(cost.value.text);
    var weightValue = double.parse(weight.value.text);
    var costPerOz = toPrecision(calculateCostPerOz(costValue, weightValue));
    var origins = originFields
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
      uploadImage(File(croppedPath), uploadedPath);
    }

    var coffeeName = name.value.text;
    var roaster = roasterName.value.text;
    var coffee = await addCoffee(CoffeeCreateReq(
      roaster: roaster,
      name: coffeeName,
      costPerOz: costPerOz,
      tastingNotes: tasteNotesController.getTags ?? [],
      usdaOrganic: isOrganic,
      fairTrade: isFairTrade,
      thumbnailPath: uploadedPath,
      origins: origins,
    ));

    AsyncValue<List<CoffeeIndex>> coffeeIndex = ref.watch(coffeesIndexProvider);

    upsertCoffeeIndex(coffeeName, roaster,
        createDoc: coffeeIndex.value == null || coffeeIndex.value!.isEmpty);

    ref.invalidate(coffeesIndexProvider);

    AsyncValue<List<String>> roastersIndex = ref.watch(roastersIndexProvider);

    upsertRoastersIndex(roaster,
        createDoc: roastersIndex.value == null || roastersIndex.value!.isEmpty);

    ref.invalidate(roastersIndexProvider);

    var originsWatch = ref.watch(originIndexProvider);

    for (final String o in origins.map((e) => e.origin).toList()) {
      await upsertOriginIndex(o,
          createDoc: originsWatch.value == null || originsWatch.value!.isEmpty);
    }

    ref.invalidate(originIndexProvider);

    tasteNotesController.getTags?.forEach((element) {
      addTastingNote(element);
    });

    ref.invalidate(tasteNotesProvider);

    return coffee;
  }
}
