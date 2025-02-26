import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_manager/presentation/blocs/auth_cubit.dart';
import 'package:task_manager/presentation/blocs/task_cubit.dart';
import 'package:task_manager/presentation/pages/admin_screen.dart';
import 'package:task_manager/screens/login_screen.dart';

import 'data/repositories/task_repository_impl.dart';
import 'domain/usecases/task/add_task.dart';
import 'domain/usecases/task/delete_task.dart';
import 'domain/usecases/task/get_tasks_assigned_by.dart';
import 'domain/usecases/task/update_task.dart';


// ✅ Agregar `navigatorKey` para manejar navegación en `AuthCubit`
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final taskRepository = TaskRepositoryImpl();

  await requestNotificationPermissions();
  setupFCMListener();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()..checkAuthStatus()),
        BlocProvider<TaskCubit>(create: (context) => TaskCubit(
          addTask: AddTask(taskRepository),
          updateTask: UpdateTask(taskRepository),
          deleteTask: DeleteTask(taskRepository),
          getTasksAssignedBy: GetTasksAssignedBy(taskRepository),
        )),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // ✅ Pasar `navigatorKey` a MaterialApp
      home: LoginScreen(), // O HomeScreen según tu flujo
    );
  }
}

Future<void> requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print("❌ El usuario ha denegado las notificaciones");
  } else {
    print("✅ Notificaciones permitidas");
  }
}

void setupFCMListener() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      showFlutterNotification(message.notification!);
    }
  });
}

void showFlutterNotification(RemoteNotification notification) {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var androidDetails = AndroidNotificationDetails(
    'channel_id', 'channel_name',
    importance: Importance.max, priority: Priority.high,
  );
  var generalNotificationDetails = NotificationDetails(android: androidDetails);

  flutterLocalNotificationsPlugin.show(
    0,
    notification.title,
    notification.body,
    generalNotificationDetails,
  );
}