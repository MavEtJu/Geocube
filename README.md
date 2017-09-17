# Geocube development

## Obtain the source and get it ready

    $ git clone

Install the Google Maps POD, run:

    $ pod update GoogleMaps

After that, open Geocube.xcworkspace in Xcode and under Supporting
Files, copy the file EncryptionKeysExample.plist to EncryptionKeys.plist
and populate with the information you have (Google Maps key,
Geocaching Australia API consumer, LiveAPI keys, shared secrets).
This file is not supposed to be in the SCM as it contains secret
information.

To obtain the keys: 
* Geocaching Australia key: http://geocaching.com.au/api/services/
* Google Maps key: https://developers.google.com/maps/documentation/ios-sdk/start
* Mapbox key: https://www.mapbox.com/studio/

The shared secrets are (currently only) used to hide the API keys
hidden downloaded via geocube_sites.geocube:

    <oauth_key_public sharedsecret="1">

is encoded with "shared_secret_1":

    <key>sharedsecret_1</key>
    <string>foobar</string>


Then build and run!

After you have made changes, run ./lint.sh. It will check for style
and completeness issues like configuration, localization etc.

## Developer Style Guide

### Syntax

The lint.sh shell script will check for the following:

- Every Geocube .m and .h file needs to have a license. This excludes
  the parts of the ContribLibrary ask they are not part of Geocube.

- Every license should have the current year in the Copyright statement.

- All strings in _("xxx") need to have a localized version. All
  strings in the location database should exist in the source files.

- In the DatabaseLibrary: Every DB_PREPARE needs to finish with a
  DB_FINISH to prevent locking of the database.

- Every DatabaseLibrary object db* should show up in the
  DeveloperDatabaseViewController.

- Every DatabaseLibrary object db* should have a TABLENAME defined.

- Every DatabaseLibrary object db* should be in the order:
  - init
  - finish
  - dbCount
  - dbCreate
  - dbUpdate
  - dbAllXXX
  - dbAll
  - dbGet
  - dbDelete

- No tabs in the code.
- No dangling spaces at the end.
- No spaces before a ] method closer.
- No empty lines at the end of a file.
- No empty lines after the beginning of a method.
- No double empty lines.
- No space between parent class and delegates.
- No { on the same line line of @interface.
- No { on the same line line as the method definition.
- No double ;;'s

- Method definition should have a space between -/+ and name.
- Subclassing is space-colon-space.
- Classes must have @interface (), even if empty.

- Array enumeration should have \_Nonnull before object and \*stop.
- Arrays should have their class defined.

- XIBs must be there for iPhone and iPad.

### Include block for .h files

All sections are seperated by an empty line. The order of include
files for .h files should be:

- The Cocoa headers:

    ```
    #include <Foundation/Foundation.h>
    #include <....>
    ```

- The Geocube headers:

    ```
    #include "Geocube-Defines.h"
    #include "Geocube-Globals.h"
    ```

- The Various Geocube Library enum files:

    ```
    #include "DatabaseLibrary/dbWaypoint-enum.h"
    #include "ToolsLibrary/MyTools-enum.h"
    ```

- @class statements for the classes needed in the function prototypes:

    ```
    @class dbWaypoint;
    ```

### Include block for .m files

All sections are seperated by an empty line. The order of include
files for .h files should be:

- Class definition:

    ```
    #include "FooBar.h"
    ```

- The Cocoa headers:

    ```
    #include <Foundation/Foundation.h>
    #include <....>
    ```

- The Geocube headers:

    ```
    #include "Geocube-Defines.h"
    #include "Geocube-Globals.h"
    ```

- The Various Geocube Library class files:

    ```
    #include "DatabaseLibrary/dbWaypoint.h"
    #include "ToolsLibrary/MyTools.h"
    ```

- The Various Geocube class files:

    ```
    #include "something.h"
    ```

### Global variables

Global variables are externally defined under the class prototype
in the .h file.

    @end

    extern FooBar *fooBar;

Global variables are internally defined in main.m:

    FooBar *fooBar;

For global variables which are not a class in the source code, they
are put in Geocube-Globals.h.
