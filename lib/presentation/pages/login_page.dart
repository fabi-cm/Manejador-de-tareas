import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state.user != null) {
            // Si el usuario ya inició sesión, ir al HomePage
            return HomePage();
          }
          return Center(
            child: ElevatedButton(
              onPressed: () => context.read<AuthCubit>().login(),
              child: Text("Iniciar sesión con Google"),
            ),
          );
        },
      ),
    );
  }
}
