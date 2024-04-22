import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      title: const Icon(Icons.coffee),
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primaryContainer),
      centerTitle: true
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}