import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditActivityDialog extends StatefulWidget {
  final int additionalMinutes;

  const EditActivityDialog({
    super.key,
    this.additionalMinutes = 0,
  });

  @override
  State<EditActivityDialog> createState() => _EditActivityDialogState();
}

class _EditActivityDialogState extends State<EditActivityDialog> {
  late TextEditingController _minutesController;

  @override
  void initState() {
    super.initState();
    _minutesController = TextEditingController(
      text: widget.additionalMinutes.toString(),
    );
  }

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '추가 개발 시간',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _minutesController,
              decoration: const InputDecoration(
                labelText: '추가 시간 (분)',
                border: OutlineInputBorder(),
                helperText: '자동 계산에서 누락된 개발 시간을 추가해주세요',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final minutes = int.tryParse(_minutesController.text) ?? 0;
                    Navigator.pop(context, minutes);
                  },
                  child: const Text('저장'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 