class PaymentType {
  int id;
  String name;
  String desc;
  String assetImage;
  Function pay;

  PaymentType(
      {required this.id,
      required this.name,
      required this.desc,
      required this.assetImage,
      required this.pay});
}
