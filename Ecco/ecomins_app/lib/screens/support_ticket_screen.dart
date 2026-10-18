import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SupportTicketScreen extends StatelessWidget {
  const SupportTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 20),
        ),
        title: const Text('New Support Ticket', style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How can we help you?', style: TextStyle(color: AppColors.onSurface, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text('Our eco-concierges will get back to you within 24 hours.', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
            const SizedBox(height: 32),
            
            _buildLabel('Category'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: 'Order Issue',
                  dropdownColor: AppColors.surfaceContainerHigh,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.onSurfaceVariant),
                  style: const TextStyle(color: AppColors.onSurface, fontSize: 15),
                  items: <String>['Order Issue', 'Service Complaint', 'App Bug', 'General Inquiry']
                      .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (_) {},
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            _buildLabel('Subject'),
            _buildTextField(hint: 'e.g., Missing items in my recent order'),
            const SizedBox(height: 24),

            _buildLabel('Description'),
            _buildTextField(hint: 'Please provide as much detail as possible...', maxLines: 6),
            const SizedBox(height: 24),
            
            _buildLabel('Attachments (Optional)'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5), style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, color: AppColors.onSurfaceVariant, size: 32),
                  const SizedBox(height: 12),
                  Text('Tap to upload photos or documents', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {},
                child: const Text('Submit Ticket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField({required String hint, int maxLines = 1}) {
    return TextFormField(
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}
