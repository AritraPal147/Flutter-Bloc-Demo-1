import 'package:flutter_bloc/flutter_bloc.dart';
part 'counter_state.dart';

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterState(counterValue: 0, wasIncremented: false));

  // state.counterValue gives the counterValue of current state.
  // increment() function emits a CounterState after incrementing counterValue by 1
  void increment() => emit(CounterState(counterValue: state.counterValue+1, wasIncremented: true));

  // decrement() function emits a CounterState after decrementing counterValue by 1
  void decrement() => emit(CounterState(counterValue: state.counterValue-1, wasIncremented: false));
}
