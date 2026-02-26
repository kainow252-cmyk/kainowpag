import 'package:flutter/material.dart';

/// Status e traduções centralizadas conforme documentação DeltaPag
/// Fonte: https://deltapag-tech.readme.io/reference/status-e-tipos

class PaymentStatus {
  // ========== STATUS DE COBRANÇA ==========
  
  /// Status de Cobrança (Charge Status)
  static const String CHARGE_PAY = 'PAY';                     // Pago
  static const String CHARGE_AUTHORIZED = 'AUTHORIZED';       // Autorizado
  static const String CHARGE_PENDING = 'PENDING';             // Pendente
  static const String CHARGE_SCHEDULE = 'SCHEDULE';           // Agendado
  static const String CHARGE_REFUND = 'REFUND';               // Estornado
  static const String CHARGE_COUNTERCHARGE = 'COUNTERCHARGE'; // Contestação
  static const String CHARGE_CHARGEBACK = 'CHARGEBACK';       // Chargeback
  static const String CHARGE_FAIL = 'FAIL';                   // Falhou
  static const String CHARGE_CANCELED = 'CANCELED';           // Cancelado
  static const String CHARGE_IN_PROGRESS = 'IN_PROGRESS';     // Em Progresso
  
  // ========== STATUS DE PEDIDO/ASSINATURA ==========
  
  /// Status de Pedido ou Assinatura (Order/Subscription Status)
  static const String ORDER_ACTIVE = 'ACTIVE';                // Ativo
  static const String ORDER_OVERDUE = 'OVERDUE';              // Inadimplente
  static const String ORDER_CANCELED = 'CANCELED';            // Cancelado
  static const String ORDER_PENDING = 'PENDING';              // Pendente
  static const String ORDER_COUNTERCHARGE = 'COUNTERCHARGE';  // Contestação
  static const String ORDER_CHARGEBACK = 'CHARGEBACK';        // Chargeback
  
  // ========== STATUS DE TRANSAÇÃO ==========
  
  /// Status de Transação (Transaction Status)
  static const String TRANS_IN_PROGRESS = 'IN_PROGRESS';      // Em Progresso
  static const String TRANS_APPROVED = 'APPROVED';            // Aprovado
  static const String TRANS_REFUND = 'REFUND';                // Estornado
  static const String TRANS_AUTHORIZED = 'AUTHORIZED';        // Autorizado
  static const String TRANS_NOT_AUTHORIZED = 'NOT_AUTHORIZED';// Não Autorizado
  static const String TRANS_NOT_APPROVED = 'NOT_APPROVED';    // Não Aprovado
  static const String TRANS_CHARGEBACK = 'CHARGEBACK';        // Chargeback
  static const String TRANS_COUNTERCHARGE = 'COUNTERCHARGE';  // Contestação
  static const String TRANS_FAIL = 'FAIL';                    // Falhou
  static const String TRANS_AWAITING_PAYMENT = 'AWAITING_PAYMENT'; // Aguardando Pagamento
  
  // ========== TRADUÇÕES E DESCRIÇÕES ==========
  
  /// Retorna o nome em português do status de cobrança
  static String getChargeName(String? status) {
    if (status == null) return 'Desconhecido';
    
    switch (status.toUpperCase()) {
      case CHARGE_PAY:
        return 'Pago';
      case CHARGE_AUTHORIZED:
        return 'Autorizado';
      case CHARGE_PENDING:
        return 'Pendente';
      case CHARGE_SCHEDULE:
        return 'Agendado';
      case CHARGE_REFUND:
        return 'Estornado';
      case CHARGE_COUNTERCHARGE:
        return 'Contestação';
      case CHARGE_CHARGEBACK:
        return 'Chargeback';
      case CHARGE_FAIL:
        return 'Falhou';
      case CHARGE_CANCELED:
        return 'Cancelado';
      case CHARGE_IN_PROGRESS:
        return 'Em Progresso';
      default:
        return status;
    }
  }
  
