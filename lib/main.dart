import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
