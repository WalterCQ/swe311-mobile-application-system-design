import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../constants/assets.dart';
import '../../constants/theme.dart';
import '../../models/listing.dart';
import '../../store/listing_store.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_input.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/liquid_button.dart';
import '../../widgets/logo_mark.dart';
import 'my_listings_screen.dart';

class ListingFormScreen extends StatefulWidget {
  const ListingFormScreen({super.key, required this.store, this.listing});

  final ListingStore store;
  final Listing? listing;

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  static const _categoryOptions = [
    'Phones',
    'Audio',
    'Gaming',
    'Cameras',
    'Computing',
    'Wearables',
  ];
  static const _conditionOptions = [
    'New',
    'Used - Like New',
    'Used - Excellent',
    'Used - Good',
    'Collector Grade',
    'For Parts',
  ];

  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _title;
  late final TextEditingController _price;
  late final TextEditingController _description;
  late final TextEditingController _storage;
  late final TextEditingController _battery;
  late final TextEditingController _connector;
  late String _category;
  late String _condition;
  late String _asset;
  bool _submitted = false;

  bool get isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    final listing = widget.listing;
    _title = TextEditingController(text: listing?.title ?? '');
    _category = listing?.category ?? 'Audio';
    _price = TextEditingController(
      text: listing?.price.toStringAsFixed(2) ?? '',
    );
    _condition = listing?.condition ?? 'Used - Excellent';
    _description = TextEditingController(text: listing?.description ?? '');
    _storage = TextEditingController(text: listing?.storage ?? '');
    _battery = TextEditingController(text: listing?.battery ?? '');
    _connector = TextEditingController(text: listing?.connector ?? '');
    _asset = listing?.imageAsset ?? Assets.gameboy;
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _description.dispose();
    _storage.dispose();
    _battery.dispose();
    _connector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormShell(
      title: isEditing ? 'Edit Listing' : 'Create Listing',
      action: isEditing ? 'Save Changes' : 'Publish Listing',
      onSave: _save,
      formKey: _formKey,
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      dangerAction: isEditing ? 'Delete Listing' : null,
      onDanger: isEditing
          ? () async {
              final deleted = await showDeleteListingDialog(
                context,
                widget.store,
                widget.listing!,
              );
              if (deleted && context.mounted) Navigator.pop(context);
            }
          : null,
      children: [
        GlassFormPanel(
          children: [
            FormSection(
              title: 'Photo',
              subtitle: 'Tap the preview to upload a local product photo.',
            ),
            Semantics(
              button: true,
              label: 'Upload product photo',
              child: GestureDetector(
                onTap: _pickImage,
                child: GlassCard(
                  height: 136,
                  radius: 26,
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ProductImage(asset: _asset, width: 102, height: 74),
                        SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.upload_file_rounded,
                              color: AppTheme.blue,
                              size: 16,
                            ),
                            SizedBox(width: 5),
                            Text(
                              _isLocalImage
                                  ? 'Photo uploaded'
                                  : 'Upload product photo',
                              style: AppTheme.body.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 18),
            FormSection(
              title: 'Basic Info',
              subtitle:
                  'Use clear details buyers can scan before opening the item.',
            ),
            GlassInput(
              controller: _title,
              label: 'Product Title',
              hint: 'Sony Walkman WM-EX',
              icon: Icons.sell_outlined,
              requiredField: true,
              textInputAction: TextInputAction.next,
              validator: _required('Enter a product title.'),
            ),
            SizedBox(height: 12),
            _SelectableCardGroup(
              value: _category,
              options: _categoryOptions,
              label: 'Category',
              icon: Icons.category_outlined,
              requiredField: true,
              twoColumn: true,
              onChanged: (value) => setState(() => _category = value),
              validator: _required('Choose a category.'),
            ),
            SizedBox(height: 12),
            GlassInput(
              controller: _price,
              label: 'Price',
              hint: 'RM 499.00',
              helperText: 'Enter the amount in Malaysian Ringgit.',
              icon: Icons.paid_outlined,
              requiredField: true,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              validator: _priceValidator,
            ),
            SizedBox(height: 12),
            _SelectableCardGroup(
              value: _condition,
              options: _conditionOptions,
              label: 'Condition',
              icon: Icons.verified_outlined,
              requiredField: true,
              onChanged: (value) => setState(() => _condition = value),
              validator: _required('Choose the item condition.'),
            ),
            SizedBox(height: 18),
            FormSection(
              title: 'Specs',
              subtitle:
                  'Keep comparable details consistent across your listings.',
            ),
            GlassInput(
              controller: _storage,
              label: 'Storage',
              hint: '40GB',
              icon: Icons.sd_storage_outlined,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 12),
            GlassInput(
              controller: _battery,
              label: 'Battery Life',
              hint: '14h',
              icon: Icons.battery_5_bar_outlined,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 12),
            GlassInput(
              controller: _connector,
              label: 'Connector',
              hint: '30-Pin',
              icon: Icons.cable_outlined,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 18),
            FormSection(
              title: 'Description',
              subtitle:
                  'Mention included items, visible wear, and buyer notes.',
            ),
            GlassInput(
              controller: _description,
              label: 'Description',
              hint: 'Collector-ready device with light wear.',
              icon: Icons.notes_rounded,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),
          ],
        ),
      ],
    );
  }

  bool get _isLocalImage => !_asset.startsWith('assets/');

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (image == null) return;
      final storedPath = await _storePickedImage(image);
      if (!mounted) return;
      setState(() => _asset = storedPath);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not upload image. Please try again.')),
      );
    }
  }

  Future<String> _storePickedImage(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final uploads = Directory(p.join(directory.path, 'listing_photos'));
    if (!await uploads.exists()) await uploads.create(recursive: true);

    final extension = _imageExtension(image);
    final fileName =
        'listing_${DateTime.now().millisecondsSinceEpoch}$extension';
    final storedFile = File(p.join(uploads.path, fileName));
    await storedFile.writeAsBytes(await image.readAsBytes(), flush: true);
    return storedFile.path;
  }

  String _imageExtension(XFile image) {
    final nameExtension = p.extension(image.name);
    final pathExtension = p.extension(image.path);
    final extension = nameExtension.isNotEmpty ? nameExtension : pathExtension;
    return extension.isEmpty ? '.jpg' : extension.toLowerCase();
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final parsedPrice = double.parse(_price.text.trim());
    final listing = Listing(
      id:
          widget.listing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      subtitle: widget.listing?.subtitle ?? '',
      category: _category,
      price: parsedPrice,
      condition: _condition,
      description: _description.text.trim(),
      storage: _storage.text.trim(),
      battery: _battery.text.trim(),
      connector: _connector.text.trim(),
      imageAsset: _asset,
      status: 'Published',
      views: widget.listing?.views ?? 0,
    );
    if (isEditing) {
      await widget.store.update(listing);
    } else {
      await widget.store.add(listing);
    }
    if (mounted) Navigator.pop(context);
  }

  FormFieldValidator<String> _required(String message) {
    return (value) => value == null || value.trim().isEmpty ? message : null;
  }

  String? _priceValidator(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Enter a price.';
    final price = double.tryParse(input);
    if (price == null) return 'Enter a valid number.';
    if (price <= 0) return 'Price must be greater than 0.';
    return null;
  }
}

