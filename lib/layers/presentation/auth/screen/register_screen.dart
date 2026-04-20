import 'package:e_commerce_app/layers/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<AuthViewmodel>().resetRegisterPasswordVisibility();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: Consumer<AuthViewmodel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JOIN LUXE',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4.0,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"Design is not just what it looks like and feels like. Design is how it works."',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: scheme.onSurface.withOpacity(0.58),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                if (viewModel.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.error.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: scheme.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildTextField(
                  controller: _nameController,
                  label: 'First Name',
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) => _applyNameFormatting(
                    controller: _nameController,
                    viewModel: viewModel,
                    value: value,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _surnameController,
                  label: 'Last Name',
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) => _applyNameFormatting(
                    controller: _surnameController,
                    viewModel: viewModel,
                    value: value,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: viewModel.isRegisterPasswordObscured,
                  onVisibilityToggle:
                      viewModel.toggleRegisterPasswordVisibility,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmPassController,
                  label: 'Confirm Password',
                  obscureText: viewModel.isRegisterConfirmPasswordObscured,
                  onVisibilityToggle:
                      viewModel.toggleRegisterConfirmPasswordVisibility,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            final success = await viewModel
                                .registerUserWithEmailAndPassword(
                                  name: _nameController.text.trim(),
                                  surname: _surnameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  confirmPassword: _confirmPassController.text
                                      .trim(),
                                );
                            if (success && context.mounted) {
                              context.pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Registration Successful!'),
                                ),
                              );
                            }
                          },
                    child: viewModel.isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: scheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(letterSpacing: 1.5),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.pushReplacement('/login');
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withOpacity(0.58),
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    ValueChanged<String>? onChanged,
    VoidCallback? onVisibilityToggle,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: onVisibilityToggle == null
            ? null
            : IconButton(
                onPressed: onVisibilityToggle,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: scheme.onSurface.withOpacity(0.58),
                ),
              ),
      ),
    );
  }

  void _applyNameFormatting({
    required TextEditingController controller,
    required AuthViewmodel viewModel,
    required String value,
  }) {
    final formattedValue = viewModel.formatNameInput(value);
    if (formattedValue == value) {
      return;
    }

    final cursorOffset = controller.selection.baseOffset;
    final safeOffset = cursorOffset < 0
        ? formattedValue.length
        : cursorOffset.clamp(0, formattedValue.length).toInt();

    controller.value = TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: safeOffset),
      composing: TextRange.empty,
    );
  }
}
