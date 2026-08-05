import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_management_system/Features/owner/court_management/court_editor_screen.dart';
import 'package:padel_management_system/Features/owner/data/owner_models.dart';
import 'package:padel_management_system/Features/owner/data/owner_providers.dart';
import 'package:padel_management_system/Features/owner/widgets/owner_widgets.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/court_images.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

/// This screen runs entirely on the in-memory demo state in
/// `owner_providers.dart`; the app ships without a reachable backend, so a
/// Firestore round-trip here would simply hang.

final ImagePicker _imagePicker = ImagePicker();

/// Opens the create / edit court form.
Future<void> openCourtEditor(BuildContext context, {OwnerCourt? court}) async {
  await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(builder: (_) => CourtEditorScreen(court: court)),
  );
}

/// The owner's court list. Embedded in [OwnerDashboard]'s Scaffold, so it does
/// not build one of its own.
class OwnerCourtManagement extends ConsumerWidget {
  const OwnerCourtManagement({super.key, this.embedded = true});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.padel;
    final courts = ref.watch(ownerCourtsProvider);
    final activeCount = courts.where((court) => court.isActive).length;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ASizes.md,
            ASizes.md,
            ASizes.md,
            ASizes.sm,
          ),
          child: OwnerSectionHeader(
            title: 'My courts',
            subtitle: courts.isEmpty
                ? 'No courts yet'
                : '$activeCount of ${courts.length} accepting bookings',
            trailing: ElevatedButton.icon(
              onPressed: () => openCourtEditor(context),
              icon: const Icon(Icons.add_rounded, size: 19),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: courts.isEmpty
              ? OwnerEmptyState(
                  icon: Icons.sports_tennis_rounded,
                  title: 'No courts added yet',
                  message:
                      'Add your first court and players will be able to find '
                      'and book it right away.',
                  action: ElevatedButton.icon(
                    onPressed: () => openCourtEditor(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add court'),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    ASizes.md,
                    ASizes.sm,
                    ASizes.md,
                    ASizes.xl,
                  ),
                  itemCount: courts.length,
                  itemBuilder: (context, index) =>
                      _CourtCard(court: courts[index]),
                ),
        ),
      ],
    );

    if (embedded) return body;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(title: const Text('My courts')),
      body: body,
    );
  }
}

class _CourtCard extends ConsumerWidget {
  const _CourtCard({required this.court});

  final OwnerCourt court;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.padel;
    final Color statusTone = court.isActive ? AColors.success : AColors.warning;

