import 'package:bloc/bloc.dart';

import '../state/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState());
}
