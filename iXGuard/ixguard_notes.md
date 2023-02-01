
# **iXGuard notes**

```yml
# License reference
license:
  - "ixguard-license.txt"

# ThreatCast console monitoring
monitor:
  threatcast-key: "youKeyHere"
  threatcast-appuserid-getter: "getAppUserID"
  threatcast-appuserid-size: 512

# Codesigning Details
export:
  identity: '471013249E36298********2A97C82AC833F519C'
  provisioning:
    - "comorganizationprofile_AdHoc.mobileprovision"

debug:
  verbosity: info # or debug

# Obfuscation Options
protection:
  enabled: true
  default-disabled: true
  
  names:
    enabled: true
    obfuscate-metadata: false
    strict-framework-exclusion: true
    obfuscate-symbols: true
    hide-symbols: true
    hide-swift-reflectionmd: true
    denylist:
        - "partialName"
        - "namePart"

  arithmetic-operations: # requires allowlists
    enabled: true
    allowlists:
      - level: medium
        structured-allowlist:
          interfaces:
            - name: ".*"
              instancemethods:
                - name: "foo"
        allowlist:
          - "foo.*"
          - "bar.*"
      - level: high
        allowlist:
          - "PasswordDecryptionFn"

  control-flow: 
    enabled: true

    logic: # requires allowlists
      enabled: true
      allowlists:
        - level: medium
        allowlist:
          - "foo.*"

    calls:
      enabled: true
      denylist:
        - "methodName"
        - "methodNameWithArgumentOne:AndTwo:"

  data: # requires allowlists
    enabled: true
    denylist:
      - "_objc_.*"
    allowlist:
      - "license(.*)"
      - "(.*)key"
      - "any other strings / tokens used in the app"

  code-integrity:
    enabled: true
    
    functions:
      enabled: true
      prologues: true
      symbol-table: true
      callback: "iXGuardCallback"
      continue-on-callback: true
      aggressiveness: min
      allowlist:
        - "someMethod"
        - ".*+[Foo load].*"
      denylist:
        - "prepareService.*"

    objc-calls:
      enabled: true
      denylist:
        - "partialMethodName"
      
    system-library:
      enabled: true
      aggressiveness: min
      callback: "iXGuardCallback"
      continue-on-callback: true
      denylist:
        - "prepareService.*"

    tracing:
      enabled: true
      memory-check: true
      callback: "iXGuardCallback"
      continue-on-callback: true
      denylist:
        - "prepareService.*"

  app-integrity:
    enabled: true
    signing-info: true
    loaded-libraries: true
    macho-fields: true
    callback: "iXGuardCallback"
    continue-on-callback: true

  environment-integrity:
    enabled: true
    
    jailbreak:
      enabled: true
      callback: "iXGuardCallback"
      continue-on-callback: true
      
    debugger:
      enabled: true
      callback: "iXGuardCallback"
      continue-on-callback: true

  resources:  # requires allowlist
    enabled: true
    asset-catalog: false
    allowlist:
      - 'secrets.plist'
      - '.*.yml' # all yml files
      - 'myAssets/image.png' # or '.*image.png'
      - '.*config.json'
    allowlist-direct-access: # more efficient (fast) decryption
      - 'offline-model.json'
    denylist:
      - 'unecrypted.txt'
```




## iXGuardCallback function

Notes: 
  - Add the ixguard_context.h (requires bridging header for swift)
  - The callback function is called unpredictably, multiple times by any thread. So make sure, in some cases, any ui changes or server calls to happen once.

```swift
@_cdecl("iXGuardCallback")
public func myIxguardCallbackFunc(context: UnsafePointer<IXGCallbackContext>) {
    switch context.pointee.eventType {
    case IXG_ENV_JAILBREAK:
        NSLog("Jailbroken device")
    case IXG_ENV_DEBUGGER:
        NSLog("Debugger present")
    case IXG_APP_SIGNATURE:
        NSLog("App resigned")
    case IXG_APP_LOADED_LIBRARIES:
        NSLog("Loaded libraries don't match")
    case IXG_APP_MACHO:
        NSLog("MachO file modified")
    case IXG_CODE_PROLOGUE:
        NSLog("Inline hooking detected") // \(context.pointee.codeIntegrity.pointee.guardedFunction)")
    case IXG_CODE_SYMBOL_TABLE:
        NSLog("Rebinding detected") // \(context.pointee.codeIntegrity.pointee.guardedFunction)")
    case IXG_CODE_SYSTEM_LIB: // called when jailbreak as well
        NSLog("SYSTEM_LIB")
    case IXG_CODE_TRACING:
        NSLog("Tracing detected")
    default: 
        NSLog("App integrity compromized")
    }
}
```

## iXGuardCallback get user id for Threatcast

