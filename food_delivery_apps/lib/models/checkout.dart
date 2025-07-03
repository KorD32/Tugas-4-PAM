class CheckoutItem {
  final String name;
  final String image;
  final int price;
  final DateTime dateTime;
  final int quantity;

  CheckoutItem({
    required this.name,
    required this.image,
    required this.price,
    required this.dateTime,
    required this.quantity,
  });
}

class Checkout {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String paymentMethod;
  final int totalAmount;
  final DateTime createdAt;

  Checkout({
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.paymentMethod,
    required this.totalAmount,
    required this.createdAt,
  });

  factory Checkout.fromJson(Map<String, dynamic> json) => Checkout(
        customerName: json['customerName'],
        customerPhone: json['customerPhone'],
        customerAddress: json['customerAddress'],
        paymentMethod: json['paymentMethod'],
        totalAmount: json['totalAmount'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerAddress': customerAddress,
        'paymentMethod': paymentMethod,
        'totalAmount': totalAmount,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };
}
