/// Authentication seam. The static implementation checks a fixed credential
/// pair today; a future API-backed implementation swaps in behind this
/// interface with no change to callers.
abstract class AuthService {
  Future<bool> signIn(String username, String password);
}
