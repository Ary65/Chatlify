// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatlify/features/select_contacts/repository/select_contact_repository.dart';

//*
final getContactsProvider = FutureProvider((ref) {
  final selectContactRepository = ref.watch(
    selectContactsRepositoryProvider,
  );
  return selectContactRepository.getContacts();
});

//*
final selectContactControllerProvider = Provider((ref) {
  final selectContactRepository = ref.watch(
    selectContactsRepositoryProvider,
  );
  return SelectContactController(
    ref: ref,
    selectContactRepository: selectContactRepository,
  );
});

//*
class SelectContactController {
  final ProviderRef ref;
  final SelectContactRepository selectContactRepository;
  SelectContactController({
    required this.ref,
    required this.selectContactRepository,
  });

  //*
  void selectContact(Contact selectedContact, BuildContext context) {
    selectContactRepository.selectContact(
      selectedContact,
      context,
    );
  }
}
