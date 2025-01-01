import '../constants/plan_type.dart';
import '../constants/subscription_status.dart';

class Subscription {
  final int id;
  final String profileId;
  final String? stripeSubscriptionId;
  final String? stripePlanId;
  final PlanType? planType;
  final SubscriptionStatus? status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.profileId,
    this.stripeSubscriptionId,
    this.stripePlanId,
    this.planType,
    this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      profileId: map['profile_id'],
      stripeSubscriptionId: map['stripe_subscription_id'],
      stripePlanId: map['stripe_plan_id'],
      planType: map['plan_type'] != null
          ? PlanType.values.firstWhere((e) => e.name == map['plan_type'])
          : null,
      status: map['status'] != null
          ? SubscriptionStatus.values.firstWhere((e) => e.name == map['status'])
          : null,
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'stripe_subscription_id': stripeSubscriptionId,
      'stripe_plan_id': stripePlanId,
      'plan_type': planType?.name,
      'status': status?.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
