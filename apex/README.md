# APEX Applications

By default the build script included in this project will do some "extra" things for your APEX applications. 

- [App Version](#app-version)


## App Version

Every APEX application has version attribute which is stored in `Application Properties > Version`. By default it's set to `Release 1.0` and shows up in the bottom left footer of your application. Manually changing this value for each release can be cumbersome and error prone. Instead use `%RELEASE_VERSION%` in the `Version` attribute and `%RELEASE_VERSION%` will be replaced automatically with your build version.

For example set the `Version` to `Release %RELEASE_VERSION%` and when you "build" version `2.0.0` it will show up as `Release 2.0.0` in your application.