    return OwnerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CourtGallery(court: court),
          Padding(
            padding: const EdgeInsets.all(ASizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            court.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 14,
                                color: c.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  court.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: c.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tapping the badge really pauses/resumes the court, and the
                    // dashboard "Active courts" tile moves with it.
                    Tooltip(
                      message: court.isActive
                          ? 'Pause bookings for this court'
                          : 'Start accepting bookings again',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          ref
                              .read(ownerCourtsProvider.notifier)
                              .toggleActive(court.id);
                          if (court.isActive) {
                            AppFeedback.warning(
                              '${court.name} paused',
                              'Players can no longer book this court.',
                            );
                          } else {
                            AppFeedback.success(
                              '${court.name} is live',
                              'The court is bookable again.',
                            );
                          }
                        },
                        child: OwnerStatusPill(
                          label: court.isActive ? 'Active' : 'Paused',
                          color: statusTone,
                          icon: court.isActive
                              ? Icons.check_circle_outline_rounded
                              : Icons.pause_circle_outline_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ASizes.sm + 2),
                Row(
                  children: [
                    _MetaChip(
                      icon: Icons.payments_outlined,
                      label: court.priceLabel,
                      tone: AColors.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    _MetaChip(
                      icon: Icons.photo_library_outlined,
                      label: court.images.isEmpty
                          ? 'No photos'
                          : '${court.images.length} photo'
                              '${court.images.length == 1 ? '' : 's'}',
                      tone:
                          court.images.isEmpty ? AColors.warning : AColors.info,
                    ),
                  ],
                ),
                const SizedBox(height: ASizes.sm + 2),
                Text(
                  court.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: c.textSecondary, height: 1.4),
                ),
                if (court.facilities.isNotEmpty) ...[
                  const SizedBox(height: ASizes.sm + 2),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final facility in court.facilities.take(3))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: c.primarySoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            facility,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: c.onSurfaceAccent(AColors.primaryColor),
                            ),
                          ),
                        ),
                      if (court.facilities.length > 3)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: c.fill,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: c.border),
                          ),
                          child: Text(
                            '+${court.facilities.length - 3} more',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: ASizes.md),
                // These three used to be `Expanded` widgets inside a `Wrap`,
                // which is not a Flex — it threw "Incorrect use of
                // ParentDataWidget" and took every court card down with it.
                Row(
                  children: [
                    Expanded(
                      child: OwnerActionButton(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        filled: true,
                        onPressed: () => openCourtEditor(context, court: court),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OwnerActionButton(
                        icon: Icons.image_outlined,
                        label: 'Photos',
                        tone: AColors.info,
                        onPressed: () =>
                            showCourtPhotosSheet(context, court.id),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OwnerActionButton(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete',
                        tone: AColors.error,
                        onPressed: () => _confirmDelete(context, ref),
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

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await AppFeedback.confirm(
      context,
      title: 'Delete ${court.name}?',
      message: 'The court, its photos and its upcoming bookings are removed '
          'from the player app.',
      confirmLabel: 'Delete',
      icon: Icons.delete_forever_rounded,
      destructive: true,
    );
    if (!ok) return;
    ref.read(ownerCourtsProvider.notifier).remove(court.id);
    AppFeedback.success('Court deleted', '${court.name} was removed.');
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.soft(tone),
        borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c.onSurfaceAccent(tone)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c.onSurfaceAccent(tone),
            ),
          ),
        ],
      ),
    );
  }
}

/// Swipeable photo strip on top of a court card.
class _CourtGallery extends StatefulWidget {
  const _CourtGallery({required this.court});

  final OwnerCourt court;

  @override
  State<_CourtGallery> createState() => _CourtGalleryState();
}

