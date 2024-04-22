import 'package:coffee_companion/my_brews.dart';
import 'package:flutter/material.dart';
import 'my_roasts.dart';
import 'main.dart';
import 'grinder.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary
            ),
            child: const Text('CoffeeCompanion',
            style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            title: const Text('Brew Timer'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Timer')),
              );
            },
          ),
          ListTile(
            title: const Text('My Roasts'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyRoastsPage(title: 'My Roasts')),
              );
            }
          ),
          ListTile(
            title: const Text('My Brews'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyBrewsPage(title: 'My Brews'))
              );
            }
          ),
          ListTile(
            title: const Text('My Grinder'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyGrinderPage(title: 'My Grinder'))
              );
            }
          ),
        ],
      ),
    );
  }
}