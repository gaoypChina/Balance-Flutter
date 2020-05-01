
import 'dart:math' as math;

/// Function to compute the time features of COGvML and COGvAP
///
/// This function compute all the time features required for the
/// stabilometric analysis; such as sway path, mean distance, standard
/// deviation and range.
///
/// Here's the algorithm written in Octave:
/// ```
///     %%%%%   sway path  %%%%%%
///     sway_path = 0;
///     displacement = zeros(size(ap)-1);
///     for i = 1:size(ap)-1
///     sway_path = sway_path + sqrt((ml(i+1)- ml(i))^2+(ap(i+1)- ap(i))^2);
///     displacement(i) = sqrt(ml(i)^2+ap(i)^2);
///     end
///     sway_path = sway_path/duration;
///
///     %%%%% mean COP distance  %%%%%%%
///     mean_displacement = mean(displacement);
///
///     %%%%% standard deviation of COP %%%%%%
///     displacement_standard_deviation = std(displacement);
///
///     %%%%% Range of COP displacement %%%%%%%%%
///     range = [min(displacement), max(displacement)];
/// ```
///
/// Return:
/// a Map with: swayPath, meanDisplacement, stdDisplacement, minDist, maxDist
Future<Map<String, double>> timeDomainFeatures(List<double> ap, List<double> ml) {
  // Compute the Sway Path
  double swayPath = 0.0;
  for (var i = 0; i < ml.length - 1; i++) {
    swayPath += math.sqrt(math.pow(ml[i + 1] - ml[i], 2) + math.pow(ap[i + 1] - ap[i], 2));
  }
  swayPath /= 32;

  // Compute the Displacement
  List<double> displacement = [];
  for (var i = 0; i < ml.length; i++) {
    displacement.add(math.sqrt(math.pow(ml[i], 2) + math.pow(ap[i], 2)));
  }

  // Compute the Mean Displacement
  double meanDisplacement = displacement.reduce((value, e) => value + e) / displacement.length;

  // Compute the Standard Deviation
  var stdDisplacement = displacement.fold(0.0, (prev, curr) => prev + math.pow(curr - meanDisplacement, 2));
  stdDisplacement /= displacement.length;
  stdDisplacement = math.sqrt(stdDisplacement);

  // Compute the Range
  double minDisplacement = displacement.reduce(math.min);
  double maxDisplacement = displacement.reduce(math.max);

  return Future.value({
    "swayPath": swayPath,
    "meanDisplacement": meanDisplacement,
    "stdDisplacement": stdDisplacement,
    "minDist": minDisplacement,
    "maxDist": maxDisplacement
  });
}