  /// Retorna a descrição detalhada do status de cobrança
  static String getChargeDescription(String? status) {
    if (status == null) return 'Status desconhecido';
    
    switch (status.toUpperCase()) {
      case CHARGE_PAY:
        return 'A cobrança foi autorizada e capturada com sucesso.';
      case CHARGE_AUTHORIZED:
        return 'A cobrança foi autorizada e precisa ser capturada.';
      case CHARGE_PENDING:
        return 'A cobrança encontra-se pendente de pagamento. Pode ter sido uma negação por parte da adquirente ou do banco emissor.';
      case CHARGE_SCHEDULE:
        return 'A cobrança foi agendada, respeitando a data de vencimento informada.';
      case CHARGE_REFUND:
        return 'A cobrança foi estornada com sucesso.';
      case CHARGE_COUNTERCHARGE:
        return 'A cobrança recebeu uma notificação de não reconhecimento da compra por parte do cliente. Foi iniciado um processo de disputa junto a adquirente.';
      case CHARGE_CHARGEBACK:
        return 'A cobrança recebeu uma notificação de chargeback. O processo de disputa foi perdido e o valor da venda foi estornado para o cliente.';
      case CHARGE_FAIL:
        return 'Ocorreu uma falha ao realizar a cobrança.';
      case CHARGE_CANCELED:
        return 'A cobrança foi cancelada e não poderão ser realizadas novas tentativas de pagamento.';
      case CHARGE_IN_PROGRESS:
        return 'A cobrança está em processamento.';
      default:
        return 'Status: $status';
    }
  }
  
  /// Retorna o nome em português do status de pedido/assinatura
  static String getOrderName(String? status) {
    if (status == null) return 'Desconhecido';
    
    switch (status.toUpperCase()) {
      case ORDER_ACTIVE:
        return 'Ativo';
      case ORDER_OVERDUE:
        return 'Inadimplente';
      case ORDER_CANCELED:
        return 'Cancelado';
      case ORDER_PENDING:
        return 'Pendente';
      case ORDER_COUNTERCHARGE:
        return 'Contestação';
      case ORDER_CHARGEBACK:
        return 'Chargeback';
      default:
        return status;
    }
  }
  
  /// Retorna a descrição detalhada do status de pedido/assinatura
  static String getOrderDescription(String? status) {
    if (status == null) return 'Status desconhecido';
    
    switch (status.toUpperCase()) {
      case ORDER_ACTIVE:
        return 'Pedido ou assinatura está ativo.';
      case ORDER_OVERDUE:
        return 'Venda com uma ou mais cobranças pendentes de pagamento.';
      case ORDER_CANCELED:
        return 'A venda foi cancelada via portal ou API. Após esse status não poderá realizar novas tentativas de cobrança.';
      case ORDER_PENDING:
        return 'Venda não conseguiu ser efetuada com sucesso.';
      case ORDER_COUNTERCHARGE:
        return 'A venda possui cobranças que receberam notificações de não reconhecimento da compra (apenas cartão de crédito).';
      case ORDER_CHARGEBACK:
        return 'A venda possui cobranças que receberam notificações de chargeback. Processo de disputa expirado ou perdido (apenas cartão de crédito).';
      default:
        return 'Status: $status';
    }
  }
  
  /// Retorna o nome em português do status de transação
  static String getTransactionName(String? status) {
    if (status == null) return 'Desconhecido';
    
    switch (status.toUpperCase()) {
      case TRANS_IN_PROGRESS:
        return 'Em Progresso';
      case TRANS_APPROVED:
        return 'Aprovado';
      case TRANS_REFUND:
        return 'Estornado';
      case TRANS_AUTHORIZED:
        return 'Autorizado';
      case TRANS_NOT_AUTHORIZED:
        return 'Não Autorizado';
      case TRANS_NOT_APPROVED:
        return 'Não Aprovado';
      case TRANS_CHARGEBACK:
        return 'Chargeback';
      case TRANS_COUNTERCHARGE:
        return 'Contestação';
      case TRANS_FAIL:
        return 'Falhou';
      case TRANS_AWAITING_PAYMENT:
        return 'Aguardando Pagamento';
      default:
        return status;
    }
  }
  
  // ========== CORES DE STATUS ==========
  
  /// Retorna a cor apropriada para o status de cobrança
  static Color getChargeColor(String? status) {
    if (status == null) return Colors.grey;
    
    switch (status.toUpperCase()) {
      case CHARGE_PAY:
      case CHARGE_AUTHORIZED:
        return Colors.green;
      
      case CHARGE_PENDING:
      case CHARGE_SCHEDULE:
      case CHARGE_IN_PROGRESS:
        return Colors.orange;
      
      case CHARGE_FAIL:
      case CHARGE_CANCELED:
      case CHARGE_CHARGEBACK:
        return Colors.red;
      
      case CHARGE_REFUND:
        return Colors.blue;
      
      case CHARGE_COUNTERCHARGE:
        return Colors.deepOrange;
      
      default:
        return Colors.grey;
    }
  }
  
