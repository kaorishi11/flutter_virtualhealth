import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // CADASTRO DE PACIENTE
  Future<String?> cadastrarPaciente({
    required String nome,
    required String email,
    required String senha,
    required String cep,
    required String cpf,
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

      // Cria perfil do paciente
      await supabase.from('perfis').insert({
        'auth_id': user.id,
        'nome_completo': nome,
        'email': email,
        'funcao': 'paciente',
        'cpf': cpf,
        'cep': cep,
        'ativo': true,
      });

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // CADASTRO DE MÉDICO
  Future<String?> cadastrarMedico({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
    required String cep,
    required DateTime dataNascimento,
    required String registroProfissional,
    required String universidade,
    required int anoFormacao,
    required String especialidade,
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

      // Cria perfil do médico
      final perfilResponse = await supabase.from('perfis').insert({
        'auth_id': user.id,
        'nome_completo': nome,
        'email': email,
        'funcao': 'medico',
        'telefone': telefone,
        'cep': cep,
        'data_nascimento': dataNascimento.toIso8601String(),
        'ativo': true,
      }).select();

      final perfilId = perfilResponse[0]['id'];

      // Cria registro do profissional
      await supabase.from('profissionais').insert({
        'perfil_id': perfilId,
        'especialidade': especialidade,
        'crm': registroProfissional,
        'universidade': universidade,
        'ano_formacao': anoFormacao,
        'status': 'pendente',
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

  // USUÁRIO ATUAL
  User? get usuarioAtual {
    return supabase.auth.currentUser;
  }

  // PEGAR PERFIL DO USUÁRIO
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

  // VERIFICAR SE ESTÁ LOGADO
  bool get isLoggedIn {
    return supabase.auth.currentUser != null;
  }

  // RECUPERAR SENHA
  Future<String?> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}