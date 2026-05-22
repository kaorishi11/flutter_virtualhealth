import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // CADASTRO completo
  Future<String?> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
    required String funcao, // 'paciente' ou 'medico'
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: senha,
        data: {
          'nome_completo': nome,
          'telefone': telefone,
          'funcao': funcao,
        },
      );

      final user = response.user;
      if (user == null) {
        return 'Erro ao criar usuário';
      }

      // Cria o perfil na tabela perfis
      await supabase.from('perfis').insert({
        'auth_id': user.id,
        'nome_completo': nome,
        'email': email,
        'telefone': telefone,
        'funcao': funcao,
      });

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // LOGIN
  Future<String?> login({
    required String email,
    required String senha,
  }) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: senha,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // Usuário logado
  User? get usuarioAtual {
    return supabase.auth.currentUser;
  }

  // Pega o perfil do usuário logado
  Future<Map<String, dynamic>?> getPerfilUsuario() async {
    final user = usuarioAtual;
    if (user == null) return null;

    final response = await supabase
        .from('perfis')
        .select()
        .eq('auth_id', user.id)
        .maybeSingle();

    return response;
  }
}