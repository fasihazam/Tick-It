class Day {
  final int dayID;
  final String location;
  final String vip;
  final String type;
  final String description;
  final String event_link;
  final double pricePerTicket;
  final double sponsoredPrice;
  final double lat;
  final double long;
  final String date;
  final String start_time;
  final String end_time;
  final int sold;
  final int left;

  const Day({
    required this.dayID,
    required this.location,
    required this.vip,
    required this.type,
    required this.description,
    required this.event_link,
    required this.pricePerTicket,
    required this.sponsoredPrice,
    required this.lat,
    required this.long,
    required this.date,
    required this.start_time,
    required this.end_time,
    required this.sold,
    required this.left,
  });

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      dayID: json['id'],
      location: json['location'],
      vip: json['vip'],
      type: json['type'],
      description: json['description'],
      event_link: json['event_link'],
      pricePerTicket: double.parse(json['pricePerTicket'].toString()),
      sponsoredPrice: double.parse(json['s_price'].toString()),
      lat: double.parse(json['lat'].toString()),
      long: double.parse(json['long'].toString()),
      date: json['date'],
      start_time: json['start_time'],
      end_time: json['end_time'],
      sold: json['ticket_sold'],
      left: json['ticket_left'],

    );
  }
  
}