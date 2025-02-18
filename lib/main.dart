import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:task_manager/presentation/pages/home_page.dart';
import 'presentation/blocs/auth_bloc.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/sign_in_with_google.dart';
import 'presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final authRepository = AuthRepositoryImpl();
  final signInWithGoogle = SignInWithGoogle(authRepository);

  runApp(MyApp(signInWithGoogle: signInWithGoogle));
}

class MyApp extends StatelessWidget {
  final SignInWithGoogle signInWithGoogle;
  MyApp({required this.signInWithGoogle});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(signInWithGoogle)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state.user != null) {
              return HomePage(); // Si está autenticado, ir a Home
            }
            return LoginPage(); // Si no, mostrar login
          },
        ),
      ),
    );
  }
}
