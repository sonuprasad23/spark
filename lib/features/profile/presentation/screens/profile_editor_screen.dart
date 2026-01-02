import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/spark_theme.dart';
import '../../../../shared/widgets/spark_button.dart';

/// Profile editor screen for editing user profile
class ProfileEditorScreen extends StatefulWidget {
  const ProfileEditorScreen({super.key});

  @override
  State<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> {
  final _nameController = TextEditingController(text: 'Your Name');
  final _bioController = TextEditingController(text: 'Love traveling, photography, and trying new cuisines. Looking for someone to share adventures with! 🌍✈️');
  
  String _city = 'Bangalore';
  String _gender = 'male';
  String _lookingFor = 'female';
  int _age = 24;
  
  List<String?> _photos = [
    'photo1', 'photo2', null, null, null, null
  ];
  
  List<String> _interests = ['Travel', 'Photography', 'Cooking', 'Music', 'Fitness'];
  
  bool _hasChanges = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  void _saveProfile() async {
    HapticFeedback.mediumImpact();
    // TODO: Save to Firebase
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: SparkColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: SparkSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photos section
                      _buildPhotosSection(),
                      
                      const SizedBox(height: SparkSpacing.xl),
                      
                      // Basic info
                      _buildBasicInfoSection(),
                      
                      const SizedBox(height: SparkSpacing.xl),
                      
                      // Bio
                      _buildBioSection(),
                      
                      const SizedBox(height: SparkSpacing.xl),
                      
                      // Interests
                      _buildInterestsSection(),
                      
                      const SizedBox(height: SparkSpacing.xl),
                      
                      // Prompts
                      _buildPromptsSection(),
                      
                      const SizedBox(height: SparkSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(SparkSpacing.md),
      decoration: BoxDecoration(
        color: SparkColors.surface,
        border: Border(
          bottom: BorderSide(color: SparkColors.cardBorder),
        ),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: SparkTypography.labelLarge.copyWith(
                color: SparkColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Edit Profile',
              textAlign: TextAlign.center,
              style: SparkTypography.headlineSmall.copyWith(
                color: SparkColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: _hasChanges ? _saveProfile : null,
            child: Text(
              'Save',
              style: SparkTypography.labelLarge.copyWith(
                color: _hasChanges ? SparkColors.primary : SparkColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Photos', 'Add up to 6 photos'),
        
        const SizedBox(height: SparkSpacing.md),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: SparkSpacing.sm,
            mainAxisSpacing: SparkSpacing.sm,
            childAspectRatio: 0.75,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            final hasPhoto = index < _photos.length && _photos[index] != null;
            
            return _PhotoSlot(
              photoUrl: hasPhoto ? _photos[index] : null,
              isPrimary: index == 0,
              onTap: () {
                // TODO: Open image picker
                if (!hasPhoto) {
                  setState(() {
                    if (index >= _photos.length) {
                      _photos.add('photo${index + 1}');
                    } else {
                      _photos[index] = 'photo${index + 1}';
                    }
                  });
                  _markChanged();
                }
              },
              onRemove: hasPhoto ? () {
                setState(() {
                  _photos[index] = null;
                });
                _markChanged();
              } : null,
            );
          },
        ),
        
        const SizedBox(height: SparkSpacing.sm),
        
        Row(
          children: [
            Icon(Icons.info_outline, size: 14, color: SparkColors.textTertiary),
            const SizedBox(width: SparkSpacing.xs),
            Text(
              'Drag to reorder. First photo is your main profile picture.',
              style: SparkTypography.bodySmall.copyWith(
                color: SparkColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    ).animate().fade(delay: 100.ms);
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Basic Info', null),
        
        const SizedBox(height: SparkSpacing.md),
        
        // Name
        _buildTextField(
          label: 'Name',
          controller: _nameController,
          onChanged: (_) => _markChanged(),
        ),
        
        const SizedBox(height: SparkSpacing.md),
        
        // Age and Location
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Age',
                value: _age.toString(),
                items: List.generate(33, (i) => (18 + i).toString()),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _age = int.parse(val));
                    _markChanged();
                  }
                },
              ),
            ),
            const SizedBox(width: SparkSpacing.md),
            Expanded(
              flex: 2,
              child: _buildTextField(
                label: 'City',
                initialValue: _city,
                onChanged: (val) {
                  _city = val;
                  _markChanged();
                },
              ),
            ),
          ],
        ),
      ],
    ).animate().fade(delay: 200.ms);
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('About Me', null),
            Text(
              '${_bioController.text.length}/300',
              style: SparkTypography.labelSmall.copyWith(
                color: SparkColors.textTertiary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: SparkSpacing.md),
        
        Container(
          decoration: BoxDecoration(
            color: SparkColors.surface,
            borderRadius: SparkRadius.cardRadius,
            border: Border.all(color: SparkColors.cardBorder),
          ),
          child: TextField(
            controller: _bioController,
            maxLines: 4,
            maxLength: 300,
            style: SparkTypography.bodyMedium.copyWith(
              color: SparkColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Tell others about yourself...',
              hintStyle: SparkTypography.bodyMedium.copyWith(
                color: SparkColors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(SparkSpacing.md),
              counterText: '',
            ),
            onChanged: (_) {
              setState(() {}); // Update counter
              _markChanged();
            },
          ),
        ),
      ],
    ).animate().fade(delay: 300.ms);
  }

  Widget _buildInterestsSection() {
    final allInterests = [
      'Travel', 'Photography', 'Cooking', 'Music', 'Fitness',
      'Reading', 'Movies', 'Art', 'Gaming', 'Sports',
      'Dancing', 'Yoga', 'Hiking', 'Coffee', 'Food',
      'Fashion', 'Technology', 'Pets', 'Nature', 'Writing',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Interests', 'Select up to 10'),
        
        const SizedBox(height: SparkSpacing.md),
        
        Wrap(
          spacing: SparkSpacing.sm,
          runSpacing: SparkSpacing.sm,
          children: allInterests.map((interest) {
            final isSelected = _interests.contains(interest);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _interests.remove(interest);
                  } else if (_interests.length < 10) {
                    _interests.add(interest);
                  }
                });
                _markChanged();
              },
              child: AnimatedContainer(
                duration: SparkDurations.fast,
                padding: const EdgeInsets.symmetric(
                  horizontal: SparkSpacing.md,
                  vertical: SparkSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? SparkColors.primary.withOpacity(0.15)
                      : SparkColors.surface,
                  borderRadius: SparkRadius.chipRadius,
                  border: Border.all(
                    color: isSelected
                        ? SparkColors.primary
                        : SparkColors.cardBorder,
                  ),
                ),
                child: Text(
                  interest,
                  style: SparkTypography.labelMedium.copyWith(
                    color: isSelected
                        ? SparkColors.primary
                        : SparkColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fade(delay: 400.ms);
  }

  Widget _buildPromptsSection() {
    final prompts = [
      {'prompt': 'A perfect first date would be...', 'answer': 'Coffee and a walk through a bookstore'},
      {'prompt': 'I\'m looking for...', 'answer': ''},
      {'prompt': 'My ideal weekend looks like...', 'answer': ''},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Prompts', 'Answer up to 3 prompts'),
        
        const SizedBox(height: SparkSpacing.md),
        
        ...prompts.asMap().entries.map((entry) {
          final index = entry.key;
          final prompt = entry.value;
          
          return Container(
            margin: const EdgeInsets.only(bottom: SparkSpacing.md),
            padding: const EdgeInsets.all(SparkSpacing.md),
            decoration: BoxDecoration(
              color: SparkColors.surface,
              borderRadius: SparkRadius.cardRadius,
              border: Border.all(color: SparkColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prompt['prompt']!,
                  style: SparkTypography.labelMedium.copyWith(
                    color: SparkColors.primary,
                  ),
                ),
                const SizedBox(height: SparkSpacing.sm),
                TextField(
                  style: SparkTypography.bodyMedium.copyWith(
                    color: SparkColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write your answer...',
                    hintStyle: SparkTypography.bodyMedium.copyWith(
                      color: SparkColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: 2,
                  onChanged: (_) => _markChanged(),
                ),
              ],
            ),
          );
        }),
        
        // Add prompt button
        OutlinedButton.icon(
          onPressed: () {
            // TODO: Show prompt picker
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Prompt'),
          style: OutlinedButton.styleFrom(
            foregroundColor: SparkColors.textSecondary,
            side: BorderSide(color: SparkColors.cardBorder),
          ),
        ),
      ],
    ).animate().fade(delay: 500.ms);
  }

  Widget _buildSectionHeader(String title, String? subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: SparkTypography.headlineSmall.copyWith(
            color: SparkColors.textPrimary,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: SparkTypography.bodySmall.copyWith(
              color: SparkColors.textTertiary,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SparkTypography.labelMedium.copyWith(
            color: SparkColors.textSecondary,
          ),
        ),
        const SizedBox(height: SparkSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: SparkColors.surface,
            borderRadius: SparkRadius.buttonRadius,
            border: Border.all(color: SparkColors.cardBorder),
          ),
          child: TextField(
            controller: controller,
            style: SparkTypography.bodyMedium.copyWith(
              color: SparkColors.textPrimary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SparkSpacing.md,
                vertical: SparkSpacing.sm + 2,
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SparkTypography.labelMedium.copyWith(
            color: SparkColors.textSecondary,
          ),
        ),
        const SizedBox(height: SparkSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: SparkSpacing.md),
          decoration: BoxDecoration(
            color: SparkColors.surface,
            borderRadius: SparkRadius.buttonRadius,
            border: Border.all(color: SparkColors.cardBorder),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: SparkColors.surface,
            style: SparkTypography.bodyMedium.copyWith(
              color: SparkColors.textPrimary,
            ),
            items: items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            )).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final String? photoUrl;
  final bool isPrimary;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _PhotoSlot({
    required this.photoUrl,
    required this.isPrimary,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: SparkRadius.cardRadius,
          child: Container(
            decoration: BoxDecoration(
              color: SparkColors.surfaceLight,
              borderRadius: SparkRadius.cardRadius,
              border: Border.all(
                color: isPrimary ? SparkColors.primary : SparkColors.cardBorder,
                width: isPrimary ? 2 : 1,
              ),
            ),
            child: photoUrl != null
                ? Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: SparkColors.secondaryGradient,
                          borderRadius: SparkRadius.cardRadius,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                      if (isPrimary)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: SparkColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Main',
                              style: SparkTypography.labelSmall.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: SparkColors.surfaceLighter,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: SparkColors.textSecondary,
                        ),
                      ),
                      if (isPrimary) ...[
                        const SizedBox(height: SparkSpacing.xs),
                        Text(
                          'Primary',
                          style: SparkTypography.labelSmall.copyWith(
                            color: SparkColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
        
        // Remove button
        if (onRemove != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: SparkColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
