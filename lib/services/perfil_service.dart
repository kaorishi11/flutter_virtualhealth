import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class PerfilService {
  final supabase = Supabase.instance.client;

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não logado');

      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await supabase.storage.from('avatars').upload(fileName, imageFile,
          fileOptions: const FileOptions(cacheControl: '3600'));

      final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      await supabase
          .from('usuarios')
          .update({'foto': publicUrl}).eq('id', userId);

      return publicUrl;
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      return true;
    } catch (e) {
      print('Erro ao atualizar senha: $e');
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        // Deletar dados relacionados do usuário
        await supabase.from('mensagens').delete().eq('usuario_id', userId);
        await supabase.from('usuarios').delete().eq('id', userId);
      }
      await supabase.auth.signOut();
      return true;
    } catch (e) {
      print('Erro ao deletar conta: $e');
      return false;
    }
  }

  String formatarCPF(String valor) {
    String cpf = valor.replaceAll(RegExp(r'\D'), '');
    if (cpf.length <= 11) {
      if (cpf.length >= 3 && cpf.length <= 5) {
        return '${cpf.substring(0, 3)}.${cpf.substring(3)}';
      } else if (cpf.length >= 6 && cpf.length <= 8) {
        return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6)}';
      } else if (cpf.length >= 9) {
        return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
      }
    }
    return cpf;
  }

  String formatarTelefone(String valor) {
    String telefone = valor.replaceAll(RegExp(r'\D'), '');
    if (telefone.length == 10) {
      return '(${telefone.substring(0, 2)}) ${telefone.substring(2, 6)}-${telefone.substring(6)}';
    } else if (telefone.length == 11) {
      return '(${telefone.substring(0, 2)}) ${telefone.substring(2, 7)}-${telefone.substring(7)}';
    }
    return telefone;
  }

  String desformatarCPF(String cpf) {
    return cpf.replaceAll(RegExp(r'\D'), '');
  }

  String desformatarTelefone(String telefone) {
    return telefone.replaceAll(RegExp(r'\D'), '');
  }

  String getIniciais(String nome) {
    if (nome.isEmpty) return '?';
    final nomes = nome.trim().split(' ');
    if (nomes.length == 1) return nomes[0][0].toUpperCase();
    return (nomes[0][0] + nomes[nomes.length - 1][0]).toUpperCase();
  }

  int getCorFundo(String nome) {
    if (nome.isEmpty) return 0xFF6366F1;

    final cores = [
      0xFF6366F1,
      0xFF8B5CF6,
      0xFFEC4899,
      0xFFF43F5E,
      0xFFEF4444,
      0xFFF97316,
      0xFFF59E0B,
      0xFF84CC16,
      0xFF10B981,
      0xFF14B8A6,
      0xFF06B6D4,
      0xFF0EA5E9,
      0xFF3B82F6,
      0xFF6366F1,
      0xFF8B5CF6
    ];

    int hash = 0;
    for (int i = 0; i < nome.length; i++) {
      hash = nome.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final index = hash.abs() % cores.length;
    return cores[index];
  }
}
