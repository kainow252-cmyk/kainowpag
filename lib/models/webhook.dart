class WebhookConfiguration {
  final int? id;
  final String event;
  final String notificationUrl;
  final String authType;
  final String? authorizationHeader;
  final String? apiKey;
  final String? username;
  final String? password;
  final String? customHeaders;
  final int timeoutSeconds;
  final int retryCount;
  final bool? active;
  final int? createdAt;
  final int? updatedAt;

  WebhookConfiguration({
    this.id,
    required this.event,
    required this.notificationUrl,
    required this.authType,
    this.authorizationHeader,
    this.apiKey,
    this.username,
    this.password,
    this.customHeaders,
    this.timeoutSeconds = 30,
    this.retryCount = 3,
    this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory WebhookConfiguration.fromJson(Map<String, dynamic> json) {
    return WebhookConfiguration(
      id: json['id'],
      event: json['event'],
      notificationUrl: json['notificationUrl'],
      authType: json['authType'],
      authorizationHeader: json['authorizationHeader'],
      apiKey: json['apiKey'],
      username: json['username'],
      password: json['password'],
      customHeaders: json['customHeaders'],
      timeoutSeconds: json['timeoutSeconds'] ?? 30,
      retryCount: json['retryCount'] ?? 3,
      active: json['active'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'event': event,
      'notificationUrl': notificationUrl,
      'authType': authType,
      if (authorizationHeader != null) 'authorizationHeader': authorizationHeader,
      if (apiKey != null) 'apiKey': apiKey,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (customHeaders != null) 'customHeaders': customHeaders,
      'timeoutSeconds': timeoutSeconds,
      'retryCount': retryCount,
    };
  }

  String get eventDisplay {
    switch (event) {
      case 'NEW_ALERT':
        return 'Novo Alerta';
      case 'NEW_SUBSCRIPTION':
        return 'Nova Assinatura';
      case 'CANCELED_SUBSCRIPTION':
        return 'Assinatura Cancelada';
      case 'ACTIVE_SUBSCRIPTION':
        return 'Assinatura Ativa';
      case 'OVERDUE_SUBSCRIPTION':
        return 'Assinatura Vencida';
      case 'TICKET_TOKEN':
        return 'Token de Ticket';
      default:
        return event;
    }
  }

  String get authTypeDisplay {
    switch (authType) {
      case 'NONE':
        return 'Sem Autenticação';
      case 'BEARER':
        return 'Bearer Token';
      case 'BASIC':
        return 'Básica (Basic Auth)';
      case 'API_KEY':
        return 'API Key';
      case 'CUSTOM':
        return 'Personalizada';
      default:
        return authType;
    }
  }

  String get statusDisplay => active == true ? 'Ativo' : 'Inativo';
}

// Tipos de eventos disponíveis
class WebhookEvent {
  static const String newAlert = 'NEW_ALERT';
  static const String newSubscription = 'NEW_SUBSCRIPTION';
  static const String canceledSubscription = 'CANCELED_SUBSCRIPTION';
  static const String activeSubscription = 'ACTIVE_SUBSCRIPTION';
  static const String overdueSubscription = 'OVERDUE_SUBSCRIPTION';
  static const String ticketToken = 'TICKET_TOKEN';

  static const List<String> all = [
    newAlert,
    newSubscription,
    canceledSubscription,
    activeSubscription,
    overdueSubscription,
    ticketToken,
  ];

  static String getDisplay(String event) {
    switch (event) {
      case newAlert:
        return 'Novo Alerta';
      case newSubscription:
        return 'Nova Assinatura';
      case canceledSubscription:
        return 'Assinatura Cancelada';
      case activeSubscription:
        return 'Assinatura Ativa';
      case overdueSubscription:
        return 'Assinatura Vencida';
      case ticketToken:
        return 'Token de Ticket';
      default:
        return event;
    }
  }
}

// Tipos de autenticação disponíveis
class WebhookAuthType {
  static const String none = 'NONE';
  static const String bearer = 'BEARER';
  static const String basic = 'BASIC';
  static const String apiKey = 'API_KEY';
  static const String custom = 'CUSTOM';

  static const List<String> all = [
    none,
    bearer,
    basic,
    apiKey,
    custom,
  ];

  static String getDisplay(String authType) {
    switch (authType) {
      case none:
        return 'Sem Autenticação';
      case bearer:
        return 'Bearer Token';
      case basic:
        return 'Básica (Basic Auth)';
      case apiKey:
        return 'API Key';
      case custom:
        return 'Personalizada';
      default:
        return authType;
    }
  }
}
