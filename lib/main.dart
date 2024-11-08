import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts List with Search',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ContactsPage(),
    );
  }
}

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  bool permissionGranted = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchContacts();
    searchController.addListener(() {
      filterContacts();
    });
  }

  Future<void> fetchContacts() async {
    // Request permission to access contacts
    if (await FlutterContacts.requestPermission()) {
      setState(() {
        permissionGranted = true;
      });
      // Retrieve contacts
      List<Contact> contactsList =
          await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        contacts = contactsList;
        filteredContacts = contactsList;
      });
    } else {
      setState(() {
        permissionGranted = false;
      });
    }
  }

  void filterContacts() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredContacts = contacts.where((contact) {
        return contact.displayName.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: permissionGranted
          ? Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search Contacts',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      Contact contact = filteredContacts[index];
                      return ListTile(
                        title: Text(contact.displayName),
                        subtitle: Text(contact.phones.isNotEmpty
                            ? contact.phones.first.number
                            : 'No phone number'),
                        leading: CircleAvatar(
                          child: Text(contact.displayName[0]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : Center(
              child: const Text('Permission to access contacts was denied'),
            ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
