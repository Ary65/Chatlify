import 'package:chatlify/features/common/widgets/error.dart';
import 'package:chatlify/features/select_contacts/controller/select_contact_controller.dart';
import 'package:chatlify/utils/colors.dart';
import 'package:chatlify/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class SelectContactScreen extends ConsumerWidget {
  static const routeName = '/select_contact';
  const SelectContactScreen({Key? key}) : super(key: key);

  void selectContact(
      WidgetRef ref, Contact selectedContact, BuildContext context) {
    ref
        .read(selectContactControllerProvider)
        .selectContact(selectedContact, context);
  }

  Future<void> _handleRefresh() async {
    return await Future.delayed(
      const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact'),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: MySearchDelegate(),
                );
              },
              icon: const Icon(Icons.search)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: ref.watch(getContactsProvider).when(
          data: (contactList) => LiquidPullToRefresh(
                animSpeedFactor: 2,
                height: 200,
                color: backgroundColor,
                backgroundColor: const Color(0xff0176F5),
                onRefresh: _handleRefresh,
                child: ListView.builder(
                  itemCount: contactList.length,
                  itemBuilder: (context, index) {
                    final contact = contactList[index];
                    return InkWell(
                      onTap: () => selectContact(ref, contact, context),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(
                            contact.displayName,
                            style: const TextStyle(fontSize: 18),
                          ),
                          subtitle: Text(contact.phones[0].number),
                          leading: contact.photo == null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(globalPhotoUrl),
                                )
                              : CircleAvatar(
                                  backgroundImage: MemoryImage(contact.photo!),
                                  radius: 30,
                                ),
                          trailing: TextButton(
                            onPressed: () {},
                            child: const Text('invite'),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          error: (err, trace) => ErrorScreen(error: err.toString()),
          loading: () => const Loader()),
    );
  }
}

class MySearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return theme.copyWith(
      backgroundColor: appBarColor,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, query);
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Text('Results');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
