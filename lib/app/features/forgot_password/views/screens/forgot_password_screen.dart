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
            child: Obx(() => controller.isEmailSent.value
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
        _buildEmailField(),
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
          child: Icon(Icons.mark_email_read_outlined, color: kNotifColor, size: 36),
        ),
        const SizedBox(height: kSpacing * 1.5),
        const Text(
          'Check your email',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: kSpacing / 2),
        Text(
          'We sent a password reset link to\n${controller.emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: kFontColorPallets[2], height: 1.6),
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
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: kSpacing),
        TextButton(
          onPressed: controller.sendResetEmail,
          child: Text(
            "Didn't receive the email? Resend",
            style: TextStyle(
              fontSize: 13,
              color: const Color.fromRGBO(128, 109, 255, 1),
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
          'Forgot Password? 🔑',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          "Enter your email and we'll send you a reset link",
          style: TextStyle(fontSize: 14, color: kFontColorPallets[2]),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: kFontColorPallets[1])),
        const SizedBox(height: 8),
        TextField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'your@email.com',
            hintStyle: TextStyle(color: kFontColorPallets[2], fontSize: 14),
            prefixIcon: Icon(Icons.mail_outline_rounded, color: kFontColorPallets[2], size: 18),
            filled: true,
            fillColor: const Color.fromRGBO(38, 40, 55, 1),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kBorderRadius / 2),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kBorderRadius / 2),
              borderSide:
                  const BorderSide(color: Color.fromRGBO(128, 109, 255, 1), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.sendResetEmail,
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
                    'Send Reset Link',
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
}
