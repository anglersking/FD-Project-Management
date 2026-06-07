import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_management/app/constans/app_constants.dart';
import '../../controllers/forgot_password_controller.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kSpacing * 2),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Obx(() => controller.isSuccess.value
                ? _buildSuccessView()
                : _buildFormView()),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackButton(),
        const SizedBox(height: kSpacing),
        _buildTitle(),
        const SizedBox(height: kSpacing * 2),
        _buildPhoneField(),
        const SizedBox(height: kSpacing),
        _buildNewPasswordField(),
        const SizedBox(height: kSpacing),
        _buildConfirmPasswordField(),
        const SizedBox(height: kSpacing * 1.5),
        _buildSubmitButton(),
        const SizedBox(height: kSpacing * 2),
        _buildLoginRow(),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: kSpacing * 2),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: kNotifColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle_outline_rounded,
              color: kNotifColor, size: 36),
        ),
        const SizedBox(height: kSpacing * 1.5),
        const Text(
          'Password Reset!',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
        const SizedBox(height: kSpacing / 2),
        Text(
          'Your password has been updated.\nYou can now sign in with your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14, color: kFontColorPallets[2], height: 1.6),
        ),
        const SizedBox(height: kSpacing * 2),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              primary: const Color.fromRGBO(128, 109, 255, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBorderRadius / 2),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Back to Sign In',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ),
        ),
      ],
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
          'Reset Password 🔑',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter your phone number and set a new password',
          style: TextStyle(fontSize: 14, color: kFontColorPallets[2]),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return _fieldWrapper(
      label: 'Phone Number',
      child: TextField(
        controller: controller.phoneController,
        keyboardType: TextInputType.phone,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: _inputDecoration(
            hint: '+86 138 0000 0000', icon: Icons.phone_outlined),
      ),
    );
  }

  Widget _buildNewPasswordField() {
    return _fieldWrapper(
      label: 'New Password',
      child: Obx(() => TextField(
            controller: controller.newPasswordController,
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
      label: 'Confirm New Password',
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

  Widget _buildSubmitButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed:
                controller.isLoading.value ? null : controller.resetPassword,
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
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Reset Password',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
          ),
        ));
  }

  Widget _buildLoginRow() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Remember your password? ',
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
                  color: Color.fromRGBO(128, 109, 255, 1)),
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
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kFontColorPallets[1])),
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kBorderRadius / 2),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kBorderRadius / 2),
        borderSide: const BorderSide(
            color: Color.fromRGBO(128, 109, 255, 1), width: 1.5),
      ),
    );
  }
}
