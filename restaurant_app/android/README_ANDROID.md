Android notes:
- setup.sh copies google-services.json into android/app/.
- If you see build error about google services plugin, ensure android/app/build.gradle has:
  plugins { id 'com.google.gms.google-services' }
  and android/build.gradle includes classpath 'com.google.gms:google-services:4.4.2' (or compatible).
