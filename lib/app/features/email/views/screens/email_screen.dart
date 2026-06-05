import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_management/app/constans/app_constants.dart';
import '../../controllers/email_controller.dart';

class EmailScreen extends GetView<EmailController> {
  const EmailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(kSpacing * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: kSpacing * 1.5),
            Expanded(child: _buildEmailList()),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          color: Colors.white,
        ),
        const SizedBox(width: kSpacing),
        const Text(
          'Notifications',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const Spacer(),
        Obx(() {
          final unread = controller.emails.where((e) => !e.isRead).length;
          if (unread == 0) return const SizedBox();
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(128, 109, 255, 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$unread 未读',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          );
        }),
      ],
    );
  }

  Widget _buildEmailList() {
    return Obx(() => ListView.separated(
          itemCount: controller.emails.length,
          separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
              color: Color.fromRGBO(255, 255, 255, 0.05)),
          itemBuilder: (context, index) {
            final email = controller.emails[index];
            final isSelected = controller.selectedIndex.value == index;

            return GestureDetector(
              onTap: () => controller.selectEmail(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(kSpacing),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color.fromRGBO(128, 109, 255, 0.1)
                      : const Color.fromRGBO(38, 40, 55, 1),
                  borderRadius: BorderRadius.circular(kBorderRadius),
                  border: isSelected
                      ? Border.all(
                          color: const Color.fromRGBO(128, 109, 255, 0.4))
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _notifColor(email.subject)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _notifIcon(email.subject),
                            size: 18,
                            color: _notifColor(email.subject),
                          ),
                        ),
                        const SizedBox(width: kSpacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (!email.isRead)
                                    Container(
                                      width: 7,
                                      height: 7,
                                      margin:
                                          const EdgeInsets.only(right: 6),
                                      decoration: const BoxDecoration(
                                        color: Color.fromRGBO(
                                            128, 109, 255, 1),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      email.subject,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: email.isRead
                                            ? FontWeight.normal
                                            : FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(email.time,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: kFontColorPallets[2])),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(email.sender,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: kFontColorPallets[2])),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: kSpacing),
                      Divider(
                          height: 1,
                          color: Colors.white.withOpacity(0.08)),
                      const SizedBox(height: kSpacing),
                      Text(email.preview,
                          style: TextStyle(
                              fontSize: 13,
                              color: kFontColorPallets[1],
                              height: 1.5)),
                      const SizedBox(height: kSpacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!email.isRead)
                            TextButton.icon(
                              onPressed: () =>
                                  controller.markAsRead(index),
                              icon: const Icon(EvaIcons.checkmarkCircle2Outline,
                                  size: 14),
                              label: const Text('标为已读',
                                  style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(
                                  foregroundColor: kNotifColor),
                            ),
                          TextButton.icon(
                            onPressed: () =>
                                controller.deleteEmail(index),
                            icon: const Icon(EvaIcons.trash2Outline,
                                size: 14),
                            label: const Text('删除',
                                style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.redAccent),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ));
  }

  Color _notifColor(String subject) {
    if (subject.contains('浇水') || subject.contains('水')) {
      return Colors.blueAccent;
    }
    if (subject.contains('告警') || subject.contains('Bug') || subject.contains('offline')) {
      return Colors.redAccent;
    }
    if (subject.contains('施肥') || subject.contains('植物')) {
      return kNotifColor;
    }
    return const Color.fromRGBO(128, 109, 255, 1);
  }

  IconData _notifIcon(String subject) {
    if (subject.contains('浇水') || subject.contains('水')) {
      return EvaIcons.dropletOutline;
    }
    if (subject.contains('告警') || subject.contains('Bug')) {
      return EvaIcons.alertTriangleOutline;
    }
    if (subject.contains('施肥') || subject.contains('植物')) {
      return Icons.eco;
    }
    return EvaIcons.bellOutline;
  }
}
