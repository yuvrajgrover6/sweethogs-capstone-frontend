import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sweethogs_capstone_frontend/app/controllers/patients_controller.dart';
import 'package:sweethogs_capstone_frontend/app/models/patient_model.dart';
import 'package:sweethogs_capstone_frontend/app/models/readmission_prediction_model.dart';

// Mock classes
class MockReadmissionService extends Mock {}

void main() {
  group('PatientsController PDF Download Tests', () {
    late PatientsController controller;
    late PatientModel testPatient;
    late ReadmissionPrediction testPrediction;

    setUp(() {
      controller = PatientsController();
      
      // Create test patient
      testPatient = PatientModel(
        patientId: 'TEST001',
        age: 65,
        gender: 'M',
        admissionType: 'Emergency',
        dischargeDisposition: 'Home',
        timeInHospital: 5,
        numLabProcedures: 15,
        numProcedures: 2,
        numMedications: 8,
        numberOutpatient: 1,
        numberEmergency: 0,
        numberInpatient: 0,
        diabetesMed: 'Yes',
        readmitted: 'NO',
        raceId: 1,
        genderId: 1,
        admissionTypeId: 1,
        dischargeDispositionId: 1,
        admissionSourceId: 1,
        diag1Id: 250,
        diag2Id: 401,
        diag3Id: 272,
        maxGluSerum: 'Norm',
        a1cResult: '>8',
        insulin: 'No',
        change: 'No',
        metformin: 'No',
        patientName: 'John Doe',
        dateOfBirth: DateTime(1958, 5, 15),
        phoneNumber: '555-0123',
        address: '123 Main St, City, State',
      );

      // Create test prediction
      testPrediction = ReadmissionPrediction(
        patientId: 'TEST001',
        probability: 0.75,
        riskLevel: 'High',
        riskFactors: ['Diabetes medication', 'Multiple lab procedures'],
        recommendation: 'Close monitoring required',
        timestamp: DateTime.now(),
      );
    });

    test('downloadPredictionPdf method exists and is properly typed', () {
      expect(controller.downloadPredictionPdf, isA<Function>());
    });

    test('ReadmissionPrediction has toJson method', () {
      final json = testPrediction.toJson();
      
      expect(json, isA<Map<String, dynamic>>());
      expect(json['patientId'], equals('TEST001'));
      expect(json['probability'], equals(0.75));
      expect(json['riskLevel'], equals('High'));
      expect(json['riskFactors'], isA<List<String>>());
      expect(json['recommendation'], equals('Close monitoring required'));
      expect(json['timestamp'], isA<String>());
    });

    test('Patient model has toJson method for PDF generation', () {
      final json = testPatient.toJson();
      
      expect(json, isA<Map<String, dynamic>>());
      expect(json['patientId'], equals('TEST001'));
      expect(json['age'], equals(65));
      expect(json['gender'], equals('M'));
    });
  });
}
