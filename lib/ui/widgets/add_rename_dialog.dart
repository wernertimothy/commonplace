import 'package:flutter/material.dart';

/// Shows a single-text-field dialog for adding or renaming an item.
///
/// Returns the entered name, or null if cancelled / empty.
Future<String?> showNameDialog(
  BuildContext context, {
  required String title,
  String? initialValue,
  String confirmLabel = 'Save',
}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Name'),
          onSubmitted: (_) => _submit(context, controller),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _submit(context, controller),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
}

void _submit(BuildContext context, TextEditingController controller) {
  final text = controller.text.trim();
  Navigator.pop(context, text.isEmpty ? null : text);
}

/// Result of [showItemDialog]: a required name and an optional description.
class ItemDetails {
  final String name;
  final String description;

  const ItemDetails(this.name, this.description);
}

/// Dialog with a required name field and an optional multiline description.
/// Used to create projects & topics. Returns null if cancelled / name empty.
Future<ItemDetails?> showItemDialog(
  BuildContext context, {
  required String title,
  String confirmLabel = 'Create',
}) {
  final nameController = TextEditingController();
  final descController = TextEditingController();

  void submit() {
    final name = nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, ItemDetails(name, descController.text.trim()));
  }

  return showDialog<ItemDetails>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Name'),
              onSubmitted: (_) => submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(onPressed: submit, child: Text(confirmLabel)),
        ],
      );
    },
  );
}

/// Multiline dialog for editing only a description. Returns the new text
/// (may be empty to clear it), or null if cancelled.
Future<String?> showDescriptionDialog(
  BuildContext context, {
  String? initialValue,
}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Description'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Add an optional description…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            // Return the raw text (possibly empty) so callers can clear it;
            // a sentinel-free contract: null only means "cancelled".
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