class _CourtGalleryState extends State<_CourtGallery> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.court.images;
    final height = MediaQuery.sizeOf(context).width > 600 ? 240.0 : 176.0;

    if (images.isEmpty) {
      return SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CourtImagePlaceholder(iconSize: 46),
            const CourtImageScrim(),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => showCourtPhotosSheet(context, widget.court.id),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(height: ASizes.xs),
                      Text(
                        'Add court photos',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final safeIndex = _index.clamp(0, images.length - 1);

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (_, i) => CourtImageView(source: images[i]),
          ),
          const IgnorePointer(child: CourtImageScrim()),
          Positioned(
            top: ASizes.sm,
            right: ASizes.sm,
            child: _GalleryButton(
              icon: Icons.photo_library_outlined,
              tooltip: 'Manage photos',
              onTap: () => showCourtPhotosSheet(context, widget.court.id),
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: ASizes.sm,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < images.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == safeIndex ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: i == safeIndex ? 0.95 : 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GalleryButton extends StatelessWidget {
  const _GalleryButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: 0.45),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

/// Photo manager for a court: add from the gallery, add a stock shot, remove.
Future<void> showCourtPhotosSheet(BuildContext context, String courtId) {
  return showAppSheet<void>(
    context,
    title: 'Court photos',
    subtitle: 'Swipe-through gallery shown to players',
    icon: Icons.photo_library_outlined,
    heightFactor: 0.8,
    child: _CourtPhotosBody(courtId: courtId),
  );
}

class _CourtPhotosBody extends ConsumerWidget {
  const _CourtPhotosBody({required this.courtId});

  final String courtId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.padel;
    final courts = ref.watch(ownerCourtsProvider);
    final matches = courts.where((court) => court.id == courtId);

    if (matches.isEmpty) {
      return const OwnerEmptyState(
        icon: Icons.image_not_supported_outlined,
        title: 'Court removed',
        message: 'This court is no longer in your list.',
      );
    }

    final court = matches.first;
    final notifier = ref.read(ownerCourtsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        ASizes.md,
        ASizes.md,
        ASizes.md,
        ASizes.lg,
      ),
      children: [
        Text(
          court.name,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: ASizes.sm + 4),
        if (court.images.isEmpty)
          const _EmptyPhotos()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: court.images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CourtImageView(source: court.images[index]),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            notifier.removeImageAt(court.id, index);
                            AppFeedback.info(
                              'Photo removed',
                              '${court.name} now has '
                                  '${court.images.length - 1} photos.',
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: ASizes.lg),
        ElevatedButton.icon(
          onPressed: () => _pickFromGallery(notifier, court),
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Pick from gallery'),
        ),
        const SizedBox(height: ASizes.sm + 2),
        OutlinedButton.icon(
          onPressed: () {
            notifier.addImage(court.id, CourtImages.uploadFallback);
            AppFeedback.success(
              'Stock photo added',
              'Useful while you wait for the club\'s own shots.',
            );
          },
          icon: const Icon(Icons.collections_bookmark_outlined),
          label: const Text('Add a stock padel photo'),
        ),
        const SizedBox(height: ASizes.sm + 2),
        Text(
          'Photos are stored on this device for the demo — nothing is uploaded.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: c.textMuted),
        ),
      ],
    );
  }

  Future<void> _pickFromGallery(
    OwnerCourtsNotifier notifier,
    OwnerCourt court,
  ) async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      // The picked file used to be thrown away and a hard-coded stock URL added
      // instead, so the owner never saw their own photo.
      notifier.addImage(court.id, image.path);
      AppFeedback.success('Photo added', 'It now appears on the court card.');
    } catch (error) {
      // image_picker has no implementation on some desktop targets.
      AppFeedback.error(
        'Gallery unavailable',
        'Use "Add a stock padel photo" instead on this device.',
      );
      debugPrint('Court photo pick failed: $error');
    }
  }
}

class _EmptyPhotos extends StatelessWidget {
  const _EmptyPhotos();

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: c.fill,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Icon(Icons.image_outlined, size: 34, color: c.textMuted),
          const SizedBox(height: 10),
          Text(
            'No photos yet',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Courts with photos get noticeably more bookings.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Court picker used by the dashboard's "Court photos" quick action.
///
/// The picker returns the chosen id and *then* the caller opens the photo
/// sheet — reaching for `context` after the sheet has popped is what used to
/// throw "Looking up a deactivated widget's ancestor is unsafe".
Future<void> showCourtPickerSheet(BuildContext context) async {
  final courtId = await showAppSheet<String>(
    context,
    title: 'Choose a court',
    subtitle: 'Then manage that court\'s photo gallery',
    icon: Icons.photo_camera_back_outlined,
    heightFactor: 0.7,
    child: const _CourtPickerBody(),
  );
  if (courtId == null || !context.mounted) return;
  await showCourtPhotosSheet(context, courtId);
}

class _CourtPickerBody extends ConsumerWidget {
  const _CourtPickerBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.padel;
    final courts = ref.watch(ownerCourtsProvider);

    if (courts.isEmpty) {
      return const OwnerEmptyState(
        icon: Icons.sports_tennis_rounded,
        title: 'No courts yet',
        message: 'Add a court first, then you can give it a photo gallery.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        ASizes.md,
        ASizes.md,
        ASizes.md,
        ASizes.lg,
      ),
      itemCount: courts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final court = courts[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
            onTap: () => Navigator.of(context).pop(court.id),
            child: Ink(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.fill,
                borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
                border: Border.all(color: c.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: court.images.isEmpty
                          ? const CourtImagePlaceholder(iconSize: 22)
                          : CourtImageView(source: court.images.first),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          court.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          court.images.isEmpty
                              ? 'No photos yet'
                              : '${court.images.length} photo'
                                  '${court.images.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: c.textMuted),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
