Hooks directory
===============

Place any script/hook (synchronization, sanity check...) that you want
travis to run after a commit. The hooks are run in alphanumeric order, so
it is a good practice to prefix them with XX_, where XX is a number such
as 00, 01, 02, etc. Please use a meaningful name. Please note that you
need to make your script executable (chmod +x), otherwise it will be
ignored. Your hook will run from the root of the project, invoked by the
master hook ./hooks/all. It will be invoked as:

   ./hooks/XX_myhook
