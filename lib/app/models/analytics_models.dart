/// Patient Statistics Model
class PatientStats {
  final int totalPatients;
  final Map<String, int> byGender;
  final Map<String, int> byAgeGroup;
  final Map<String, int> byDiabetesMedication;
  final Map<String, int> byReadmission;
  final double averageHospitalStay;
  final double averageMedications;

  PatientStats({
    required this.totalPatients,
    required this.byGender,
    required this.byAgeGroup,
    required this.byDiabetesMedication,
    required this.byReadmission,
    required this.averageHospitalStay,
    required this.averageMedications,
  });

  factory PatientStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'];
    return PatientStats(
      totalPatients: stats['total_patients'],
      byGender: Map<String, int>.from(stats['by_gender']),
      byAgeGroup: Map<String, int>.from(stats['by_age_group']),
      byDiabetesMedication: Map<String, int>.from(stats['by_diabetes_medication']),
      byReadmission: Map<String, int>.from(stats['by_readmission']),
      averageHospitalStay: stats['average_hospital_stay'].toDouble(),
      averageMedications: stats['average_medications'].toDouble(),
    );
  }
}

/// Chart Data Model
class ChartDataItem {
  final String label;
  final int value;
  final String? percentage;

  ChartDataItem({
    required this.label,
    required this.value,
    this.percentage,
  });

  factory ChartDataItem.fromJson(Map<String, dynamic> json) {
    return ChartDataItem(
      label: json['label'],
      value: json['value'],
      percentage: json['percentage'],
    );
  }
}

/// KPIs Model
class AnalyticsKPIs {
  final int totalPatients;
  final int diabetesPatients;
  final int readmittedPatients;
  final String diabetesPercentage;
  final String readmissionPercentage;
  final double avgHospitalStay;
  final double avgMedications;
  final double avgProcedures;
  final double avgLabProcedures;

  AnalyticsKPIs({
    required this.totalPatients,
    required this.diabetesPatients,
    required this.readmittedPatients,
    required this.diabetesPercentage,
    required this.readmissionPercentage,
    required this.avgHospitalStay,
    required this.avgMedications,
    required this.avgProcedures,
    required this.avgLabProcedures,
  });

  factory AnalyticsKPIs.fromJson(Map<String, dynamic> json) {
    return AnalyticsKPIs(
      totalPatients: json['total_patients'],
      diabetesPatients: json['diabetes_patients'],
      readmittedPatients: json['readmitted_patients'],
      diabetesPercentage: json['diabetes_percentage'],
      readmissionPercentage: json['readmission_percentage'],
      avgHospitalStay: json['avg_hospital_stay'].toDouble(),
      avgMedications: json['avg_medications'].toDouble(),
      avgProcedures: json['avg_procedures'].toDouble(),
      avgLabProcedures: json['avg_lab_procedures'].toDouble(),
    );
  }
}

/// Charts Data Model
class AnalyticsCharts {
  final List<ChartDataItem> genderDistribution;
  final List<ChartDataItem> ageDistribution;
  final List<ChartDataItem> diabetesDistribution;
  final List<ChartDataItem> readmissionDistribution;
  final List<ChartDataItem> hospitalStayDistribution;
  final List<ChartDataItem> medicationDistribution;
  final List<ChartDataItem> raceDistribution;
  final List<ChartDataItem> procedureDistribution;
  final List<ChartDataItem> diagnosisDistribution;
  final List<ChartDataItem> monthlyAdmissions;

  AnalyticsCharts({
    required this.genderDistribution,
    required this.ageDistribution,
    required this.diabetesDistribution,
    required this.readmissionDistribution,
    required this.hospitalStayDistribution,
    required this.medicationDistribution,
    required this.raceDistribution,
    required this.procedureDistribution,
    required this.diagnosisDistribution,
    required this.monthlyAdmissions,
  });

  factory AnalyticsCharts.fromJson(Map<String, dynamic> json) {
    return AnalyticsCharts(
      genderDistribution: (json['gender_distribution'] as List)
          .map((item) => ChartDataItem.fromJson(item))
          .toList(),
      ageDistribution: (json['age_distribution'] as List)
          .map((item) => ChartDataItem.fromJson(item))
          .toList(),
      diabetesDistribution: (json['diabetes_distribution'] as List)
          .map((item) => ChartDataItem.fromJson(item))
          .toList(),
      readmissionDistribution: (json['readmission_distribution'] as List)
          .map((item) => ChartDataItem.fromJson(item))
          .toList(),
      hospitalStayDistribution: (json['hospital_stay_distribution'] as List)
          .map((item) => ChartDataItem.fromJson(item))
          .toList(),
      medicationDistribution: (json['medication_distribution'] as List)
          .map((item) => ChartDataItem.fromJson(item))
          .toList(),
      raceDistribution: (json['race_distribution'] as List)
          .map((item) => ChartDataItem.fromJson(item))
          .toList(),
      procedureDistribution: (json['procedure_distribution'] as List)
          .map((item) => ChartDataItem.fromJson(item))
          .toList(),
      diagnosisDistribution: (json['diagnosis_distribution'] as List)
          .map((item) => ChartDataItem.fromJson(item))
          .toList(),
      monthlyAdmissions: (json['monthly_admissions'] as List)
          .map((item) => ChartDataItem.fromJson(item))
          .toList(),
    );
  }
}

/// Complete Analytics Model
class PatientAnalytics {
  final AnalyticsKPIs kpis;
  final AnalyticsCharts charts;

  PatientAnalytics({
    required this.kpis,
    required this.charts,
  });

  factory PatientAnalytics.fromJson(Map<String, dynamic> json) {
    final analytics = json['analytics'];
    return PatientAnalytics(
      kpis: AnalyticsKPIs.fromJson(analytics['kpis']),
      charts: AnalyticsCharts.fromJson(analytics['charts']),
    );
  }
}

/// API Response Models
class PatientStatsResponse {
  final int code;
  final String message;
  final PatientStats body;

  PatientStatsResponse({
    required this.code,
    required this.message,
    required this.body,
  });

  factory PatientStatsResponse.fromJson(Map<String, dynamic> json) {
    return PatientStatsResponse(
      code: json['code'],
      message: json['message'],
      body: PatientStats.fromJson(json['body']),
    );
  }
}

class PatientAnalyticsResponse {
  final int code;
  final String message;
  final PatientAnalytics body;

  PatientAnalyticsResponse({
    required this.code,
    required this.message,
    required this.body,
  });

  factory PatientAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return PatientAnalyticsResponse(
      code: json['code'],
      message: json['message'],
      body: PatientAnalytics.fromJson(json['body']),
    );
  }
}
