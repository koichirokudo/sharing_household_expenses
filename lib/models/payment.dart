import '../constants/payment_status.dart';

class Payment {
  final int id;
  final String profileId;
  final double amount;
  final DateTime paymentDate;
  final String? stripePaymentId;
  final PaymentStatus paymentStatus;
  final int? subscriptionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.profileId,
    required this.amount,
    required this.paymentDate,
    this.stripePaymentId,
    required this.paymentStatus,
    this.subscriptionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      profileId: map['profile_id'],
      amount: map['amount'],
      paymentDate: DateTime.parse(map['payment_date']),
      stripePaymentId: map['stripe_payment_id'],
      paymentStatus: PaymentStatus.values
          .firstWhere((e) => e.name == map['payment_status']),
      subscriptionId: map['subscription_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'stripe_payment_id': stripePaymentId,
      'payment_status': paymentStatus.name,
      'subscription_id': subscriptionId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
