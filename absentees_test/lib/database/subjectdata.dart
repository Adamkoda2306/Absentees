class SubjectList {
  // Define a Map to store subjects based on UG and semester
  final Map<String, Map<int, List<String>>> subjects = {
    'ECE': {
      1: ['CP', 'DSMA', 'DLD', 'OCW', 'FHVE', 'EE/EEN'],
      2: ['DSA', 'PS', 'BEC', 'SS', 'OPC', 'EEN/CC'],
      3: ['OOPS', 'RANAC', 'ES', 'CS', 'CNA', 'PC'],
      4: ['CCN', 'FCOMM', 'EMTL', 'AC', 'ACS', 'QIC/IE/SE/PGP'],
    },
    'CSE': {
      1: ['CP', 'DSMA', 'DLD', 'OCW', 'FHVE', 'EE/EEN'],
      2: ['DSA', 'PS', 'SS', 'CA', 'OPC', 'EEN/CC'],
      3: ['OOPS', 'RANAC', 'ADSA', 'DBMS', 'OS', 'PC'],
      4: ['CCN', 'FFSD', 'TOC', 'AI', 'ACS', 'QIC/IE/SE/PGP'],
    },
    'AIDS': {
      1: ['CP', 'DSMA', 'DLD', 'OCW', 'FHVE', 'EE/EEN'],
      2: ['DSA', 'PS', 'SS', 'CA', 'OPC', 'EEN/CC'],
      3: ['OOPS', 'RANAC', 'ADSA', 'DBMS', 'ML', 'PC'],
      4: ['CCN', 'DL', 'IDA', 'AIKR', 'ACS', 'QIC/IE/SE/PGP'],
    }
  };

  // Method to get subject names based on branch and semester
  List<String> getSubjects(String branch, int semester) {
    if (subjects.containsKey(branch) &&
        subjects[branch]!.containsKey(semester)) {
      return subjects[branch]![semester]!;
    } else {
      return ['No subjects found for the given branch and semester.'];
    }
  }
}
