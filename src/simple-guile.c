#include <libguile.h>

static void run_guile(int argc, char **argv) {
  scm_init_guile();
  // add modules here
  scm_shell(argc, argv);
}
int main(int argc, char *argv[]) {
  if(1 == argc){ // no args include hello world script
#include "hello.scm.h"
    char ex_flag[] = {'-', 'c', '\0'}; // eval expression flag
    char *args[] = {argv[0], ex_flag, hello_scm }; // add exe name
    int argCount = sizeof(args) / sizeof(args[0]);
    run_guile(argCount, args);
  }else{
    run_guile(argc, argv);
  }
  return 0; /* never reached, see inner_main */
}
