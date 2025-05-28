import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepository _userRepository = UserRepository();

  String selectedRole = 'IT';
  bool isOnline = true;
  String userName = 'Caricamento...';

  final List<String> roles = ['IT', 'Volontario', 'Ospite', 'Staff'];
  final TextEditingController _nameController = TextEditingController();

  UserModel? currentUserProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print('🔵 ProfileScreen: initState chiamato');
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    print('🔵 ProfileScreen: Inizio caricamento profilo');

    try {
      final user = FirebaseAuth.instance.currentUser;
      print('🔵 ProfileScreen: Current user = ${user?.email}');

      if (user != null) {
        print('🔵 ProfileScreen: Chiamata getUserById...');
        final profile = await _userRepository.getUserById(user.uid);
        print('🔵 ProfileScreen: Profile ricevuto = ${profile != null ? "OK" : "NULL"}');

        if (mounted) {
          if (profile != null) {
            print('🔵 ProfileScreen: Aggiornamento stato con profilo esistente');
            setState(() {
              currentUserProfile = profile;
              userName = profile.name;
              selectedRole = profile.role;
              isOnline = profile.isOnline;
              _nameController.text = profile.name;
              isLoading = false;
            });
          } else {
            print('🟡 ProfileScreen: Profilo non trovato - creazione nuovo profilo');
            // Crea un nuovo profilo con dati di default
            await _createDefaultProfile(user);
          }
        }
      } else {
        print('🔴 ProfileScreen: Utente non autenticato');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        _showErrorSnackBar('Utente non autenticato');
      }
    } catch (e) {
      print('🔴 ProfileScreen: Errore durante caricamento = $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      _showErrorSnackBar('Errore durante il caricamento del profilo: $e');
    }
  }

  Future<void> _createDefaultProfile(User user) async {
    try {
      print('🟡 ProfileScreen: Creazione profilo di default per ${user.email}');

      final defaultProfile = UserModel(
        uid: user.uid,
        email: user.email ?? 'Unknown',
        name: user.displayName ?? 'Nuovo Utente',
        role: 'Ospite', // Ruolo di default
        isOnline: true,
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
      );

      await _userRepository.createOrUpdateUser(defaultProfile);

      if (mounted) {
        setState(() {
          currentUserProfile = defaultProfile;
          userName = defaultProfile.name;
          selectedRole = defaultProfile.role;
          isOnline = defaultProfile.isOnline;
          _nameController.text = defaultProfile.name;
          isLoading = false;
        });
      }

      print('🟢 ProfileScreen: Profilo di default creato con successo');
    } catch (e) {
      print('🔴 ProfileScreen: Errore durante creazione profilo di default = $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      _showErrorSnackBar('Errore durante la creazione del profilo: $e');
    }
  }

  Future<void> _updateUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && currentUserProfile != null) {
        final updatedProfile = currentUserProfile!.copyWith(
          name: _nameController.text.trim(),
          role: selectedRole,
          isOnline: isOnline,
        );

        await _userRepository.createOrUpdateUser(updatedProfile);

        setState(() {
          currentUserProfile = updatedProfile;
          userName = updatedProfile.name;
        });

        _showSuccessSnackBar('Profilo aggiornato con successo!');
      }
    } catch (e) {
      _showErrorSnackBar('Errore durante l\'aggiornamento: $e');
    }
  }

  Future<void> _toggleOnlineStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final newStatus = !isOnline;
        await _userRepository.updateUserOnlineStatus(user.uid, newStatus);

        setState(() {
          isOnline = newStatus;
        });

        _showSuccessSnackBar(
          newStatus ? 'Ora sei online!' : 'Ora sei offline!',
        );
      }
    } catch (e) {
      _showErrorSnackBar('Errore durante l\'aggiornamento dello stato: $e');
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifica Profilo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Ruolo',
                    border: OutlineInputBorder(),
                  ),
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateUserProfile();
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF009E3D),
          ),
        ),
      );
    }

    // Aggiungi questa condizione per gestire il caso in cui il profilo non esiste
    if (currentUserProfile == null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF009E3D),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/logo.png',
                width: 40,
                height: 40,
                color: Colors.white,
              ),
            ],
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Profilo non trovato',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Contatta l\'amministratore per risolvere il problema.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF009E3D),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 24),
            Image.asset(
              'assets/icons/logo.png',
              width: 40,
              height: 40,
              color: Colors.white,
            ),
            GestureDetector(
              onTap: _showEditDialog,
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
                  image: AssetImage('assets/icons/logo.png'),
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

            // Email (readonly)
            Text(
              currentUserProfile!.email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // Ruolo (readonly display)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade50,
              ),
              child: Row(
                children: [
                  Icon(Icons.badge, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Ruolo: $selectedRole',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Data registrazione
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade50,
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Registrato il: ${_formatDate(currentUserProfile!.createdAt)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
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
                onPressed: _toggleOnlineStatus,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isOnline ? Icons.circle : Icons.circle_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOnline ? 'Sei Online' : 'Sei Offline',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}