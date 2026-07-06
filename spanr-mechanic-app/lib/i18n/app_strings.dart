class AppStrings {
  final String jobList;
  final String startJob;
  final String waitingForParts;
  final String resumeWork;
  final String beforeInspection;
  final String partsReplacement;
  final String serviceNotes;
  final String afterInspection;
  final String completeJob;
  final String requestExtraWork;
  final String extraWorkTitle;
  final String description;
  final String estimatedCost;
  final String submitRequest;
  final String onHoldMessage;
  final String approved;
  final String rejected;
  final String pending;

  const AppStrings({
    required this.jobList,
    required this.startJob,
    required this.waitingForParts,
    required this.resumeWork,
    required this.beforeInspection,
    required this.partsReplacement,
    required this.serviceNotes,
    required this.afterInspection,
    required this.completeJob,
    required this.requestExtraWork,
    required this.extraWorkTitle,
    required this.description,
    required this.estimatedCost,
    required this.submitRequest,
    required this.onHoldMessage,
    required this.approved,
    required this.rejected,
    required this.pending,
  });

  static const en = AppStrings(
    jobList: 'My Jobs',
    startJob: 'Start Job',
    waitingForParts: 'Waiting for Parts',
    resumeWork: 'Resume Work',
    beforeInspection: 'Before Inspection',
    partsReplacement: 'Parts Replacement',
    serviceNotes: 'Service Notes',
    afterInspection: 'After Inspection',
    completeJob: 'Complete Job',
    requestExtraWork: 'Request Extra Work',
    extraWorkTitle: 'Request Extra Work',
    description: 'Description',
    estimatedCost: 'Estimated Cost',
    submitRequest: 'Submit Request',
    onHoldMessage: 'Order on hold — waiting for customer approval.',
    approved: 'Approved',
    rejected: 'Rejected',
    pending: 'Pending',
  );

  static const te = AppStrings(
    jobList: 'నా జాబ్‌లు',
    startJob: 'జాబ్ ప్రారంభించండి',
    waitingForParts: 'విడిభాగాల కోసం వేచి ఉంది',
    resumeWork: 'పని కొనసాగించండి',
    beforeInspection: 'ముందు తనిఖీ',
    partsReplacement: 'విడిభాగాల మార్పిడి',
    serviceNotes: 'సేవా నోట్లు',
    afterInspection: 'తర్వాత తనిఖీ',
    completeJob: 'జాబ్ పూర్తి చేయండి',
    requestExtraWork: 'అదనపు పని అభ్యర్థించండి',
    extraWorkTitle: 'అదనపు పని అభ్యర్థన',
    description: 'వివరణ',
    estimatedCost: 'అంచనా ధర',
    submitRequest: 'అభ్యర్థన సమర్పించండి',
    onHoldMessage: 'ఆర్డర్ హోల్డ్‌లో ఉంది — కస్టమర్ అనుమతి కోసం వేచి ఉంది.',
    approved: 'ఆమోదించబడింది',
    rejected: 'తిరస్కరించబడింది',
    pending: 'పెండింగ్',
  );

  static const ta = AppStrings(
    jobList: 'என் வேலைகள்',
    startJob: 'வேலையை தொடங்கு',
    waitingForParts: 'உதிரிபாகங்களுக்காக காத்திருக்கிறோம்',
    resumeWork: 'வேலையை தொடர்',
    beforeInspection: 'முன் ஆய்வு',
    partsReplacement: 'பாகங்கள் மாற்றல்',
    serviceNotes: 'சேவை குறிப்புகள்',
    afterInspection: 'பின் ஆய்வு',
    completeJob: 'வேலையை முடி',
    requestExtraWork: 'கூடுதல் வேலை கோரிக்கை',
    extraWorkTitle: 'கூடுதல் வேலை கோரிக்கை',
    description: 'விளக்கம்',
    estimatedCost: 'மதிப்பிடப்பட்ட செலவு',
    submitRequest: 'கோரிக்கையை சமர்ப்பி',
    onHoldMessage: 'ஆர்டர் நிறுத்தி வைக்கப்பட்டுள்ளது — வாடிக்கையாளர் அனுமதிக்காக காத்திருக்கிறோம்.',
    approved: 'அங்கீகரிக்கப்பட்டது',
    rejected: 'நிராகரிக்கப்பட்டது',
    pending: 'நிலுவையில் உள்ளது',
  );

  static const kn = AppStrings(
    jobList: 'ನನ್ನ ಕೆಲಸಗಳು',
    startJob: 'ಕೆಲಸ ಪ್ರಾರಂಭಿಸಿ',
    waitingForParts: 'ಬಿಡಿಭಾಗಗಳಿಗಾಗಿ ಕಾಯುತ್ತಿದ್ದೇವೆ',
    resumeWork: 'ಕೆಲಸ ಮುಂದುವರಿಸಿ',
    beforeInspection: 'ಮೊದಲು ತಪಾಸಣೆ',
    partsReplacement: 'ಬಿಡಿಭಾಗ ಬದಲಾವಣೆ',
    serviceNotes: 'ಸೇವಾ ಟಿಪ್ಪಣಿಗಳು',
    afterInspection: 'ನಂತರ ತಪಾಸಣೆ',
    completeJob: 'ಕೆಲಸ ಪೂರ್ಣಗೊಳಿಸಿ',
    requestExtraWork: 'ಹೆಚ್ಚುವರಿ ಕೆಲಸ ವಿನಂತಿ',
    extraWorkTitle: 'ಹೆಚ್ಚುವರಿ ಕೆಲಸ ವಿನಂತಿ',
    description: 'ವಿವರಣೆ',
    estimatedCost: 'ಅಂದಾಜು ವೆಚ್ಚ',
    submitRequest: 'ವಿನಂತಿ ಸಲ್ಲಿಸಿ',
    onHoldMessage: 'ಆರ್ಡರ್ ಹಿಡಿದಿಡಲಾಗಿದೆ — ಗ್ರಾಹಕರ ಅನುಮೋದನೆಗಾಗಿ ಕಾಯುತ್ತಿದ್ದೇವೆ.',
    approved: 'ಅನುಮೋದಿಸಲಾಗಿದೆ',
    rejected: 'ತಿರಸ್ಕರಿಸಲಾಗಿದೆ',
    pending: 'ಬಾಕಿ ಇದೆ',
  );

  static AppStrings of(String locale) {
    switch (locale) {
      case 'te':
        return te;
      case 'ta':
        return ta;
      case 'kn':
        return kn;
      default:
        return en;
    }
  }
}
