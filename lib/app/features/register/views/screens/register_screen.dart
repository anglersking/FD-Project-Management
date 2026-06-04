import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_management/app/constans/app_constants.dart';
import '../../controllers/register_controller.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kSpacing * 2),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(),
                const SizedBox(height: kSpacing),
                _buildTitle(),
                const SizedBox(height: kSpacing * 2),
                _buildNameField(),
                const SizedBox(height: kSpacing),
                _buildEmailField(),
                const SizedBox(height: kSpacing),
                _buildPasswordField(),
                const SizedBox(height: kSpacing),
                _buildConfirmPasswordField(),
                const SizedBox(height: kSpacing * 1.5),
                _buildRegisterButton(),
                const SizedBox(height: kSpacing * 2),
                _buildLoginRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      onPressed: () => Get.back(),
      icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      color: Colors.white,
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create Account ✨',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Fill in the details to get started',
          style: TextStyle(fontSize: 14, color: kFontColorPallets[2]),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return _fieldWrapper(
      label: 'Full Name',
      child: TextField(
        controller: controller.nameController,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: _inputDecoration(hint: 'John Doe', icon: Icons.person_outline_rounded),
      ),
    );
  }

  Widget _buildEmailField() {
    return _fieldWrapper(
      label: 'Email',
      child: TextField(
        controller: controller.emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: _inputDecoration(hint: 'your@email.com', icon: Icons.mail_outline_rounded),
      ),
    );
  }

  Widget _buildPasswordField() {
    return _fieldWrapper(
      label: 'Password',
      child: Obx(() => TextField(
            controller: controller.passwordController,
            obscureText: !controller.isPasswordVisible.value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _inputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                splashRadius: 18,
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: kFontColorPallets[2],
                  size: 18,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
          )),
    );
  }

  Widget _buildConfirmPasswordField() {
    return _fieldWrapper(
      label: 'Confirm Password',
      child: Obx(() => TextField(
            controller: controller.confirmPasswordController,
            obscureText: !controller.isConfirmPasswordVisible.value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _inputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                splashRadius: 18,
                icon: Icon(
                  controller.isConfirmPasswordVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: kFontColorPallets[2],
                  size: 18,
                ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
            ),
          )),
    );
  }

  Widget _buildRegisterButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.register,
            style: ElevatedButton.styleFrom(
              primary: const Color.fromRGBO(128, 109, 255, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBorderRadius / 2),
              ),
              elevation: 0,
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
          ),
        ));
  }

  Widget _buildLoginRow() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Already have an account? ',
              style: TextStyle(fontSize: 13, color: kFontColorPallets[2])),
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(128, 109, 255, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldWrapper({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: kFontColorPallets[1])),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: kFontColorPallets[2], fontSize: 14),
      prefixIcon: Icon(icon, color: kFontColorPallets[2], size: 18),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color.fromRGBO(38, 40, 55, 1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kBorderRadius / 2),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kBorderRadius / 2),
        borderSide: const BorderSide(color: Color.fromRGBO(128, 109, 255, 1), width: 1.5),
      ),
    );
  }
}
