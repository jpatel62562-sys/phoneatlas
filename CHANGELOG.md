## 0.1.0

- Initial production-quality release of `phoneatlas`.
- Support for 245+ countries and territories with ISO 3166-1 alpha-2 codes.
- International dialing codes and Unicode regional indicator flag emojis.
- Authoritative phone number validation powered by Google libphonenumber metadata ecosystem.
- As-you-type national phone number formatting with intelligent cursor position maintenance.
- Flutter `Form` integration with `PhoneAtlasField` and validation hooks (`PhoneValidator`).
- Reusable country picker modal bottom sheet and dialog with instant search and lazy list rendering (`ListView.builder`).
- Immutable `Country` and `PhoneNumberValue` models with E.164 output.
- Two-way binding and programmatic manipulation via `PhoneAtlasController`.
- Accessibility support with descriptive semantic labels and touch target sizes.
- Light and dark theme compatibility with Material 3 design tokens.
- Reproducible metadata generation script in `tool/generate_phone_metadata.dart`.
- Complete interactive example application in `example/`.
