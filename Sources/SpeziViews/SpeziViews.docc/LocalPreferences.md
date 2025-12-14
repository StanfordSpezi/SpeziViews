# Local Preferences

<!--
#
# This source file is part of the Stanford Spezi open-source project
#
# SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
#
# SPDX-License-Identifier: MIT
#       
-->

Persist data using the `UserDefaults` APIs. 


## Overview

The ``LocalPreferenceKey`` type is used to identify individual entries in a ``LocalPreferencesStore`` (which is a wrapper around a `UserDefaults` store),
and to define how an entry's value should be encoded and decoded.
The ``LocalPreferenceKey`` additionally associates each entry with its Swift type.

``LocalPreferencesStore`` supports the following types:
- anything that conforms to the ``HasDirectUserDefaultsSupport`` protocol (e.g., `Int`, `Bool`, `String`, `Double`, `Float`, `Date`, `Data`, `URL`, etc)
- anything that is `RawRepresentable`
- anything that is `Codable`
- `Optional` values of the above

You define a ``LocalPreferenceKey`` by placing it as a static property into the ``LocalPreferenceKeys`` type:
```swift
extension LocalPreferenceKeys {
    static let prefersLargeText = LocalPreferenceKey<Bool>("largeText", default: false)
}
```

You can then use this key to interact with the ``LocalPreferencesStore``:
```swift
let store = LocalPreferencesStore.standard

// read values (if no entry exists this will return the default value)
if store[.prefersLargeText] {
    // increase text size
}

// write values
store[.prefersLargeText] = true
```

Within SwiftUI Views, you can use the ``LocalPreference`` property wrapper, similar to how you'd use SwiftUI's `AppStorage`:
```swift
@LocalPreference(.prefersLargeText) var prefersLargeText

var body: some View {
    textView
        .font(.body.scaled(by: prefersLargeText ? 2 : 1))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Toggle("Large Text", isOn: $prefersLargeText)
            }
        }
}
```
The `@LocalPreference` property will observe changes to its underlying `UserDefaults` entry and will trigger a view update if the value is changed.
This includes changes that are written using `AppStorage` or `UserDefaults`.
It is possible to use `@LocalPreference` alongside `@AppStorage`, for the same entries (see below).


### Local Preference Keys
The ``LocalPreferenceKey`` type is used to define how values for a key are stored in a ``LocalPreferencesStore``.
It keeps track of the entry's name, type, default value, and preferred storage mechanism (e.g., whether the value can directly be stored by `UserDefaults` or whether it needs to be encoded first). 

Additionally, each ``LocalPreferenceKey`` contains a ``LocalPreferenceKey/Key``, which stores the actual raw `String` key that is used when reading from or writing to the underlying `UserDefaults` store.
In order to avoid conflicts and name clashes between multiple libraries in the same app that possibly could be using the same keys, ``LocalPreferenceKey/Key`` supports namespaces, which act as a kind of scope in which the key is placed.
For example, your app would by default place all of its local preferences into its own namespace (derived from the app's bundle id); while a package you're using in your app would instead define its own namespace.

On the `UserDefaults` level, a namespace scope is simply a prefix that is prepended to the key's name.
(E.g., `Key("didRate", in: .app)` will result in the key `"com_example_MyApp:didRate"`, where `"com.example.MyApp"` is your app's bundle id.)


#### Key Format Considerations
For performance reasons when observing the `UserDefaults` for changes, keys by default are converted into a normalized form, which replaces all periods with underscores.
You can disable this behaviour by using ``LocalPreferenceKey/Key/init(verbatim:in:)``.

For keys containing periods, the ``LocalPreference`` property wrapper will still be able to observe changes (and trigger UI updates in response), but performance might be slightly worse if there are a lot of writes to other `UserDefaults` entries in your program.



### Interoperability with AppStorage
The ``LocalPreference`` property wrapper is a direct replacement for SwiftUI's `AppStorage` w.r.t. its functionality and behaviour, but there are some important differences when migrating.

The main difference between `AppStorage` and the Local Preferences API is that `AppStorage` places all entries directly into the `UserDefaults` (without scoping them), while ``LocalPreferenceKey`` by default scopes entries using the app's' bundle id.

Creating an `AppStorage` is equivalent to creating a ``LocalPreferenceKey`` that uses the global scope; e.g., the following definitions are equivalent and will access the same `UserDefaults` entry:
```swift
// in a View
@AppStorage("didRate") var didRate: Bool = false
@LocalPreference(.didRate)


extension LocalPreferenceKeys {
    static let didRate = LocalPreferenceKey<Bool>(.init("didRate", in: .none), default: false)
}
```

There is no need to do a full switch from using `@AppStorage` to using `@LocalPreference`; it is possible to use both at the same time (accessing the same entries), or do to a gradual migration:
- you can use the migration APIs (see below) to move your app's entries from the global scope into one based on your app's bundle id;
- you can simply keep the entry unscoped and tell the ``LocalPreferenceKey`` to use that (not recommended because it might lead to conflicts).

If you want to use `@AppStorage` to access a `LocalStorageKey`'s entry, simply pass the key's underlying key value to the `AppStorage` initializer:
```swift
@AppStorage(LocalPreferenceKeys.didRate.key.value)
var didRate Bool = LocalPreferenceKeys.didRate.defaultValue
```

Inversely, you can also use `@LocalPreference` to access an `@AppStorage`-defined entry (see the example above).



### Migrations
``LocalPreferencesStore`` supports migrations, allowing you to make changes to your local preferences without losing data or breaking existing code.

Migrations need to be run as early into the app's lifecycle as possibe, ideally directly in the `App`'s `init()`:
```swift
struct MyApp: App {
    // ...
    
    init() {
        let store = LocalPreferencesStore.standard
        try? store.runMigrations(
            LocalPreferencesStore.MigrateName<Date>(
                from: "dateOfBrith",
                to: "dateOfBirth"
            ),
            LocalPreferencesStore.MigrateValue(
                from: LocalPreferenceKey<Int>("rating", default: 0),
                to: LocalPreferenceKey<Double>("rating", default: 0)
            ) { (oldValue: Int) -> Double in
                Double(oldValue)
            }
        )
    }
}
```

Migrations are idempotent, meaning that once a migration has run once, any future runs will simply have no effect.
This means that you can safely have your migrations code simply run on every launch.

- Tip: You can use the migrations feature even if your app only uses `AppStorage` and does not use the ``LocalPreference`` property wrapper.


#### Name Migrations
Use ``LocalPreferencesStore/MigrateName`` to change the name (key) of an entry while keeping its value unchanged.

Name migrations will have no effect if there already exists a value for the new key, or if there exists no value for the old key.


#### Value Migrations
Use ``LocalPreferencesStore/MigrateValue`` to migrate the value of an entry into a new type.

A value migration will read the old key's value, transform it into the new value (using a user-supplied closure), and then write that into the storage, removing the old key's entry.
If no entry exists for the old key the migration will have no effect.
You can optionally also migrate the name of the key at the same time.
```swift
// migrates "token" from a base-64 String into a plain Data object
LocalPreferencesStore.MigrateValue(
    from: LocalPreferenceKey<String>("token", default: ""),
    to: LocalPreferenceKey<Data?>("token")
) { (oldValue: String) -> Data? in
    Data(base64Encoded: oldValue)
}
```



## Topics
### Types
- ``LocalPreferenceKey``
- ``LocalPreferencesStore``
- ``LocalPreference``
