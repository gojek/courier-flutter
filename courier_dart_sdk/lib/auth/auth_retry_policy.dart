abstract class AuthRetryPolicy {
  int getRetrySeconds(Exception error);
  reset();
}
