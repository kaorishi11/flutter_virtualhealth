import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {

  final supabase = Supabase.instance.client;

  // CADASTRO
  Future<String?> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
    required String funcao,
  }) async {

    try {

      final response = await supabase.auth.signUp(
        email: email,
        password: senha,
      );

      final user = response.user;

      if (user == null) {
        return 'Erro ao criar usuário';
      }

      // cria perfil
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

  // usuário logado
  User? get usuarioAtual {
    return supabase.auth.currentUser;
  }
}