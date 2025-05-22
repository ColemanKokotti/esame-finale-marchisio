import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String selectedRole = 'Ospite';
  bool isOnline = true;

  final String userName = 'Mario Rossi';
  final List<String> roles = ['IT', 'Volontario', 'Ospite', 'Staff'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF009E3D),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 24), // Placeholder per allineare il titolo centralmente
            Image.asset(
              'assets/icons/logo.png',
              width: 40,
              height: 40,
              color: Colors.white,
            ),
            GestureDetector(
              onTap: () {
                // Azione modifica profilo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Modifica profilo cliccato')),
                );
              },
              child: Image.asset(
                'assets/icons/modify_profile.png',
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Foto profilo (placeholder)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
                image: const DecorationImage(
                  image: AssetImage('assets/icons/logo.png'), // Sostituibile con immagine reale
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nome
            Text(
              userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Ruolo dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedRole,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: roles.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (String? newRole) {
                    if (newRole != null) {
                      setState(() {
                        selectedRole = newRole;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stato online/offline
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOnline ? const Color(0xFF009E3D) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isOnline = !isOnline;
                  });
                },
                child: Text(
                  isOnline ? 'Sei Online' : 'Sei Offline',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
