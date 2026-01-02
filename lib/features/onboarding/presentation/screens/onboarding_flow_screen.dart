import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/spark_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/spark_button.dart';
import '../widgets/onboarding_step_indicator.dart';

/// Main onboarding flow container that manages all onboarding steps
class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Collected data
  String _name = '';
  DateTime? _birthDate;
  String? _gender;
  String? _genderPreference;
  String _city = '';
  List<String> _photos = [];
  String _bio = '';

  static const int _totalSteps = 6;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: SparkDurations.normal,
        curve: SparkCurves.smooth,
      );
      setState(() => _currentStep++);
    } else {
      // Complete onboarding
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: SparkDurations.normal,
        curve: SparkCurves.smooth,
      );
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  void _completeOnboarding() {
    // TODO: Save profile to Firebase
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: SparkColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back and progress
              _buildHeader(),
              
              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _BasicInfoStep(
                      name: _name,
                      birthDate: _birthDate,
                      gender: _gender,
                      onNameChanged: (v) => setState(() => _name = v),
                      onBirthDateChanged: (v) => setState(() => _birthDate = v),
                      onGenderChanged: (v) => setState(() => _gender = v),
                    ),
                    _PreferencesStep(
                      genderPreference: _genderPreference,
                      city: _city,
                      onGenderPreferenceChanged: (v) => setState(() => _genderPreference = v),
                      onCityChanged: (v) => setState(() => _city = v),
                    ),
                    _PhotosStep(
                      photos: _photos,
                      onPhotosChanged: (v) => setState(() => _photos = v),
                    ),
                    _BioStep(
                      bio: _bio,
                      onBioChanged: (v) => setState(() => _bio = v),
                    ),
                    _QuestionnaireStep(
                      onComplete: _nextStep,
                    ),
                    _VerificationStep(
                      onComplete: _nextStep,
                      onSkip: _completeOnboarding,
                    ),
                  ],
                ),
              ),
              
              // Bottom CTA
              _buildBottomCTA(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousStep,
            icon: const Icon(Icons.arrow_back_ios_new),
            color: SparkColors.textPrimary,
          ),
          Expanded(
            child: OnboardingStepIndicator(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildBottomCTA() {
    // Determine if step is valid
    bool isValid = _isCurrentStepValid();
    
    return Padding(
      padding: SparkSpacing.screenPadding.copyWith(top: 0, bottom: 24),
      child: SparkButton(
        label: _currentStep == _totalSteps - 1 ? 'Finish' : 'Continue',
        onPressed: isValid ? _nextStep : null,
        isFullWidth: true,
      ),
    );
  }

  bool _isCurrentStepValid() {
    switch (_currentStep) {
      case 0: // Basic info
        return _name.isNotEmpty && _birthDate != null && _gender != null;
      case 1: // Preferences
        return _genderPreference != null && _city.isNotEmpty;
      case 2: // Photos
        return _photos.length >= 2;
      case 3: // Bio
        return true; // Bio is optional
      case 4: // Questionnaire
        return true; // Handle internally
      case 5: // Verification
        return true; // Can skip
      default:
        return false;
    }
  }
}

// Step 1: Basic Info
class _BasicInfoStep extends StatelessWidget {
  final String name;
  final DateTime? birthDate;
  final String? gender;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<DateTime> onBirthDateChanged;
  final ValueChanged<String> onGenderChanged;

  const _BasicInfoStep({
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.onNameChanged,
    required this.onBirthDateChanged,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: SparkSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SparkSpacing.lg),
          
          Text(
            "Let's get started",
            style: SparkTypography.displaySmall.copyWith(
              color: SparkColors.textPrimary,
            ),
          ).animate().fade().slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: SparkSpacing.xxl),
          
          // Name Input
          Text(
            'First name',
            style: SparkTypography.labelLarge.copyWith(
              color: SparkColors.textSecondary,
            ),
          ),
          const SizedBox(height: SparkSpacing.sm),
          TextFormField(
            initialValue: name,
            onChanged: onNameChanged,
            textCapitalization: TextCapitalization.words,
            style: SparkTypography.bodyLarge.copyWith(
              color: SparkColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: 'Your first name',
            ),
          ).animate().fade(delay: 100.ms),
          
          const SizedBox(height: SparkSpacing.xl),
          
          // Date of Birth
          Text(
            'When were you born?',
            style: SparkTypography.labelLarge.copyWith(
              color: SparkColors.textSecondary,
            ),
          ),
          const SizedBox(height: SparkSpacing.sm),
          _DatePickerField(
            selectedDate: birthDate,
            onDateSelected: onBirthDateChanged,
          ).animate().fade(delay: 200.ms),
          
          const SizedBox(height: SparkSpacing.xl),
          
          // Gender Selection
          Text(
            'I am a...',
            style: SparkTypography.labelLarge.copyWith(
              color: SparkColors.textSecondary,
            ),
          ),
          const SizedBox(height: SparkSpacing.md),
          _GenderSelector(
            selectedGender: gender,
            onGenderSelected: onGenderChanged,
          ).animate().fade(delay: 300.ms),
        ],
      ),
    );
  }
}

