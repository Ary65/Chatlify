import 'dart:io';

import 'package:chatlify/features/group/repositopry/group_repositry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupControllerProvider = Provider(
  (ref) {
    final groupRepository = ref.read(groupRepositoryProvider);
    return GroupController(
      groupRepository: groupRepository,
      ref: ref,
    );
  },
);

class GroupController {
  final GroupRepository groupRepository;
  final ProviderRef ref;

  GroupController({
    required this.groupRepository,
    required this.ref,
  });

  void createGroup(BuildContext context, String name, File profilePic,
      List<Contact> selectedContact) {
    groupRepository.createGroup(
      context,
      name,
      profilePic,
      selectedContact,
    );
  }
}
