import 'package:flutter/material.dart';
import 'package:frontend/auth/home_screen.dart';
import 'package:frontend/auth/login/login_screen.dart';
import 'package:frontend/auth/register/register_screen.dart';
import 'package:frontend/blocks/bloques_crud.dart';
import 'package:frontend/categoria/categoria_crud.dart';
import 'package:frontend/edificios/edificios_crud.dart';
import 'package:frontend/evaluacion/evaluaciones_list.dart';
import 'package:frontend/evaluacion/evaluaciones_screen.dart';
import 'package:frontend/map/custom_map_ui.dart';
import 'package:frontend/menu_screen.dart';
import 'package:frontend/lugar/lugar_crud.dart';

final Map<String, WidgetBuilder> rutasPantallas = {
  '/': (context) => HomeScreen(),
  '/login': (context) => LoginScreen(),
  '/register': (context) => RegisterScreen(),
  '/menu': (context) => MenuScreen(
        token: 'token',
      ),
  '/agregarLugar': (context) => AgregarLugarScreen(),
  '/categoria': (context) => CategoriaScreen(),
  '/edificio': (context) => EdificioScreen(),
  '/bloques': (context) => BloquesScreen(),
  '/evaluacion': (context) => EvaluacionScreen(),
  '/map': (context) => CustomMapUI(),
  '/listEvaluacion': (context) => EvaluacionesListScreen(),
};