// Date Picker Field
class _DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _DatePickerField({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime(now.year - 21),
          firstDate: DateTime(now.year - 50),
          lastDate: DateTime(now.year - 18),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: SparkColors.primary,
                  surface: SparkColors.surface,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      borderRadius: SparkRadius.buttonRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: SparkColors.surfaceLight,
          borderRadius: SparkRadius.buttonRadius,
          border: Border.all(color: SparkColors.cardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedDate != null
                    ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                    : 'DD/MM/YYYY',
                style: SparkTypography.bodyLarge.copyWith(
                  color: selectedDate != null
                      ? SparkColors.textPrimary
                      : SparkColors.textTertiary,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: SparkColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// Gender Selector
class _GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String> onGenderSelected;

  const _GenderSelector({
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    final genders = [
      ('male', 'Man', '👨'),
      ('female', 'Woman', '👩'),
      ('non_binary', 'Non-binary', '🧑'),
    ];

    return Row(
      children: genders.map((g) {
        final isSelected = selectedGender == g.$1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: g != genders.last ? SparkSpacing.sm : 0,
            ),
            child: InkWell(
              onTap: () => onGenderSelected(g.$1),
              borderRadius: SparkRadius.buttonRadius,
              child: AnimatedContainer(
                duration: SparkDurations.fast,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? SparkColors.primary.withOpacity(0.15)
                      : SparkColors.surfaceLight,
                  borderRadius: SparkRadius.buttonRadius,
                  border: Border.all(
                    color: isSelected
                        ? SparkColors.primary
                        : SparkColors.cardBorder,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(g.$3, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: SparkSpacing.xs),
                    Text(
                      g.$2,
                      style: SparkTypography.labelMedium.copyWith(
                        color: isSelected
                            ? SparkColors.primary
                            : SparkColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Step 2: Preferences (placeholder)
class _PreferencesStep extends StatelessWidget {
  final String? genderPreference;
  final String city;
  final ValueChanged<String> onGenderPreferenceChanged;
  final ValueChanged<String> onCityChanged;

  const _PreferencesStep({
    required this.genderPreference,
    required this.city,
    required this.onGenderPreferenceChanged,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: SparkSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SparkSpacing.lg),
          
          Text(
            "What are you\nlooking for?",
            style: SparkTypography.displaySmall.copyWith(
              color: SparkColors.textPrimary,
            ),
          ).animate().fade().slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: SparkSpacing.xxl),
          
          Text(
            "I'm interested in...",
            style: SparkTypography.labelLarge.copyWith(
              color: SparkColors.textSecondary,
            ),
          ),
          const SizedBox(height: SparkSpacing.md),
          
          _PreferenceSelector(
            selectedPreference: genderPreference,
            onPreferenceSelected: onGenderPreferenceChanged,
          ).animate().fade(delay: 100.ms),
          
          const SizedBox(height: SparkSpacing.xl),
          
          Text(
            'Where are you based?',
            style: SparkTypography.labelLarge.copyWith(
              color: SparkColors.textSecondary,
            ),
          ),
          const SizedBox(height: SparkSpacing.sm),
          TextFormField(
            initialValue: city,
            onChanged: onCityChanged,
            style: SparkTypography.bodyLarge.copyWith(
              color: SparkColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search city...',
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: SparkColors.textSecondary,
              ),
            ),
          ).animate().fade(delay: 200.ms),
        ],
      ),
    );
  }
}

class _PreferenceSelector extends StatelessWidget {
  final String? selectedPreference;
  final ValueChanged<String> onPreferenceSelected;

  const _PreferenceSelector({
    required this.selectedPreference,
    required this.onPreferenceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final preferences = [
      ('male', 'Men'),
      ('female', 'Women'),
      ('everyone', 'Everyone'),
    ];

    return Row(
      children: preferences.map((p) {
        final isSelected = selectedPreference == p.$1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: p != preferences.last ? SparkSpacing.sm : 0,
            ),
            child: InkWell(
              onTap: () => onPreferenceSelected(p.$1),
              borderRadius: SparkRadius.buttonRadius,
              child: AnimatedContainer(
                duration: SparkDurations.fast,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? SparkColors.primary.withOpacity(0.15)
                      : SparkColors.surfaceLight,
                  borderRadius: SparkRadius.buttonRadius,
                  border: Border.all(
                    color: isSelected
                        ? SparkColors.primary
                        : SparkColors.cardBorder,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    p.$2,
                    style: SparkTypography.labelLarge.copyWith(
                      color: isSelected
                          ? SparkColors.primary
                          : SparkColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Step 3: Photos (placeholder)
class _PhotosStep extends StatelessWidget {
  final List<String> photos;
  final ValueChanged<List<String>> onPhotosChanged;

  const _PhotosStep({
    required this.photos,
    required this.onPhotosChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: SparkSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SparkSpacing.lg),
          
          Text(
            "Add your best\nphotos",
            style: SparkTypography.displaySmall.copyWith(
              color: SparkColors.textPrimary,
            ),
          ).animate().fade().slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: SparkSpacing.sm),
          
          Text(
            "At least 2 photos, up to 6",
            style: SparkTypography.bodyMedium.copyWith(
              color: SparkColors.textSecondary,
            ),
          ).animate().fade(delay: 100.ms),
          
          const SizedBox(height: SparkSpacing.xl),
          
          // Photo grid
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
              return _PhotoSlot(
                photoUrl: index < photos.length ? photos[index] : null,
                isPrimary: index == 0,
                onTap: () {
                  // TODO: Implement photo picker
                  final newPhotos = List<String>.from(photos);
                  if (index >= photos.length) {
                    newPhotos.add('placeholder_$index');
                  }
                  onPhotosChanged(newPhotos);
                },
              ).animate().fade(delay: Duration(milliseconds: 100 * index));
            },
          ),
          
          const SizedBox(height: SparkSpacing.xl),
          
          // Tips
          Container(
            padding: const EdgeInsets.all(SparkSpacing.md),
            decoration: BoxDecoration(
              color: SparkColors.surfaceLight,
              borderRadius: SparkRadius.cardRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Photo Tips',
                  style: SparkTypography.labelLarge.copyWith(
                    color: SparkColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SparkSpacing.sm),
                Text(
                  '• Clear face photos get 40% more matches\n'
                  '• Include a full body photo\n'
                  '• Show your hobbies and interests',
                  style: SparkTypography.bodySmall.copyWith(
                    color: SparkColors.textSecondary,
                  ),
                ),
              ],
            ),
          ).animate().fade(delay: 400.ms),
        ],
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final String? photoUrl;
  final bool isPrimary;
  final VoidCallback onTap;

  const _PhotoSlot({
    required this.photoUrl,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
                  // Placeholder colored box
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
    );
  }
}

// Step 4: Bio (placeholder)
class _BioStep extends StatelessWidget {
  final String bio;
  final ValueChanged<String> onBioChanged;

  const _BioStep({
    required this.bio,
    required this.onBioChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: SparkSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SparkSpacing.lg),
          
          Text(
            "Tell your story",
            style: SparkTypography.displaySmall.copyWith(
              color: SparkColors.textPrimary,
            ),
          ).animate().fade().slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: SparkSpacing.xxl),
          
          Text(
            'Bio (optional)',
            style: SparkTypography.labelLarge.copyWith(
              color: SparkColors.textSecondary,
            ),
          ),
          const SizedBox(height: SparkSpacing.sm),
          TextFormField(
            initialValue: bio,
            onChanged: onBioChanged,
            maxLines: 4,
            maxLength: 300,
            style: SparkTypography.bodyLarge.copyWith(
              color: SparkColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: 'Write something about yourself...',
            ),
          ).animate().fade(delay: 100.ms),
        ],
      ),
    );
  }
}

// Step 5: Questionnaire (placeholder)
class _QuestionnaireStep extends StatelessWidget {
  final VoidCallback onComplete;

  const _QuestionnaireStep({required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SparkSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SparkSpacing.lg),
          
          Text(
            "Quick\nquestionnaire",
            style: SparkTypography.displaySmall.copyWith(
              color: SparkColors.textPrimary,
            ),
          ).animate().fade().slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: SparkSpacing.md),
          
          Text(
            "Help us find your perfect match",
            style: SparkTypography.bodyLarge.copyWith(
              color: SparkColors.textSecondary,
            ),
          ).animate().fade(delay: 100.ms),
          
          const Spacer(),
          
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: SparkColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('📋', style: TextStyle(fontSize: 56)),
                  ),
                ),
                const SizedBox(height: SparkSpacing.lg),
                Text(
                  '25 quick questions\n~3 minutes',
                  textAlign: TextAlign.center,
                  style: SparkTypography.bodyMedium.copyWith(
                    color: SparkColors.textSecondary,
                  ),
                ),
              ],
            ),
          ).animate().fade(delay: 200.ms).scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1, 1),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }
}

// Step 6: Verification (placeholder)
class _VerificationStep extends StatelessWidget {
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const _VerificationStep({
    required this.onComplete,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SparkSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SparkSpacing.lg),
          
          Text(
            "Get verified",
            style: SparkTypography.displaySmall.copyWith(
              color: SparkColors.textPrimary,
            ),
          ).animate().fade().slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: SparkSpacing.md),
          
          Text(
            "Stand out with a verified badge",
            style: SparkTypography.bodyLarge.copyWith(
              color: SparkColors.textSecondary,
            ),
          ).animate().fade(delay: 100.ms),
          
          const Spacer(),
          
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: SparkColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: SparkShadows.glow,
                  ),
                  child: const Center(
                    child: Text('🛡️', style: TextStyle(fontSize: 56)),
                  ),
                ),
                const SizedBox(height: SparkSpacing.lg),
                Text(
                  'Verified profiles get\n3x more matches',
                  textAlign: TextAlign.center,
                  style: SparkTypography.bodyMedium.copyWith(
                    color: SparkColors.textSecondary,
                  ),
                ),
              ],
            ),
          ).animate().fade(delay: 200.ms).scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1, 1),
          ),
          
          const Spacer(),
          
          Center(
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                'Skip for now',
                style: SparkTypography.labelLarge.copyWith(
                  color: SparkColors.textSecondary,
                ),
              ),
            ),
          ).animate().fade(delay: 300.ms),
        ],
      ),
    );
  }
}
