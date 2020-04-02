
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:balance_app/bloc/states/result_states.dart';
import 'package:balance_app/bloc/result_bloc.dart';

import 'package:balance_app/model/measurement.dart';
import 'package:balance_app/widgets/result_features_items.dart';
import 'package:balance_app/widgets/result_info_item.dart';

class ResultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the resultId from the arguments
    final int resultId = ModalRoute.of(context).settings.arguments;
    final Measurement measurement = Measurement(
      id: resultId,
      eyesOpen: true,
      creationDate: DateTime.now().millisecondsSinceEpoch,
    );

    return Scaffold(
      body: BlocProvider(
        create: (context) => ResultBloc.create(measurement.id),
        child: BlocBuilder<ResultBloc, ResultState>(
          builder: (context, state) {
            print(state);
            // Display the data
            if (state is ResultSuccess)
              return _successScreen(context, measurement, state);
            // Display the error snack-bar
            else if (state is ResultError) {
              WidgetsBinding.instance
                .addPostFrameCallback((_) => Scaffold.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text("An unexpected error occurred!"),
                )
              ));
              return _successScreen(context, measurement, null);
            }
            // Display the loading
            else
              return _loadingScreen(context, measurement);
          },
        ),
      ),
    );
  }

  /// Build the loading screen
  Widget _loadingScreen(BuildContext context, Measurement measurement) => Scaffold(
    appBar: AppBar(
      title: Text("Test ${measurement.id}"),
      elevation: 0,
    ),
    body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        // Result info card and appbar overflow
        Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Positioned.fill(
              child: Container(
                margin: EdgeInsets.only(bottom: 26),
                color: Theme.of(context).primaryColor,
              ),
            ),
            // Result info card
            ResultInfoItem(measurement)
          ]
        ),
        Expanded(
          child: Center(
            child: Container(
              width: 100,
              height: 100,
              child: CircularProgressIndicator()
            ),
          ),
        )
      ],
    )
  );

  /// Build the screen with data
  Widget _successScreen(
    BuildContext context,
    Measurement measurement,
    ResultSuccess success
    ) => CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        title: Text("Test ${measurement.id}"),
        floating: false,
      ),
      SliverList(
        delegate: SliverChildListDelegate.fixed([
          // Result info card and appbar overflow
          Stack(
            alignment: AlignmentDirectional.topCenter,
            children: <Widget>[
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.only(bottom: 26),
                  color: Theme.of(context).primaryColor,
                ),
              ),
              // Result info card
              ResultInfoItem(measurement),
            ]
          ),
          ResultFeaturesItems(),
        ])
      )
    ]);
}
