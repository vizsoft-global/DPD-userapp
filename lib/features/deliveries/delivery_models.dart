import '../../l10n/app_localizations.dart';

/// Driver-submitted delivery row from `public.deliveries`.
class DriverDelivery {
  const DriverDelivery({
    required this.id,
    required this.externalOrderId,
    required this.status,
    required this.deliveredAt,
    this.orderProofUrl,
    this.partnerName,
    this.partnerLogoUrl,
  });

  final String id;
  final String externalOrderId;
  final String status;
  final DateTime deliveredAt;
  final String? orderProofUrl;
  final String? partnerName;
  final String? partnerLogoUrl;

  bool get hasDisplayablePartnerLogo {
    final url = partnerLogoUrl?.trim();
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  bool get hasOrderProof {
    final value = orderProofUrl?.trim();
    return value != null && value.isNotEmpty;
  }

  bool get hasOrderId {
    final value = externalOrderId.trim();
    return value.isNotEmpty && value != '—';
  }

  String displayOrderId(AppLocalizations l10n) =>
      hasOrderId ? externalOrderId : l10n.notProvided;

  factory DriverDelivery.fromJson(Map<String, dynamic> json) {
    final partners = json['partners'];
    Map<String, dynamic>? partnerMap;
    if (partners is Map<String, dynamic>) {
      partnerMap = partners;
    } else if (partners is List && partners.isNotEmpty) {
      partnerMap = Map<String, dynamic>.from(partners.first as Map);
    }

    return DriverDelivery(
      id: json['id'] as String,
      externalOrderId: json['external_order_id'] as String? ?? '—',
      status: json['status'] as String? ?? 'pending',
      deliveredAt: DateTime.parse(json['delivered_at'] as String),
      orderProofUrl: json['order_proof_url'] as String?,
      partnerName: partnerMap?['name'] as String?,
      partnerLogoUrl: partnerMap?['logo_url'] as String?,
    );
  }
}

class CreatedDelivery {
  const CreatedDelivery({
    required this.id,
    required this.externalOrderId,
    required this.status,
    required this.deliveredAt,
  });

  final String id;
  final String externalOrderId;
  final String status;
  final DateTime deliveredAt;

  factory CreatedDelivery.fromJson(Map<String, dynamic> json) {
    return CreatedDelivery(
      id: json['id'] as String,
      externalOrderId: json['external_order_id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      deliveredAt: DateTime.parse(json['delivered_at'] as String),
    );
  }
}