  /// Retorna a cor apropriada para o status de pedido/assinatura
  static Color getOrderColor(String? status) {
    if (status == null) return Colors.grey;
    
    switch (status.toUpperCase()) {
      case ORDER_ACTIVE:
        return Colors.green;
      
      case ORDER_OVERDUE:
      case ORDER_PENDING:
        return Colors.orange;
      
      case ORDER_CANCELED:
      case ORDER_CHARGEBACK:
        return Colors.red;
      
      case ORDER_COUNTERCHARGE:
        return Colors.deepOrange;
      
      default:
        return Colors.grey;
    }
  }
  
  /// Retorna a cor apropriada para o status de transação
  static Color getTransactionColor(String? status) {
    if (status == null) return Colors.grey;
    
    switch (status.toUpperCase()) {
      case TRANS_APPROVED:
      case TRANS_AUTHORIZED:
        return Colors.green;
      
      case TRANS_IN_PROGRESS:
      case TRANS_AWAITING_PAYMENT:
        return Colors.orange;
      
      case TRANS_NOT_AUTHORIZED:
      case TRANS_NOT_APPROVED:
      case TRANS_FAIL:
      case TRANS_CHARGEBACK:
        return Colors.red;
      
      case TRANS_REFUND:
        return Colors.blue;
      
      case TRANS_COUNTERCHARGE:
        return Colors.deepOrange;
      
      default:
        return Colors.grey;
    }
  }
  
  // ========== ÍCONES DE STATUS ==========
  
  /// Retorna o ícone apropriado para o status de cobrança
  static IconData getChargeIcon(String? status) {
    if (status == null) return Icons.help_outline;
    
    switch (status.toUpperCase()) {
      case CHARGE_PAY:
        return Icons.check_circle;
      
      case CHARGE_AUTHORIZED:
        return Icons.verified;
      
      case CHARGE_PENDING:
      case CHARGE_SCHEDULE:
        return Icons.schedule;
      
      case CHARGE_IN_PROGRESS:
        return Icons.sync;
      
      case CHARGE_FAIL:
      case CHARGE_CANCELED:
        return Icons.cancel;
      
      case CHARGE_REFUND:
        return Icons.undo;
      
      case CHARGE_COUNTERCHARGE:
        return Icons.warning;
      
      case CHARGE_CHARGEBACK:
        return Icons.error;
      
      default:
        return Icons.help_outline;
    }
  }
  
  /// Retorna o ícone apropriado para o status de pedido/assinatura
  static IconData getOrderIcon(String? status) {
    if (status == null) return Icons.help_outline;
    
    switch (status.toUpperCase()) {
      case ORDER_ACTIVE:
        return Icons.check_circle;
      
      case ORDER_OVERDUE:
        return Icons.warning;
      
      case ORDER_PENDING:
        return Icons.schedule;
      
      case ORDER_CANCELED:
        return Icons.cancel;
      
      case ORDER_COUNTERCHARGE:
        return Icons.report_problem;
      
      case ORDER_CHARGEBACK:
        return Icons.error;
      
      default:
        return Icons.help_outline;
    }
  }
  
  // ========== HELPERS ==========
  
  /// Verifica se o status indica sucesso
  static bool isSuccess(String? status) {
    if (status == null) return false;
    final upper = status.toUpperCase();
    return upper == CHARGE_PAY || 
           upper == CHARGE_AUTHORIZED || 
           upper == TRANS_APPROVED || 
           upper == TRANS_AUTHORIZED ||
           upper == ORDER_ACTIVE;
  }
  
  /// Verifica se o status indica falha
  static bool isFailure(String? status) {
    if (status == null) return false;
    final upper = status.toUpperCase();
    return upper == CHARGE_FAIL || 
           upper == CHARGE_CANCELED || 
           upper == TRANS_NOT_AUTHORIZED || 
           upper == TRANS_NOT_APPROVED || 
           upper == TRANS_FAIL ||
           upper == ORDER_CANCELED;
  }
  
  /// Verifica se o status indica processamento
  static bool isPending(String? status) {
    if (status == null) return false;
    final upper = status.toUpperCase();
    return upper == CHARGE_PENDING || 
           upper == CHARGE_SCHEDULE || 
           upper == CHARGE_IN_PROGRESS || 
           upper == TRANS_IN_PROGRESS || 
           upper == TRANS_AWAITING_PAYMENT ||
           upper == ORDER_PENDING;
  }
  
  /// Verifica se o status indica disputa/chargeback
  static bool isDispute(String? status) {
    if (status == null) return false;
    final upper = status.toUpperCase();
    return upper == CHARGE_COUNTERCHARGE || 
           upper == CHARGE_CHARGEBACK || 
           upper == TRANS_COUNTERCHARGE || 
           upper == TRANS_CHARGEBACK ||
           upper == ORDER_COUNTERCHARGE ||
           upper == ORDER_CHARGEBACK;
  }
}
