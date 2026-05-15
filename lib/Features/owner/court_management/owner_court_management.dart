import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/sizes.dart';

// TODO: Firebase removed - Currently using dummy/fake data for courts
// When ready to implement, replace _getDummyCourts() with Firebase Firestore queries
// Example Firebase imports (commented out):
// import 'package:cloud_firestore/cloud_firestore.dart';
// FirebaseFirestore.instance.collection('owner_courts').get()

class OwnerCourtManagement extends ConsumerStatefulWidget {
  const OwnerCourtManagement({super.key});

  @override
  ConsumerState<OwnerCourtManagement> createState() =>
      _OwnerCourtManagementState();
}

class _OwnerCourtManagementState extends ConsumerState<OwnerCourtManagement> {
  late List<OwnerCourt> _courts;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Loading dummy/fake courts data (Firebase commented out)
    _courts = _getDummyCourts();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDark ? AColors.dark : AColors.light,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth > 600 ? ASizes.lg : ASizes.md,
          vertical: ASizes.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with add button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Courts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AColors.textprimary,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddCourtDialog,
                  icon: const Icon(Icons.add, size: ASizes.iconSm),
                  label: const Text(
                    'Add Court',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: ASizes.fontSizeSm,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: ASizes.md,
                      vertical: ASizes.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ASizes.buttonRadius),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ASizes.lg),

            // Courts List
            _courts.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: ASizes.lg * 2,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.sports_tennis,
                            size: ASizes.iconLg * 2,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: ASizes.md),
                          Text(
                            'No courts added yet',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey,
                                      fontSize: ASizes.fontSizeMd,
                                    ),
                          ),
                          const SizedBox(height: ASizes.sm),
                          Text(
                            'Tap "Add Court" to create your first court',
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey[500] : Colors.grey[600],
                              fontSize: ASizes.fontSizeSm,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _courts.length,
                    itemBuilder: (context, index) {
                      return _buildCourtCard(
                        context,
                        _courts[index],
                        index,
                        isDark,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourtCard(
    BuildContext context,
    OwnerCourt court,
    int index,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: ASizes.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(ASizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Court Images
          Container(
            height: MediaQuery.of(context).size.width > 600 ? 250 : 180,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(ASizes.borderRadiusLg),
              ),
              color: Colors.grey[300],
            ),
            child: court.images.isEmpty
                ? Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: ASizes.iconLg * 1.5,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: ASizes.sm),
                          Text(
                            'No images',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: ASizes.fontSizeSm,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : PageView.builder(
                    itemCount: court.images.length,
                    itemBuilder: (_, i) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            court.images[i],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: ASizes.iconLg,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          ),
                          // Delete image button
                          Positioned(
                            top: ASizes.sm,
                            right: ASizes.sm,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  court.images.removeAt(i);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(ASizes.xs),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: ASizes.iconSm,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // Court Details
          Padding(
            padding: const EdgeInsets.all(ASizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            court.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ASizes.fontSizeLg,
                                  color: isDark
                                      ? Colors.white
                                      : AColors.textprimary,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: ASizes.xs),
                          Text(
                            court.location,
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: ASizes.fontSizeSm,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ASizes.sm,
                        vertical: ASizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: ASizes.fontSizeSm - 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ASizes.sm),

                // Price
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ASizes.sm,
                    vertical: ASizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
                  ),
                  child: Text(
                    'Price: \$${court.pricePerHour}/hour',
                    style: const TextStyle(
                      color: AColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: ASizes.fontSizeSm,
                    ),
                  ),
                ),
                const SizedBox(height: ASizes.sm),

                // Description
                Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ASizes.fontSizeSm,
                    color: isDark ? Colors.white : AColors.textprimary,
                  ),
                ),
                const SizedBox(height: ASizes.xs),
                Text(
                  court.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: ASizes.fontSizeSm - 1,
                  ),
                ),
                const SizedBox(height: ASizes.sm),

                // Facilities
                if (court.facilities.isNotEmpty)
                  Wrap(
                    spacing: ASizes.xs,
                    runSpacing: ASizes.xs,
                    children: court.facilities.take(3).map((facility) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ASizes.sm,
                          vertical: ASizes.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AColors.primaryColor.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(ASizes.borderRadiusMd),
                        ),
                        child: Text(
                          facility,
                          style: const TextStyle(
                            fontSize: ASizes.fontSizeSm - 2,
                            color: AColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: ASizes.md),

                // Action Buttons
                Wrap(
                  spacing: ASizes.sm,
                  runSpacing: ASizes.sm,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        width: 110,
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditCourtDialog(court, index),
                          icon: const Icon(
                            Icons.edit,
                            size: ASizes.iconMd,
                          ),
                          label: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: ASizes.fontSizeSm,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(ASizes.buttonRadius),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        width: 110,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showUploadImagesDialog(court, index),
                          icon: const Icon(
                            Icons.image,
                            size: ASizes.iconMd,
                          ),
                          label: const Text(
                            'Photos',
                            style: TextStyle(
                              fontSize: ASizes.fontSizeSm,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(ASizes.buttonRadius),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        width: 110,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _courts.removeAt(index);
                            });
                          },
                          icon: const Icon(
                            Icons.delete,
                            size: ASizes.iconMd,
                          ),
                          label: const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: ASizes.fontSizeSm,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(ASizes.buttonRadius),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCourtDialog() {
    _showCourtDialog(null, null);
  }

  void _showEditCourtDialog(OwnerCourt court, int index) {
    _showCourtDialog(court, index);
  }

  void _showCourtDialog(OwnerCourt? court, int? index) {
    final nameController = TextEditingController(text: court?.name ?? '');
    final locationController =
        TextEditingController(text: court?.location ?? '');
    final priceController =
        TextEditingController(text: court?.pricePerHour.toString() ?? '');
    final descriptionController =
        TextEditingController(text: court?.description ?? '');
    final facilitiesController =
        TextEditingController(text: court?.facilities.join(', ') ?? '');

    showDialog(
      context: context,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final screenWidth = MediaQuery.of(context).size.width;
        final maxWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: ASizes.md,
            vertical: ASizes.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ASizes.borderRadiusLg * 2),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            decoration: BoxDecoration(
              color: isDark ? AColors.dark : Colors.white,
              borderRadius: BorderRadius.circular(ASizes.borderRadiusLg * 2),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(ASizes.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          court == null ? 'Add Court' : 'Edit Court',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark ? Colors.white : AColors.textprimary,
                              ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.close,
                            color: isDark ? Colors.white : AColors.textprimary,
                            size: ASizes.iconMd,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ASizes.md),

                    // Court Name Field
                    _buildThemedTextField(
                      controller: nameController,
                      label: 'Court Name',
                      hint: 'Enter court name',
                      icon: Icons.business,
                      isDark: isDark,
                    ),
                    const SizedBox(height: ASizes.md),

                    // Location Field
                    _buildThemedTextField(
                      controller: locationController,
                      label: 'Location',
                      hint: 'Enter location',
                      icon: Icons.location_on,
                      isDark: isDark,
                    ),
                    const SizedBox(height: ASizes.md),

                    // Price Field
                    _buildThemedTextField(
                      controller: priceController,
                      label: 'Price per Hour (\$)',
                      hint: 'Enter price',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      isDark: isDark,
                    ),
                    const SizedBox(height: ASizes.md),

                    // Description Field
                    _buildThemedTextField(
                      controller: descriptionController,
                      label: 'Description',
                      hint: 'Enter court description',
                      icon: Icons.description,
                      maxLines: 4,
                      isDark: isDark,
                    ),
                    const SizedBox(height: ASizes.md),

                    // Facilities Field
                    _buildThemedTextField(
                      controller: facilitiesController,
                      label: 'Facilities (comma separated)',
                      hint: 'e.g., AC, Lighting, Cafe',
                      icon: Icons.stars,
                      maxLines: 3,
                      isDark: isDark,
                    ),
                    const SizedBox(height: ASizes.lg),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ASizes.lg,
                              vertical: ASizes.sm,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: ASizes.md),
                        ElevatedButton(
                          onPressed: () {
                            if (court == null) {
                              setState(() {
                                _courts.add(
                                  OwnerCourt(
                                    id: DateTime.now().toString(),
                                    name: nameController.text,
                                    location: locationController.text,
                                    pricePerHour:
                                        double.tryParse(priceController.text) ??
                                            0,
                                    description: descriptionController.text,
                                    facilities: facilitiesController.text
                                        .split(',')
                                        .map((e) => e.trim())
                                        .where((e) => e.isNotEmpty)
                                        .toList(),
                                    images: [],
                                  ),
                                );
                              });
                            } else {
                              setState(() {
                                _courts[index!] = OwnerCourt(
                                  id: court.id,
                                  name: nameController.text,
                                  location: locationController.text,
                                  pricePerHour:
                                      double.tryParse(priceController.text) ??
                                          0,
                                  description: descriptionController.text,
                                  facilities: facilitiesController.text
                                      .split(',')
                                      .map((e) => e.trim())
                                      .where((e) => e.isNotEmpty)
                                      .toList(),
                                  images: court.images,
                                );
                              });
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AColors.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: ASizes.lg,
                              vertical: ASizes.sm,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(ASizes.buttonRadius),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ASizes.fontSizeSm,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AColors.textprimary,
          ),
        ),
        const SizedBox(height: ASizes.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            color: isDark ? Colors.white : AColors.textprimary,
            fontSize: ASizes.fontSizeSm,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: ASizes.fontSizeSm,
            ),
            prefixIcon: Icon(
              icon,
              color: AColors.primaryColor,
              size: ASizes.iconSm,
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
              borderSide: const BorderSide(
                color: AColors.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: ASizes.md,
              vertical: ASizes.md,
            ),
          ),
        ),
      ],
    );
  }

  void _showUploadImagesDialog(OwnerCourt court, int index) {
    showDialog(
      context: context,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final screenWidth = MediaQuery.of(context).size.width;
        final maxWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.85;

        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: ASizes.md,
            vertical: ASizes.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ASizes.borderRadiusLg * 2),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            decoration: BoxDecoration(
              color: isDark ? AColors.dark : Colors.white,
              borderRadius: BorderRadius.circular(ASizes.borderRadiusLg * 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(ASizes.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Court Images',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark ? Colors.white : AColors.textprimary,
                            ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          color: isDark ? Colors.white : AColors.textprimary,
                          size: ASizes.iconMd,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ASizes.md),

                  // Description
                  Text(
                    'Choose an image to upload to this court',
                    style: TextStyle(
                      fontSize: ASizes.fontSizeSm,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ASizes.lg),

                  // Upload Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final XFile? image = await _imagePicker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setState(() {
                            _courts[index].images.add(
                                  'https://via.placeholder.com/300x200?text=Court+Image',
                                );
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Image added successfully'),
                              backgroundColor: AColors.primaryColor,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.image, size: ASizes.iconMd),
                      label: const Text(
                        'Pick from Gallery',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: ASizes.fontSizeSm,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ASizes.buttonRadius),
                        ),
                        elevation: ASizes.buttonElevation,
                      ),
                    ),
                  ),
                  const SizedBox(height: ASizes.md),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ASizes.buttonRadius),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: ASizes.fontSizeSm,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<OwnerCourt> _getDummyCourts() {
    // Dummy/Fake data - Replace with Firebase Firestore queries when ready
    // Firebase query example (currently commented out):
    // final querySnapshot = await FirebaseFirestore.instance.collection('owner_courts').get();
    // return querySnapshot.docs.map((doc) => OwnerCourt.fromFirestore(doc)).toList();

    return [
      OwnerCourt(
        id: '1',
        name: 'Al Noor Padel Club (نوادي النور)',
        location: 'Downtown Cairo',
        pricePerHour: 250.0,
        description:
            'Premium padel courts with professional lighting and excellent facilities. Perfect for tournament play and training sessions.',
        facilities: [
          'Air Conditioning',
          'Professional Lighting',
          'Cafe',
          'Parking',
          'Locker Rooms'
        ],
        images: [
          'https://via.placeholder.com/300x200?text=Al+Noor+Padel+1',
          'https://via.placeholder.com/300x200?text=Al+Noor+Padel+2',
        ],
      ),
      OwnerCourt(
        id: '2',
        name: 'Al Ahmar Padel Club (النادي الأحمر)',
        location: 'New Cairo',
        pricePerHour: 300.0,
        description:
            'Modern and advanced padel courts in a strategic location. High-quality service with professional staff and VIP facilities.',
        facilities: [
          'Advanced Air Conditioning',
          'International Courts',
          'Restaurant & Cafe',
          'Parking',
          'VIP Rooms',
          'Training Hall'
        ],
        images: [
          'https://via.placeholder.com/300x200?text=Al+Ahmar+1',
          'https://via.placeholder.com/300x200?text=Al+Ahmar+2',
        ],
      ),
      OwnerCourt(
        id: '3',
        name: 'Athletes Club (ناد الرياضيين)',
        location: 'Giza',
        pricePerHour: 200.0,
        description:
            'Sports padel courts at competitive prices with professional standards. Suitable for both professional players and hobbyists.',
        facilities: [
          'Air Conditioning',
          'Professional Lighting',
          'Reception',
          'Parking',
          'Changing Rooms',
          'مياه ومشروبات'
        ],
        images: [
          'https://via.placeholder.com/300x200?text=Athletes+Club+1',
          'https://via.placeholder.com/300x200?text=Athletes+Club+2',
        ],
      ),
      OwnerCourt(
        id: '4',
        name: 'Alexandria Courts',
        location: 'Alexandria',
        pricePerHour: 180.0,
        description:
            'Beautiful padel courts overlooking the Mediterranean Sea with excellent facilities and professional setup.',
        facilities: [
          'Air Conditioning',
          'Seafood Restaurant',
          'Parking',
          'Locker Rooms',
          'Private Beach',
          'Swimming Pool'
        ],
        images: [
          'https://via.placeholder.com/300x200?text=Alexandria+1',
          'https://via.placeholder.com/300x200?text=Alexandria+2',
        ],
      ),
    ];
  }
}

class OwnerCourt {
  final String id;
  final String name;
  final String location;
  final double pricePerHour;
  final String description;
  final List<String> facilities;
  final List<String> images;

  OwnerCourt({
    required this.id,
    required this.name,
    required this.location,
    required this.pricePerHour,
    required this.description,
    required this.facilities,
    required this.images,
  });
}
