class Subscription {
  String id;

  String serviceName;

  double price;

  DateTime renewalDate;

  String status;

  Subscription({
    required this.id,

    required this.serviceName,

    required this.price,

    required this.renewalDate,

    required this.status,
  });
}
