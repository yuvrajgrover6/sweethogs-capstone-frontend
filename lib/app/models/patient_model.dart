import 'package:flutter/material.dart';

class PatientModel {
  final int encounterId;
  final int patientNumber;
  final String race;
  final String gender;
  final String age;
  final String weight;
  final int admissionTypeId;
  final int dischargeDispositionId;
  final int admissionSourceId;
  final int timeInHospital;
  final String payerCode;
  final String medicalSpecialty;
  final int numLabProcedures;
  final int numProcedures;
  final int numMedications;
  final int numberOutpatient;
  final int numberEmergency;
  final int numberInpatient;
  final String diagnosis1;
  final String diagnosis2;
  final String diagnosis3;
  final int numberDiagnoses;
  final String maxGluSerum;
  final String a1cResult;
  final String metformin;
  final String repaglinide;
  final String nateglinide;
  final String chlorpropamide;
  final String glimepiride;
  final String acetohexamide;
  final String glipizide;
  final String glyburide;
  final String tolbutamide;
  final String pioglitazone;
  final String rosiglitazone;
  final String acarbose;
  final String miglitol;
  final String troglitazone;
  final String tolazamide;
  final String examide;
  final String citoglipton;
  final String insulin;
  final String glyburideMetformin;
  final String glipizideMetformin;
  final String glimepiridePioglitazone;
  final String metforminRosiglitazone;
  final String metforminPioglitazone;
  final String change;
  final String diabetesMed;
  final String readmitted;

  const PatientModel({
    required this.encounterId,
    required this.patientNumber,
    required this.race,
    required this.gender,
    required this.age,
    required this.weight,
    required this.admissionTypeId,
    required this.dischargeDispositionId,
    required this.admissionSourceId,
    required this.timeInHospital,
    required this.payerCode,
    required this.medicalSpecialty,
    required this.numLabProcedures,
    required this.numProcedures,
    required this.numMedications,
    required this.numberOutpatient,
    required this.numberEmergency,
    required this.numberInpatient,
    required this.diagnosis1,
    required this.diagnosis2,
    required this.diagnosis3,
    required this.numberDiagnoses,
    required this.maxGluSerum,
    required this.a1cResult,
    required this.metformin,
    required this.repaglinide,
    required this.nateglinide,
    required this.chlorpropamide,
    required this.glimepiride,
    required this.acetohexamide,
    required this.glipizide,
    required this.glyburide,
    required this.tolbutamide,
    required this.pioglitazone,
    required this.rosiglitazone,
    required this.acarbose,
    required this.miglitol,
    required this.troglitazone,
    required this.tolazamide,
    required this.examide,
    required this.citoglipton,
    required this.insulin,
    required this.glyburideMetformin,
    required this.glipizideMetformin,
    required this.glimepiridePioglitazone,
    required this.metforminRosiglitazone,
    required this.metforminPioglitazone,
    required this.change,
    required this.diabetesMed,
    required this.readmitted,
  });

  // Computed properties for better display
  String get displayAge =>
      age.replaceAll('[', '').replaceAll(')', '').replaceAll(',', '-');

  String get patientId => 'P${patientNumber.toString().padLeft(8, '0')}';

  String get encounterIdDisplay => 'E${encounterId.toString().padLeft(7, '0')}';

  String get riskLevel {
    // Simple risk calculation based on multiple factors
    int risk = 0;

    // Age factor
    if (age.contains('70-80') ||
        age.contains('80-90') ||
        age.contains('90-100'))
      risk += 3;
    else if (age.contains('60-70') || age.contains('50-60'))
      risk += 2;
    else if (age.contains('40-50') || age.contains('30-40'))
      risk += 1;

    // Hospital stay factor
    if (timeInHospital > 10)
      risk += 3;
    else if (timeInHospital > 5)
      risk += 2;
    else if (timeInHospital > 2)
      risk += 1;

    // Medication changes
    if (change == 'Ch') risk += 2;

    // Previous admissions
    if (numberInpatient > 0) risk += 1;
    if (numberEmergency > 0) risk += 1;

    // Diabetes medication
    if (diabetesMed == 'Yes') risk += 1;

    // Lab procedures (complexity indicator)
    if (numLabProcedures > 50)
      risk += 2;
    else if (numLabProcedures > 25)
      risk += 1;

    if (risk >= 8) return 'High';
    if (risk >= 5) return 'Medium';
    if (risk >= 2) return 'Low';
    return 'Very Low';
  }

