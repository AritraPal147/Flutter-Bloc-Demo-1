import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/counter_cubit.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      /// Implements BlocListener to display a snackbar whenever the + or - buttons are pressed

      // body: BlocListener<CounterCubit, CounterState>(
      //   listener: (context, state) {
      //     if (state.wasIncremented) {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(
      //           content: Text("Incremented"),
      //           duration: Duration(milliseconds: 500),
      //         ),
      //       );
      //     } else {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(
      //           content: Text("Decremented"),
      //           duration: Duration(milliseconds: 500),
      //         ),
      //       );
      //     }
      //   },

      body: SafeArea(
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                // Instance of blockbuilder
                // BlocBuilder<CounterCubit, CounterState>(
                //   builder: (context, state) {
                //     return Text(
                //       '${state.counterValue}',
                //       style: Theme
                //           .of(context)
                //           .textTheme
                //           .headlineMedium,
                //     );
                //   },
                // ),

                BlocConsumer<CounterCubit, CounterState>(
                  // BlocBuilder
                  builder: (context, state){
                    if (state.counterValue < 0) {
                      return Text(
                          "BRR, Negative ${state.counterValue}",
                          style: Theme.of(context).textTheme.headlineLarge);
                    }
                    else if (state.counterValue % 2 == 0) {
                      return Text(
                          "YAAY ${state.counterValue} is EVEN!!",
                          style: Theme.of(context).textTheme.headlineLarge);
                    }
                    else if (state.counterValue == 5) {
                      return Text(
                          "Hmm, Number 5",
                          style: Theme.of(context).textTheme.headlineLarge);
                    }
                    else {
                      return Text(
                          '${state.counterValue}',
                          style: Theme.of(context).textTheme.headlineLarge);
                    }
                  },
                  // BlocListener
                  listener: (context, state) {
                    if (state.wasIncremented) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Incremented"),
                          duration: Duration(milliseconds: 300),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Decremented"),
                          duration: Duration(milliseconds: 300),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
        ),
      ),
        floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                onPressed: () => BlocProvider.of<CounterCubit>(context).decrement(),
                tooltip: 'Decrement',
                child: const Icon(Icons.remove),
              ),

              FloatingActionButton(
                onPressed: () => BlocProvider.of<CounterCubit>(context).increment(),
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ),
            ],
        ),
    );
  }
}