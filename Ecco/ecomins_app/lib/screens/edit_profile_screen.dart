import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ECO-FLOW',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -1.0,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.onSurface),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Header Left Aligned Content
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Refine your digital eco-identity',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 14,
                      letterSpacing: 1.0,
                    ),
                  )
                ],
              ),
            ),
            
            // Profile Picture
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 40)
                          ]
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const CircleAvatar(
                          backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuALrLLKn4sE8GvgsO95BZPyDbeAE_XH42hrc4v06dT-N4rXxP7t-6BbwXIkI3Hseumh5OF82M91aOljer_9RZqEOmqyv7pDzJwkOcfnOTpgM9JHUjFwSf4DVZeQ6O6kCMkL-DZOzgL7T9BM-IHDYAmFm-xZ-49A_or2stBIHa-aC5skyjQN9lA4ozjCSHQ9JhBu03QIYxkzl5OFG1MM4CMn_SxofK6FHjvwtzKZPmnhl7mhEGZYMSNTP6WIanNyl1bxYLSEBJIw9uw'),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)
                            ],
                          ),
                          child: const Icon(Icons.photo_camera, color: AppColors.onPrimary, size: 20),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'IMPACT LEVEL: GOLD',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Form Fields
            _buildTextField(label: 'FULL NAME', initialValue: 'Eco Pioneer', icon: Icons.person),
            const SizedBox(height: 24),
            _buildTextField(label: 'PHONE NUMBER', initialValue: '+1 (555) 000-1234', icon: Icons.call, keyboardType: TextInputType.phone),
            const SizedBox(height: 24),
            _buildTextField(label: 'EMAIL ADDRESS', initialValue: 'pioneer@eco-flow.io', icon: Icons.mail, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 24),

            // Dropdown stub
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    'PREFERRED LANGUAGE',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: 'English (US)',
                    dropdownColor: AppColors.surfaceContainerHigh,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.language, color: AppColors.onSurfaceVariant, size: 20),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
                    icon: const Icon(Icons.expand_more, color: AppColors.onSurfaceVariant),
                    items: ['English (US)', 'Spanish', 'French', 'German'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ),
                )
              ],
            ),
            const SizedBox(height: 40),

            // Action Buttons
            ElevatedButton.icon(
               onPressed: () => Navigator.pop(context),
               icon: const Text('SAVE CHANGES'),
               label: const Icon(Icons.done_all, size: 20),
               style: ElevatedButton.styleFrom(
                 backgroundColor: AppColors.primary,
                 foregroundColor: AppColors.onPrimary,
                 minimumSize: const Size(double.infinity, 56),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 elevation: 8,
                 shadowColor: AppColors.primary.withValues(alpha: 0.3),
                 textStyle: const TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.w900, fontSize: 14)
               ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
               onPressed: () => Navigator.pop(context),
               style: OutlinedButton.styleFrom(
                 foregroundColor: AppColors.primary,
                 backgroundColor: AppColors.surfaceContainerHighest,
                 minimumSize: const Size(double.infinity, 56),
                 side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 textStyle: const TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.bold, fontSize: 14)
               ),
               child: const Text('CANCEL'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String initialValue, required IconData icon, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0),
          ),
        ),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary)),
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
          ),
        )
      ],
    );
  }
}
