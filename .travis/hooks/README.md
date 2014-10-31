Hooks directory
===============

Place any script/hook (synchronization, sanity check...) that you want
travis to run after a commit.

How it works
------------

* The hooks are run in alphanumeric order, so it is a good practice to
  prefix them with XX_, where XX is a number such as 00, 01, 02, etc.
  Please use a meaningful name. 

* You need to make your hook executable (chmod +x), otherwise it will be
  ignored. 

* Your hook will run from the root of the project, invoked by the master
  hook .travis/hooks/all. It will be invoked as:


    .travis/hooks/XX_myhook

* If your hook fails (exits with a non-zero status), then the master hook
  exits immediately and the next hooks are not executed.
