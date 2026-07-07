class ErrorTranslator {
  ErrorTranslator._();

  static String translate(String raw, int statusCode) {
    final lower = raw.toLowerCase().trim();

    if (lower == 'invalid credentials') {
      return 'Email ou senha incorretos.';
    }
    if (lower == 'not authenticated') {
      return 'Sessao expirada. Faca login novamente.';
    }
    if (lower.contains('not a valid email') || lower.contains('email address')) {
      return 'Informe um email valido.';
    }
    if (lower.contains('recovery code') && lower.contains('invalid')) {
      return 'Recovery code invalido ou ja utilizado.';
    }
    if (lower.contains('recovery code') && lower.contains('not found')) {
      return 'Recovery code nao encontrado.';
    }
    if (lower.contains('already enrolled') || lower.contains('already active')) {
      return '2FA ja esta ativo nesta conta.';
    }
    if (lower.contains('not enrolled') || lower.contains('not active')) {
      return '2FA nao esta ativo nesta conta.';
    }
    if (lower.contains('field required')) {
      return 'Campo obrigatorio nao informado.';
    }
    if (lower.contains('too short') || lower.contains('min_length')) {
      return 'Valor muito curto.';
    }
    if (lower.contains('too long') || lower.contains('max_length')) {
      return 'Valor muito longo.';
    }

    return switch (statusCode) {
      400 => 'Requisicao invalida.',
      401 => 'Nao autorizado. Faca login novamente.',
      403 => 'Acesso negado.',
      404 => 'Recurso nao encontrado.',
      422 => 'Dados invalidos. Verifique os campos informados.',
      429 => 'Muitas tentativas. Aguarde um momento.',
      500 => 'Erro interno no servidor. Tente novamente.',
      503 => 'Servico indisponivel. Tente novamente.',
      _ => 'Erro $statusCode ao comunicar com a API.',
    };
  }
}