  Color get riskColor {
    switch (riskLevel) {
      case 'High':
        return const Color(0xFFDC2626); // Red
      case 'Medium':
        return const Color(0xFFF59E0B); // Orange
      case 'Low':
        return const Color(0xFF10B981); // Green
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  bool get isHighRisk => riskLevel == 'High' || riskLevel == 'Medium';

  String get primaryDiagnosis {
    if (diagnosis1 != '?') return diagnosis1;
    if (diagnosis2 != '?') return diagnosis2;
    if (diagnosis3 != '?') return diagnosis3;
    return 'Unknown';
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      encounterId: json['encounter_id'] ?? 0,
      patientNumber: json['patient_nbr'] ?? 0,
      race: json['race'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] ?? '',
      weight: json['weight'] ?? '',
      admissionTypeId: json['admission_type_id'] ?? 0,
      dischargeDispositionId: json['discharge_disposition_id'] ?? 0,
      admissionSourceId: json['admission_source_id'] ?? 0,
      timeInHospital: json['time_in_hospital'] ?? 0,
      payerCode: json['payer_code'] ?? '',
      medicalSpecialty: json['medical_specialty'] ?? '',
      numLabProcedures: json['num_lab_procedures'] ?? 0,
      numProcedures: json['num_procedures'] ?? 0,
      numMedications: json['num_medications'] ?? 0,
      numberOutpatient: json['number_outpatient'] ?? 0,
      numberEmergency: json['number_emergency'] ?? 0,
      numberInpatient: json['number_inpatient'] ?? 0,
      diagnosis1: json['diag_1'] ?? '',
      diagnosis2: json['diag_2'] ?? '',
      diagnosis3: json['diag_3'] ?? '',
      numberDiagnoses: json['number_diagnoses'] ?? 0,
      maxGluSerum: json['max_glu_serum'] ?? '',
      a1cResult: json['A1Cresult'] ?? '',
      metformin: json['metformin'] ?? '',
      repaglinide: json['repaglinide'] ?? '',
      nateglinide: json['nateglinide'] ?? '',
      chlorpropamide: json['chlorpropamide'] ?? '',
      glimepiride: json['glimepiride'] ?? '',
      acetohexamide: json['acetohexamide'] ?? '',
      glipizide: json['glipizide'] ?? '',
      glyburide: json['glyburide'] ?? '',
      tolbutamide: json['tolbutamide'] ?? '',
      pioglitazone: json['pioglitazone'] ?? '',
      rosiglitazone: json['rosiglitazone'] ?? '',
      acarbose: json['acarbose'] ?? '',
      miglitol: json['miglitol'] ?? '',
      troglitazone: json['troglitazone'] ?? '',
      tolazamide: json['tolazamide'] ?? '',
      examide: json['examide'] ?? '',
      citoglipton: json['citoglipton'] ?? '',
      insulin: json['insulin'] ?? '',
      glyburideMetformin: json['glyburide-metformin'] ?? '',
      glipizideMetformin: json['glipizide-metformin'] ?? '',
      glimepiridePioglitazone: json['glimepiride-pioglitazone'] ?? '',
      metforminRosiglitazone: json['metformin-rosiglitazone'] ?? '',
      metforminPioglitazone: json['metformin-pioglitazone'] ?? '',
      change: json['change'] ?? '',
      diabetesMed: json['diabetesMed'] ?? '',
      readmitted: json['readmitted'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'encounter_id': encounterId,
      'patient_nbr': patientNumber,
      'race': race,
      'gender': gender,
      'age': age,
      'weight': weight,
      'admission_type_id': admissionTypeId,
      'discharge_disposition_id': dischargeDispositionId,
      'admission_source_id': admissionSourceId,
      'time_in_hospital': timeInHospital,
      'payer_code': payerCode,
      'medical_specialty': medicalSpecialty,
      'num_lab_procedures': numLabProcedures,
      'num_procedures': numProcedures,
      'num_medications': numMedications,
      'number_outpatient': numberOutpatient,
      'number_emergency': numberEmergency,
      'number_inpatient': numberInpatient,
      'diag_1': diagnosis1,
      'diag_2': diagnosis2,
      'diag_3': diagnosis3,
      'number_diagnoses': numberDiagnoses,
      'max_glu_serum': maxGluSerum,
      'A1Cresult': a1cResult,
      'metformin': metformin,
      'repaglinide': repaglinide,
      'nateglinide': nateglinide,
      'chlorpropamide': chlorpropamide,
      'glimepiride': glimepiride,
      'acetohexamide': acetohexamide,
      'glipizide': glipizide,
      'glyburide': glyburide,
      'tolbutamide': tolbutamide,
      'pioglitazone': pioglitazone,
      'rosiglitazone': rosiglitazone,
      'acarbose': acarbose,
      'miglitol': miglitol,
      'troglitazone': troglitazone,
      'tolazamide': tolazamide,
      'examide': examide,
      'citoglipton': citoglipton,
      'insulin': insulin,
      'glyburide-metformin': glyburideMetformin,
      'glipizide-metformin': glipizideMetformin,
      'glimepiride-pioglitazone': glimepiridePioglitazone,
      'metformin-rosiglitazone': metforminRosiglitazone,
      'metformin-pioglitazone': metforminPioglitazone,
      'change': change,
      'diabetesMed': diabetesMed,
      'readmitted': readmitted,
    };
  }

  /// Convert to API format for readmission prediction
  /// This format matches the API specification exactly
  Map<String, dynamic> toApiJson() {
    return {
      'encounter_id': encounterId,
      'patient_nbr': patientNumber,
      'race': race,
      'gender': gender,
      'age': age,
      'weight': weight.isEmpty ? '?' : weight,
      'admission_type_id': admissionTypeId,
      'discharge_disposition_id': dischargeDispositionId,
      'admission_source_id': admissionSourceId,
      'time_in_hospital': timeInHospital,
      'payer_code': payerCode.isEmpty ? '?' : payerCode,
      'medical_specialty': medicalSpecialty.isEmpty ? '?' : medicalSpecialty,
      'num_lab_procedures': numLabProcedures,
      'num_procedures': numProcedures,
      'num_medications': numMedications,
      'number_outpatient': numberOutpatient,
      'number_emergency': numberEmergency,
      'number_inpatient': numberInpatient,
      'diag_1': diagnosis1.isEmpty ? '?' : diagnosis1,
      'diag_2': diagnosis2.isEmpty ? '?' : diagnosis2,
      'diag_3': diagnosis3.isEmpty ? '?' : diagnosis3,
      'number_diagnoses': numberDiagnoses,
      'max_glu_serum': maxGluSerum.isEmpty ? '?' : maxGluSerum,
      'A1Cresult': a1cResult.isEmpty ? '?' : a1cResult,
      'metformin': metformin.isEmpty ? 'No' : metformin,
      'repaglinide': repaglinide.isEmpty ? 'No' : repaglinide,
      'nateglinide': nateglinide.isEmpty ? 'No' : nateglinide,
      'chlorpropamide': chlorpropamide.isEmpty ? 'No' : chlorpropamide,
      'glimepiride': glimepiride.isEmpty ? 'No' : glimepiride,
      'acetohexamide': acetohexamide.isEmpty ? 'No' : acetohexamide,
      'glipizide': glipizide.isEmpty ? 'No' : glipizide,
      'glyburide': glyburide.isEmpty ? 'No' : glyburide,
      'tolbutamide': tolbutamide.isEmpty ? 'No' : tolbutamide,
      'pioglitazone': pioglitazone.isEmpty ? 'No' : pioglitazone,
      'rosiglitazone': rosiglitazone.isEmpty ? 'No' : rosiglitazone,
      'acarbose': acarbose.isEmpty ? 'No' : acarbose,
      'miglitol': miglitol.isEmpty ? 'No' : miglitol,
      'troglitazone': troglitazone.isEmpty ? 'No' : troglitazone,
      'tolazamide': tolazamide.isEmpty ? 'No' : tolazamide,
      'examide': examide.isEmpty ? 'No' : examide,
      'citoglipton': citoglipton.isEmpty ? 'No' : citoglipton,
      'insulin': insulin.isEmpty ? 'No' : insulin,
      'glyburide-metformin': glyburideMetformin.isEmpty
          ? 'No'
          : glyburideMetformin,
      'glipizide-metformin': glipizideMetformin.isEmpty
          ? 'No'
          : glipizideMetformin,
      'glimepiride-pioglitazone': glimepiridePioglitazone.isEmpty
          ? 'No'
          : glimepiridePioglitazone,
      'metformin-rosiglitazone': metforminRosiglitazone.isEmpty
          ? 'No'
          : metforminRosiglitazone,
      'metformin-pioglitazone': metforminPioglitazone.isEmpty
          ? 'No'
          : metforminPioglitazone,
      'change': change.isEmpty ? 'No' : change,
      'diabetesMed': diabetesMed.isEmpty ? 'No' : diabetesMed,
    };
  }
}

// Pagination model for patients
class PatientPagination {
  final List<PatientModel> patients;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  const PatientPagination({
    required this.patients,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  int get startIndex => (currentPage - 1) * itemsPerPage + 1;
  int get endIndex => (currentPage * itemsPerPage).clamp(0, totalItems);
}
