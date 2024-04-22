import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luckymoon/features/board/cubit/board_cubit.dart';

import '../features/chat/cubit/chat_cubit.dart';
import '../features/consult/cubit/consult_cubit.dart';
import '../features/home/cubit/home_cubit.dart';

class BlocWidget extends StatelessWidget {
  const BlocWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (BuildContext context) => HomeCubit(),
        ),
        BlocProvider<BoardCubit>(
          create: (BuildContext context) => BoardCubit(),
        ),
        BlocProvider<ChatCubit>(
          create: (BuildContext context) => ChatCubit(),
        ),
        BlocProvider<ConsultCubit>(
          create: (BuildContext context) => ConsultCubit(),
        ),
      ],
      child: child,
    );
  }
}