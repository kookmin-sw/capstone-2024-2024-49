import 'package:bloc/bloc.dart';
import 'package:luckymoon/data/Counsellor.dart';
import '../state/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatState());

  void setCounsellor(Counsellor counsellor) {
    state.counsellor = counsellor;
  }

  Counsellor getCounsellor() {
    return state.counsellor;
  }
}