class _SelectableCardGroup extends StatelessWidget {
  const _SelectableCardGroup({
    required this.value,
    required this.options,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.requiredField = false,
    this.twoColumn = false,
    this.validator,
  });

  final String value;
  final List<String> options;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final bool requiredField;
  final bool twoColumn;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final trimmedValue = value.trim();
    final visibleOptions = [
      if (trimmedValue.isNotEmpty && !options.contains(value)) value,
      ...options,
    ];

    return FormField<String>(
      initialValue: trimmedValue.isEmpty ? null : value,
      validator: validator,
      builder: (field) {
        final currentValue = field.value ?? '';

        void selectOption(String option) {
          field.didChange(option);
          onChanged(option);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: AppTheme.label.copyWith(color: AppTheme.ink),
                ),
                if (requiredField)
                  Text(
                    ' *',
                    style: AppTheme.label.copyWith(color: AppTheme.red),
                  ),
              ],
            ),
            SizedBox(height: 7),
            if (twoColumn)
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 10) / 2;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: visibleOptions
                        .map(
                          (option) => SizedBox(
                            width: itemWidth,
                            child: _SelectableCard(
                              label: label,
                              option: option,
                              icon: icon,
                              selected: option == currentValue,
                              compact: true,
                              onTap: () => selectOption(option),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  );
                },
              )
            else
              Column(
                children: visibleOptions
                    .map(
                      (option) => Padding(
                        padding: EdgeInsets.only(
                          bottom: option == visibleOptions.last ? 0 : 10,
                        ),
                        child: _SelectableCard(
                          label: label,
                          option: option,
                          icon: icon,
                          selected: option == currentValue,
                          onTap: () => selectOption(option),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            if (field.hasError) ...[
              SizedBox(height: 7),
              Text(
                field.errorText!,
                style: TextStyle(color: AppTheme.red, fontSize: 12),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SelectableCard extends StatelessWidget {
  const _SelectableCard({
    required this.label,
    required this.option,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final String option;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? AppTheme.red : AppTheme.blue;

    return Semantics(
      button: true,
      selected: selected,
      label: '$label: $option',
      child: LiquidPressable(
        onTap: onTap,
        active: selected,
        borderRadius: BorderRadius.circular(22),
        glowColor: accent,
        child: GlassCard(
          radius: 22,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14,
            vertical: 13,
          ),
          opacity: selected ? 0.58 : 0.46,
          borderOpacity: selected ? 0.96 : 0.7,
          child: Row(
            children: [
              Icon(icon, color: accent, size: compact ? 17 : 19),
              SizedBox(width: compact ? 7 : 10),
              Expanded(
                child: Text(
                  option,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 12 : 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
              ),
              SizedBox(width: compact ? 5 : 8),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppTheme.red : AppTheme.muted,
                size: compact ? 20 : 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
