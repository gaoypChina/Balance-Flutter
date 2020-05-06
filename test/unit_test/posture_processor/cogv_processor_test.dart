
import 'package:balance_app/model/raw_measurement_data.dart';
import 'package:balance_app/posture_processor/src/cogv_processor.dart';
import 'package:balance_app/posture_processor/src/math/matrix.dart';
import 'package:flutter_test/flutter_test.dart';

import 'resource_loader.dart';

void main() {
  group("COGv Processor", () {
    Matrix initialData;
    // Data to test
    Matrix dataToRotate;
    Matrix dataToFilter;
    Matrix dataToDownsample;
    Matrix dataToDetrend;
    Matrix dataToDrop;
    // Data precomputed
    Matrix rotatedData;
    Matrix filteredData;
    Matrix downsampledData;
    Matrix detrendedData;
    Matrix droppedData;

    setUpAll(() {
      // Get test data from file
      initialData = loadMatrixFromResource("test_data.txt")?.transpose();

      dataToRotate = loadMatrixFromResource("data_to_rotate.txt")?.transpose();
      dataToFilter = loadMatrixFromResource("data_to_filter.txt")?.transpose();
      dataToDownsample = loadMatrixFromResource("data_to_downsample.txt")?.transpose();
      dataToDetrend = loadMatrixFromResource("data_to_detrend.txt")?.transpose();
      dataToDrop = loadMatrixFromResource("data_to_drop.txt")?.transpose();

      rotatedData = loadMatrixFromResource("rotated_data.txt")?.transpose();
      filteredData = loadMatrixFromResource("filtered_data.txt")?.transpose();
      downsampledData = loadMatrixFromResource("downsampled_data.txt")?.transpose();
      detrendedData = loadMatrixFromResource("detrended_data.txt")?.transpose();
      droppedData = loadMatrixFromResource("dropped_data.txt")?.transpose();
    });

    tearDownAll(() {
      initialData = null;
      dataToRotate = null;
      dataToFilter = null;
      dataToDownsample = null;
      dataToDetrend = null;
      dataToDrop = null;
      rotatedData = null;
      filteredData = null;
      downsampledData = null;
      detrendedData = null;
      droppedData = null;
    });

    test("compute whole cogv", () async {
      List<RawMeasurementData> rawMeasurements = [];
      initialData.forEachColumn((_, rowValues) =>
        rawMeasurements.add(
          RawMeasurementData(
            accelerometerX: rowValues[0],
            accelerometerY: rowValues[1],
            accelerometerZ: rowValues[2]
          )
        )
      );
      final computedMatrix = await computeCogv(rawMeasurements, 180.0);
      expect(computedMatrix.rows, equals(droppedData.rows));
      expect(computedMatrix.cols, equals(droppedData.cols));
      computedMatrix.forEachIndexed((row, col, value) {
        expect(value, within(distance: 0.02, from: droppedData.get(row, col)));
      });

      writeMatrixToFile(computedMatrix.transpose(), "computed.txt");
    });

    test("rotate axis", () async {
      final extracted = dataToRotate.extractRows();
      final rotatedDataMatrix = rotateAxis(extracted[0], extracted[1], extracted[2]);
      expect(rotatedDataMatrix.rows, equals(rotatedData.rows));
      expect(rotatedDataMatrix.cols, equals(rotatedData.cols));
      rotatedDataMatrix.forEachIndexed((row, col, value) =>
        expect(value, within(distance: 0000000000000002, from: rotatedData.get(row, col))));

      await writeMatrixToFile(rotatedDataMatrix.transpose(), "rotated_data.txt");
    });

    test("filter data", () async {
      final filteredMatrix = filterData(dataToFilter);

      expect(filteredMatrix.rows, equals(filteredData.rows));
      expect(filteredMatrix.cols, equals(filteredData.cols));
      filteredMatrix.forEachIndexed((r,c,v) =>
        expect(v, within(distance: 0.000000001, from: filteredData.get(r,c))));

      await writeMatrixToFile(filteredMatrix.transpose(), "filtered_data.txt");
    });

    test("downsample data",() async {
      final downsampledMatrix = downsample(dataToDownsample);

      expect(downsampledMatrix.rows, equals(downsampledData.rows));
      expect(downsampledMatrix.cols, equals(downsampledData.cols));
      downsampledMatrix.forEachIndexed((r, c, v) =>
        expect(v, equals(downsampledData.get(r,c))));

      await writeMatrixToFile(downsampledMatrix.transpose(), "downsampled_data.txt");
    });

    test("detrend data", () async {
      final detrendedMatrix = detrend(dataToDetrend);

      expect(detrendedMatrix.rows, equals(detrendedData.rows));
      expect(detrendedMatrix.cols, equals(detrendedData.cols));
      detrendedMatrix.forEachIndexed((r, c, v) =>
        expect(v, within(distance: 0.00000000000005, from: detrendedData.get(r, c))));

      await writeMatrixToFile(detrendedMatrix.transpose(), "detrended_data.txt");
    });

    test("drop first two seconds", () async {
      final droppedMatrix = removeFirstTwoSecond(dataToDrop);

      expect(droppedMatrix.rows, equals(droppedData.rows));
      expect(droppedMatrix.cols, equals(dataToDrop.cols - 100));
      expect(droppedMatrix.cols, equals(droppedData.cols));
      droppedMatrix.forEachIndexed((r, c, v) => expect(v, equals(droppedData.get(r,c))));

      await writeMatrixToFile(droppedMatrix.transpose(), "dropped_data.txt");
    });
  });

  group("Excepitons", () {
    test("rotate throws an exception", () {
      expect(() => rotateAxis([], [1.0], [1.0, 2.0]), throwsAssertionError);
      expect(() => rotateAxis([], [], []), throwsAssertionError);
    });

    test("filter throws an exception", () {
      expect(() => filterData(Matrix(3, 1, [1.0,2.0,3.0])), throwsAssertionError);
    });

    test("downsample throws an exception", () {
      expect(() => downsample(Matrix(3, 1, [1.0,2.0,3.0])), throwsAssertionError);
    });

    test("detrend throws an exception", () {
      expect(() => detrend(Matrix(3, 1, [1.0,2.0,3.0])), throwsAssertionError);
    });

    test("drop throws an exception", () {
      expect(() => removeFirstTwoSecond(Matrix(3, 1, [1.0,2.0,3.0])), throwsAssertionError);
    });
  });
}