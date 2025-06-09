import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/user_profile_service.dart';

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProfileService>.value(
      value: UserProfileService.instance,
      child: Consumer<UserProfileService>(
        builder: (_, profileService, __) {
          final profile = profileService.currentProfile;
          final darkMode = profile?.settings.darkMode ?? false;
          return Scaffold(
            appBar: AppBar(title: const Text('Options')),
            body: ListView(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: darkMode,
                  onChanged: profileService.setDarkMode,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
