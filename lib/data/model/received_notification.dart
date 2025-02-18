class ReceivedNotification {
  final int? id;
  final String? title;
  final String? body;
  final String? payload;

  ReceivedNotification({
    this.id,
    this.title,
    this.body,
    this.payload,
  });


  factory ReceivedNotification.fromMap(Map<String, dynamic> data) {
    return ReceivedNotification(
      id: data['id'],
      title: data['title'],
      body: data['body'],
      payload: data['payload'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
    };
  }
}