```swift
@_cdecl("getAppUserID")
public func iXGuardUserIdGetter(buffer: UnsafeMutablePointer<Int8>, size: Int32) {
    let userId = "some_user_id"
    _ = userId.withCString {
        strncpy(buffer, $0, Int(size))
    }
}
```


## Instructions

- folder with the distribution .ipa 
  - exported with the same bundleId as the one specified in the ixguard-license.txt 
  - with bitcode and stripped swift symbols

- add the ixguard-license.txt file in the folder

- generate the default ixguard.yml and the obfuscated.ipa (and some other files):
  ```bash
  $ ixguard -o Obfuscated.ipa MyOriginalApp.ipa
  ```

- alternatively generate obfuscated ipa with an already created ixguard.yml (if not in the same folder, modify the path in the terminal `ixguard.yml`)
  ```bash  
  $ ixguard -config ixguard.yml -o Obfuscated.ipa MyOriginalApp.ipa
  ```

- find the correct identity to sign the obfuscated ipa (*note*: cannot test with a distribution bundleId. Instead, use an adhoc bundleId)
  ```bash
  $ xcrun security find-identity -v -p codesigning
  ```

- Selecting Xcode Version:
  - To view the currently selected Xcode version
  ```bash
  $ xcode-select --print-path
  ```
  - Selecting a different Xcode version
  ```bash
  $ sudo xcode-select --switch /path/to/Xcode.app
  ```
  
- Guardsquare does not provide older ixguard executables/installers so you might not want to delete any downloaded ones


## Xcode 14

- IXGuard requires bitcode embedded in the product and its dependencies to apply protections.
- Dependencies that do not contain bitcode cannot be protected by iXGuard. 
- iXGuard requires you to have bitcode enabled in the original IPA. However, the protected IPA **does not contain any bitcode**
- Bitcode is now deprecated. Starting with Xcode 14, bitcode is no longer required for watchOS and tvOS applications, and the **App Store no longer accepts bitcode** submissions from Xcode 14
- The below were tested with Xcode 14 and 14.2, and iguard 4.6.12

### In Xcode:
Xcode > Toolchains > iXGuard Toolchain

### With fastlane:
```bash
toolchain: "com.guardsquare. ixguard"
```
or
```bash
xcargs: "TOOLCHAINS= 'com .guardsquare.ixguard'"
```

### Post-action:
edit scheme > archive > Post-actions > + New script
```bash
# https://customers.guardsquare.com/manual/ixguard/stable/latest/in-depth/bitcode-xcode-14-workflow.html
# When using the iGuard toolchain for archiving with bitcode, run this to enable the AppStore export option
~/Library/Developer/Toolchains/ixguard.xctoolchain/ixguard-process-xcarchive
```


## Notes on the config

- Without enabling `continue-on-callback` for a specific RASP check, it crashes when encountering one
- Swift Compiler - General > Reflection Metadata Level > None (otherwise it crashes unless `obfuscate-metadata: false` in the ixguard.yml)
- Aggressiveness levels: min, low, medium, high, max
- Sign with adhoc provisioning profile to test and resign with app store provisioning to publish
- By default it will always try to find and use the ixguard-license.txt or the provisioning file in the current working directory
- Obfuscating the `asset-catalog` might cause a black screen instead of the launchscreen image and no icons in the app's quick actions (by long-pressing the app icon)
- RASP checks might slow the app (especially when launching) even when set to minimum aggressiveness



## Verify

- Resources:
  1. `.ipa` to `.zip`
  2. AppExtractedFolder > Payload > app (right click) > Show package contents 
  3. Search the related files if they are readable or obfuscated

- RASP - Callbacks:
  1. Window > Devices and simulators > YourDevice > + (Add installed app) > YourObfuscated.ipa
  2. Open Console (NSLogs are printed here as well as other logs or crash reports)
  3. View Device Logs (symbolicated crash reports)

- Obfuscation:
  - `Hopper` or `machOView` - Disassemblers (GUI-tools)
  - 1, 2 steps from resources > Open the executable with a disassembler app
    - With bitcode enabled when exporting the ipa, Apple made a good job and there is almost no improvement.

- Testing iXGuard on a simulator:
  This is not applicable to app developers. Simulators work on a different architecture compared to real iOS devices. This would mean you need to obtain obfuscated simulator slices and use these in the simulator. Testing these simulator slices does not guarantee that you will see the same results on a real device, in other words you still need to test on a real device. Also obfuscating the simulator slice would be unnecessary work as these simulator slices are never sent to anyone assuming the product you develop is an app and not an SDK.



## Crash reports from console

To symbolicate the crash and find the function and line in Xcode that causes it:
```bash
$ atos -arch <BinaryArchitecture> -o <PathToDSYMFile>/Contents/Resources/DWARF/<BinaryName>  -l <LoadAddress> <AddressesToSymbolicate>
```

![Symbolicate crash](https://github.com/nicolaouG/iOS_miscellaneous/blob/main/iXGuard/symbolicate_crash.png "Symbolicate crash")


