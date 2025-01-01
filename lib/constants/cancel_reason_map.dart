import 'cancel_reason.dart';

const Map<CancelReason, String> cancelReasonToString = {
  CancelReason.expensive: 'Expensive',
  CancelReason.featuresNotNeeded: 'Features provided were not needed',
  CancelReason.difficultToUse: 'It was difficult to use',
  CancelReason.tooManyBugs: 'Too many bug',
  CancelReason.dissatisfiedWithPerformance: 'Dissatisfied with performance',
  CancelReason.providerService: 'Provider service',
  CancelReason.temporaryUse: 'Temporary use',
  CancelReason.privacyConcerns: 'Privacy and security concerns',
  CancelReason.others: 'Others',
};

const Map<String, CancelReason> stringToCancelReason = {
  'Expensive': CancelReason.expensive,
  'Features provided were not needed': CancelReason.featuresNotNeeded,
  'It was difficult to use': CancelReason.difficultToUse,
  'Too many bug': CancelReason.tooManyBugs,
  'Dissatisfied with performance': CancelReason.dissatisfiedWithPerformance,
  'Provider service': CancelReason.providerService,
  'Temporary use': CancelReason.temporaryUse,
  'Privacy and security concerns': CancelReason.privacyConcerns,
  'Others': CancelReason.others,
};
