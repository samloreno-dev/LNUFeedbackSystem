import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/feedback_service.dart';
import '../widgets/recaptcha_widget.dart';

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final _formKey = GlobalKey<FormState>();

  static const Color lnuNavy = Color(0xFF0B1F5C);
  static const Color lnuGold = Color(0xFFD4AF37);


  String? selectedOffice;

  String? selectedCategory;
  String feedbackText = "";
  String? captchaToken;

  List<Map<String, dynamic>> _offices = [];
  List<Map<String, dynamic>> _types = [];
  bool _isLoading = false;
  final FeedbackService _feedbackService = FeedbackService();
  int? _selectedOfficeId;
  int? _selectedTypeId;

  bool get _officeOptionsAvailable => _offices.isNotEmpty;



  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final offices = await _feedbackService.getOffices();
      final types = await _feedbackService.getTypes();
      if (mounted) {
        setState(() {
          _offices = offices;
          _types = types;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  final List<String> bannedWords = [
    // English
    "fuck", "shit", "bitch", "asshole", "damn", "cunt", "dick", "pussy",
    "bastard", "slut", "whore", "retard", "nigga", "nigger", "fag", "faggot",
    "motherfucker", "cock", "tits", "bullshit", "piss", "wanker", "twat",
    // Tagalog
    "putangina", "gago", "bobo", "tanga", "ulol", "pakyu", "tangina",
    "puta", "kantot", "iyot", "hinayupak", "lintik", "buwisit", "tarantado",
    "leche", "pesteng", "pakshet", "shunga", "ungas", "kupal", "hinampak",
    "demonyo", "bwisit", "pucha", "puchang", "piste", "yawa", "atay",
    // Variants / leetspeak
    "fck", "fuk", "sh1t", "b1tch", "paky0u", "g@go", "b0b0",
  ];

  InputDecoration customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: lnuNavy),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lnuNavy.withOpacity(0.5)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: lnuGold, width: 2),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  bool containsProfanity(String text) {
    final lowerText = text.toLowerCase();
    for (final word in bannedWords) {
      if (lowerText.contains(word)) {
        return true;
      }
    }
    return false;
  }

  bool isGibberish(String text) {
    final words = text.trim().split(RegExp(r'\\s+'));
    if (words.isEmpty || words.first.isEmpty) return true;

    int gibberishCount = 0;
    final totalWords = words.length;

    for (final word in words) {
      final clean = word.replaceAll(RegExp(r'[^\\p{L}\\p{N}]', unicode: true), '');
      if (clean.isEmpty) continue;
      final len = clean.length;

      if (len > 7 && !RegExp(r'[aeiouAEIOU]').hasMatch(clean)) {
        gibberishCount++;
        continue;
      }
      if (len > 15 && !RegExp(r'[aeiouAEIOU]').hasMatch(clean)) {
        gibberishCount++;
        continue;
      }
      if (len >= 5) {
        final lower = clean.toLowerCase();
        final charCounts = <String, int>{};
        for (var i = 0; i < lower.length; i++) {
          charCounts.update(lower[i], (v) => v + 1, ifAbsent: () => 1);
        }
        final maxCount = charCounts.values.reduce((a, b) => a > b ? a : b);
        if (maxCount / len >= 0.7) {
          gibberishCount++;
          continue;
        }
      }
      if (len >= 10 && RegExp(r'[^aeiouAEIOU\\s]{8,}').hasMatch(clean)) {
        gibberishCount++;
        continue;
      }
    }

    if (totalWords > 0 && (gibberishCount / totalWords) > 0.3) return true;

    final letters = text.replaceAll(RegExp(r'[^\\p{L}]', unicode: true), '');
    final ratio = letters.length / text.length;
    if (ratio < 0.2) return true;

    return false;
  }

  int wordCount(String text) {
    return text.trim().split(RegExp(r'\\s+')).where((w) => w.isNotEmpty).length;
  }

  Future<void> submit() async {
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Ensure all required selections/inputs are present BEFORE AI checks.
    if (selectedOffice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an office')),
      );
      return;
    }
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final trimmed = feedbackText.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback cannot be empty')),
      );
      return;
    }

    if (wordCount(trimmed) > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Feedback must be 50 words or less."),
        ),
      );
      return;
    }

    if (containsProfanity(trimmed)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please revise your feedback before submitting."),
        ),
      );
      return;
    }

    if (isGibberish(trimmed)) {
      // Only block after AI detects gibberish.
      // If you want an explicit message, replace `return;` with a SnackBar.
      return;
    }

    if (captchaToken == null || captchaToken!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete CAPTCHA")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _feedbackService.submitFeedback(
        message: trimmed,
        officeId: _selectedOfficeId,
        typeId: _selectedTypeId,
        captchaToken: captchaToken,
      );

      final bool success = result['success'] == true;

      if (success) {
        if (mounted) {
          Navigator.pushNamed(context, '/thankyou');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Submission failed'),
              backgroundColor: const Color(0xFFB91C1C),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: $e'),
            backgroundColor: const Color(0xFFB91C1C),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
  constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: lnuGold,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/lnu_logo.png',
                  height: 75,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.feedback_outlined,
                    size: 60,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome to the LNU Feedback Portal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your voice matters. Help us improve our services by sharing your experience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 80,
                    height: 4,
                    decoration: BoxDecoration(
                      color: lnuGold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  value: selectedOffice ?? '',
                  decoration: customInputDecoration("Select Office"),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem<String>(
                      value: '',
                      child: Text(
                        _isLoading
                            ? 'Loading offices...'
                            : _officeOptionsAvailable
                                ? 'Select an office'
                                : 'No offices available',
                      ),
                    ),
                    ..._offices.map((office) {
                      return DropdownMenuItem<String>(
                        value: office['id'].toString(),
                        child: Text(office['name']),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() => selectedOffice = null);
                      return;
                    }
                    setState(() {
                      selectedOffice = value;
                      _selectedOfficeId = int.tryParse(value);
                    });
                  },

                  validator: (value) {
                    if (_isLoading) {
                      return 'Please wait while offices load';
                    }
                    if (!_officeOptionsAvailable) {
                      return 'No office options available';
                    }
                    return value == null || value.isEmpty ? 'Please select an office' : null;
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: customInputDecoration("Select Category"),
                  items: _types.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['id'].toString(),
                      child: Text(type['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                      _selectedTypeId = int.tryParse(value ?? '');
                    });
                  },

                  validator: (value) =>
                      value == null ? "Please select a category" : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  minLines: 5,
                  maxLines: null,
                  decoration: customInputDecoration("Your Feedback").copyWith(
                    alignLabelWithHint: true,
                  ),
                  onChanged: (value) => feedbackText = value,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Feedback cannot be empty";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                RecaptchaWidget(
                  onVerified: (token) {
                    setState(() {
                      captchaToken = token;
                    });
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lnuNavy,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: lnuGold, width: 1.2),
                      ),
                    ),
                    child: const Text(
                      "Submit Feedback",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
