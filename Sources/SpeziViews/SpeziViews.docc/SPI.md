# System Programming Interfaces

<!--
#
# This source file is part of the Stanford Spezi open-source project
#
# SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
#
# SPDX-License-Identifier: MIT
#       
-->

An overview of System Programming Interfaces (SPIs) provided by SpeziViews.

## Overview

A [System Programming Interface](https://blog.eidinger.info/system-programming-interfaces-spi-in-swift-explained) is a subset of API
that is targeted only for certain users (e.g., framework developers) and might not be necessary or useful for app development.
Therefore, these interfaces are not visible by default and need to be explicitly imported.
This article provides an overview of supported SPI provided by SpeziFoundation

### TestingSupport

The `TestingSupport` SPI provides additional interfaces that are useful for unit and UI testing.
Annotate your import statement as follows.

```swift
@_spi(TestingSupport) import SpeziViews
```

#### RuntimeConfig

[`RuntimeConfig`](https://swiftpackageindex.com/stanfordspezi/spezifoundation/documentation/spezifoundation/spi#RuntimeConfig) is provided by
[SpeziFoundation](https://swiftpackageindex.com/stanfordspezi/spezifoundation/documentation/spezifoundation) for a central place to
provide runtime configurations.

SpeziViews adds the following extensions:

- `RuntimeConfig/testingTips`: Holds `true` if the `--testTips` command line flag was supplied to indicate to always show Tips when using
    ``ConfigureTipKit``. 

