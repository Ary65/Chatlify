import 'dart:io';

import 'package:chatlify/features/auth/controller/auth_controller.dart';
import 'package:chatlify/features/group/screens/create_group_screen.dart';
import 'package:chatlify/features/my_account/screens/my_account_screen.dart';
import 'package:chatlify/features/select_contacts/screens/select_contact_screen.dart';
import 'package:chatlify/features/status/screens/confirm_status_screen.dart';
import 'package:chatlify/features/status/screens/status_contacts_screen.dart';
import 'package:chatlify/utils/colors.dart';
import 'package:chatlify/features/chat/widgets/contacts_list.dart';
import 'package:chatlify/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileLayoutScreen extends ConsumerStatefulWidget {
  const MobileLayoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<MobileLayoutScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        ref.read(authControllerProvider).setUserState(false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appBarColor,
          centerTitle: false,
          title: const Text(
            'Chatlify',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, color: Colors.grey),
            ),
            PopupMenuButton(
              color: backgroundColor,
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Create Group'),
                  onTap: () {
                    Future(
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateGroupScreen(),
                        ),
                      ),
                    );
                  },
                ),
                PopupMenuItem(
                    child: const Text('My Account'),
                    onTap: () {
                      Future(() => Navigator.pushNamed(
                          context, MyAccountScreen.routeName));
                    })
              ],
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: tabColor,
            indicatorWeight: 4,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(
                text: 'CHATS',
              ),
              Tab(
                text: 'STATUS',
              ),
              Tab(
                text: 'CALLS',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            ContactsList(),
            StatusContactsScreen(),
            Text('Calls'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          enableFeedback: true,
          onPressed: () async {
            if (_tabController.index == 0) {
              Navigator.pushNamed(context, SelectContactScreen.routeName);
              HapticFeedback.lightImpact();
            } else {
              File? pickedImage = await pickImageFromGallery(context);
              if (pickedImage != null) {
                // ignore: use_build_context_synchronously
                Navigator.pushNamed(
                  context,
                  ConfirmStatusScreen.routeName,
                  arguments: pickedImage,
                );
                HapticFeedback.lightImpact();
              }
            }
          },
          backgroundColor: tabColor,
          child: const Icon(
            Icons.comment,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
