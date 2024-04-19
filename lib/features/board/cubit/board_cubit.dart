import 'package:bloc/bloc.dart';
import 'package:luckymoon/data/Counsellor.dart';

import '../../../data/Review.dart';
import '../state/board_state.dart';

class BoardCubit extends Cubit<BoardState> {
  BoardCubit() : super(BoardState());

  void setCounsellor(Counsellor counsellor) {
    state.counsellor = counsellor;
  }

  Counsellor getCounsellor() {
    return state.counsellor;
  }

  List<Review> getReviews() {
    return state.reviews;
  }
}
