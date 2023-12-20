<!--

This source file is part of the Stanford Spezi open-source project.

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
  
-->

# Spezi Views

[![Build and Test](https://github.com/StanfordSpezi/SpeziViews/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/StanfordSpezi/SpeziViews/actions/workflows/build-and-test.yml)
[![codecov](https://codecov.io/gh/StanfordSpezi/SpeziViews/branch/main/graph/badge.svg?token=tLnPSYE6W9)](https://codecov.io/gh/StanfordSpezi/SpeziViews)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7806475.svg)](https://doi.org/10.5281/zenodo.7806475)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordSpezi%2FSpeziViews%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/StanfordSpezi/SpeziViews)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordSpezi%2FSpeziViews%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/StanfordSpezi/SpeziViews)

A Spezi framework that provides a common set of SwiftUI views and related functionality used across the Spezi ecosystem.

## Overview

SpeziViews provides easy-to-use and easily-reusable UI components that makes the everyday life of developing Spezi applications easier.

For more information, please refer to the [API documentation](https://swiftpackageindex.com/StanfordSpezi/SpeziViews/documentation).

|![A SwiftUI alert displayed using the SpeziViews ViewState.](Sources/SpeziViews/SpeziViews.docc/Resources/ViewState.png#gh-light-mode-only) ![A SwiftUI alert displayed using the SpeziViews ViewState.](Sources/SpeziViews/SpeziViews.docc/Resources/ViewState~dark.png#gh-dark-mode-only)|![Three text fields to input your first, middle and last name.](Sources/SpeziPersonalInfo/SpeziPersonalInfo.docc/Resources/NameFields.png#gh-light-mode-only) ![Three text fields to input your first, middle and last name.](Sources/SpeziPersonalInfo/SpeziPersonalInfo.docc/Resources/NameFields~dark.png#gh-dark-mode-only)| ![Three different kinds of text fields showing validation errors in red text.](Sources/SpeziValidation/SpeziValidation.docc/Resources/Validation.png#gh-light-mode-only) ![Three different kinds of text fields showing validation errors in red text.](Sources/SpeziValidation/SpeziValidation.docc/Resources/Validation~dark.png#gh-dark-mode-only) |
|:--:|:--:|:--:|
|Easily manage view state and display erroneous state using [`ViewState`](https://swiftpackageindex.com/stanfordspezi/speziviews/documentation/speziviews/viewstate). |The [SpeziPersonalInfo](https://swiftpackageindex.com/StanfordSpezi/SpeziViews/documentation/spezipersonalinfo) provides easy to use abstractions for dealing with personal information. |Perform and visualize input validation with ease using [SpeziValidation](https://swiftpackageindex.com/StanfordSpezi/SpeziViews/documentation/spezivalidation).|

## Setup

You need to add the Spezi Account Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> [!IMPORTANT]  
> If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) to set up the core Spezi infrastructure.

## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.

## License

This project is licensed under the MIT License. See [Licenses](https://github.com/StanfordSpezi/SpeziViews/tree/main/LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/Footer.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/Footer~dark.png#gh-dark-mode-only)
