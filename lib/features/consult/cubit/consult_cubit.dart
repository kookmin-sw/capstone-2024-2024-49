import 'package:bloc/bloc.dart';
import 'package:luckymoon/data/Counsellor.dart';
import '../../../data/User.dart';
import '../state/consult_state.dart';

class ConsultCubit extends Cubit<ConsultState> {
  ConsultCubit() : super(ConsultState());

  void setUser(User user) {
    state.user = user;
  }

  User getUser() {
    return state.user;
  }

  void setChatId(String chatId) {
    state.chatId = chatId;
  }

  String getChatId() {
    return state.chatId;
  }
}