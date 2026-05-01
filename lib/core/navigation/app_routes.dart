abstract final class AppRoutes {
  static const home = '/';
  static const createSituation = '/create/situation';
  static const createThoughts = '/create/thoughts';
  static const createBody = '/create/body';
  static const createConsequences = '/create/consequences';
  static const createWithoutProblem = '/create/without-problem';
  static const editEntry = '/entry';
  static const instructions = '/instructions';

  static String editEntryPath(String id) => '$editEntry/$id';
}
