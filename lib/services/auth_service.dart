import 'package:flutter/foundation.dart';
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
    String? telefone,
    DateTime? dataNascimento,
    String? genero,
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

      // Cria registro na tabela usuarios
      await supabase.from('usuarios').insert({
        'id': user.id,
        'tipo': 'paciente',
        'nome': nome,
        'telefone': telefone,
        'cpf': cpf,
        'data_nascimento': dataNascimento?.toIso8601String(),
        'genero': genero,
        'cep': cep,
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
    required String crm,
    required String universidade,
    required int anoFormacao,
    required String especialidade,
    String? genero,
    String? cpf,
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

      // Cria registro na tabela usuarios
      await supabase.from('usuarios').insert({
        'id': user.id,
        'tipo': 'medico',
        'nome': nome,
        'telefone': telefone,
        'cpf': cpf,
        'data_nascimento': dataNascimento.toIso8601String(),
        'genero': genero,
        'cep': cep,
        'crm': crm,
        'especialidade': especialidade,
        'universidade': universidade,
        'ano_formacao': anoFormacao,
      });

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // CADASTRO DE ADMIN
  Future<String?> cadastrarAdmin({
    required String nome,
    required String email,
    required String senha,
    String? telefone,
    String? cpf,
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

      // Cria registro na tabela usuarios
      await supabase.from('usuarios').insert({
        'id': user.id,
        'tipo': 'admin',
        'nome': nome,
        'telefone': telefone,
        'cpf': cpf,
      });

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // PEGAR TIPO DO USUÁRIO
  Future<String?> pegarTipoUsuario() async {
    final user = usuarioAtual;
    if (user == null) return null;

    try {
      final response = await supabase
          .from('usuarios')
          .select('tipo')
          .eq('id', user.id)
          .maybeSingle();

      return response?['tipo'] as String?;
    } catch (e) {
      return null;
    }
  }

  // PEGAR FUNÇÃO DO USUÁRIO (compatibilidade)
  Future<String?> pegarFuncaoUsuario() async {
    return await pegarTipoUsuario();
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

  // PEGAR PERFIL DO USUÁRIO COMPLETO
  Future<Map<String, dynamic>?> getPerfilUsuario() async {
    final user = usuarioAtual;
    if (user == null) return null;

    try {
      final response = await supabase
          .from('usuarios')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Erro ao buscar perfil: $e');
      return null;
    }
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

  // ATUALIZAR PERFIL
  Future<String?> atualizarPerfil({
    String? nome,
    String? telefone,
    String? cpf,
    DateTime? dataNascimento,
    String? genero,
    String? cep,
    // Campos específicos para médico
    String? crm,
    String? especialidade,
    String? universidade,
    int? anoFormacao,
  }) async {
    final user = usuarioAtual;
    if (user == null) return 'Usuário não autenticado';

    try {
      final Map<String, dynamic> updates = {};
      
      if (nome != null) updates['nome'] = nome;
      if (telefone != null) updates['telefone'] = telefone;
      if (cpf != null) updates['cpf'] = cpf;
      if (dataNascimento != null) updates['data_nascimento'] = dataNascimento.toIso8601String();
      if (genero != null) updates['genero'] = genero;
      if (cep != null) updates['cep'] = cep;
      if (crm != null) updates['crm'] = crm;
      if (especialidade != null) updates['especialidade'] = especialidade;
      if (universidade != null) updates['universidade'] = universidade;
      if (anoFormacao != null) updates['ano_formacao'] = anoFormacao;

      if (updates.isNotEmpty) {
        await supabase
            .from('usuarios')
            .update(updates)
            .eq('id', user.id);
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }
}