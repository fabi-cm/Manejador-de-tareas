import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendPushNotification(String fcmToken, String title, String body) async {
  final String serverKey = 'BEC_wytZRWxIPP0rI-Js3yaPy9nuAQnbUo3F1eJx82sDVfZwDgcTElypc3GZYES3Mn6a9i0s3LjGPKRjIdDmJxY'; // Reemplaza con tu clave de servidor FCM
  final String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  final response = await http.post(
    Uri.parse(fcmUrl),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    },
    body: jsonEncode(<String, dynamic>{
      'to': fcmToken,
      'notification': <String, dynamic>{
        'title': title,
        'body': body,
      },
      'data': <String, dynamic>{
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'id': '1',
        'status': 'done'
      },
    }),
  );

  if (response.statusCode == 200) {
    print('Notificación enviada con éxito');
  } else {
    print('Error al enviar la notificación: ${response.body}');
  }
}