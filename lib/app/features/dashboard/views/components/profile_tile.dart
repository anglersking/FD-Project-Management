part of dashboard;

class _ProfilTile extends StatelessWidget {
  const _ProfilTile(
      {required this.data, required this.onPressedNotification, Key? key})
      : super(key: key);

  final _Profile data;
  final Function() onPressedNotification;

  void _onPressedLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color.fromRGBO(38, 40, 55, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: kFontColorPallets[2], fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: kFontColorPallets[2]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(Routes.login);
            },
            style: ElevatedButton.styleFrom(
              primary: const Color.fromRGBO(128, 109, 255, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBorderRadius / 2),
              ),
              elevation: 0,
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      leading: CircleAvatar(backgroundImage: data.photo),
      title: Text(
        data.name,
        style: TextStyle(fontSize: 14, color: kFontColorPallets[0]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        data.email,
        style: TextStyle(fontSize: 12, color: kFontColorPallets[2]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onPressedNotification,
            icon: const Icon(EvaIcons.bellOutline),
            tooltip: 'Notifications',
          ),
          IconButton(
            onPressed: () => _onPressedLogout(context),
            icon: const Icon(EvaIcons.logOutOutline),
            tooltip: 'Sign Out',
            color: kFontColorPallets[2],
          ),
        ],
      ),
    );
  }
}
