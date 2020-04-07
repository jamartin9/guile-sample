#include <libguile.h>

static void run_guile(int argc, char **argv){
  scm_init_guile();
  // add modules here
  scm_shell(argc, argv);
}

int main (int argc, char **argv)
{
  run_guile(argc, argv);
  return 0; /* never reached, see inner_main */
}
