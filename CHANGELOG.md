# Changelog

## 1.0.0 (2026-09-07)


### Features

* **/lib/core/services:** implement local backup engine and drive sync in ackup_service.dart ([96ed0dc](https://github.com/qgithaka/clod/commit/96ed0dc144bb8aeb29d74f287d93693df0dedf46))
* **`/`:** add app icons and native splash screens in `pubspec.yaml` ([4a96b1a](https://github.com/qgithaka/clod/commit/4a96b1a37fc05cd872fc00f7117fca18e762eeec))
* **`analytics_repository.dart`:** implement Dashboard Metrics and P&L engine ([99a56fb](https://github.com/qgithaka/clod/commit/99a56fb3dedca3754f572c401fbcd5a90c10c9de))
* **`app_database.dart`:** initialize drift database instance ([7a8f94d](https://github.com/qgithaka/clod/commit/7a8f94d0a71c5280617f47e507a8d89256aad41e))
* **`back_office_view.dart`:** implement purchase orders, shrinkage, and expense tracking ([e6c2f22](https://github.com/qgithaka/clod/commit/e6c2f228cb487152dbc9936284320b3f5e9e0dbc))
* **`business_profile_repository.dart`:** implement profile repo and providers ([f7b728e](https://github.com/qgithaka/clod/commit/f7b728ed2141123c2ca18ceaa81fbe451c2cf11b))
* **`business_profile_view.dart`:** build business profile config screen ([e96d3d7](https://github.com/qgithaka/clod/commit/e96d3d7bd4070ccaf6da3aa02dc62cf797197780))
* **`cart_provider.dart`:** implement in-memory POS cart state management ([93fdb79](https://github.com/qgithaka/clod/commit/93fdb7915221da82b718f28821b471cdd4bfbd7f))
* **`catalogue_view.dart`:** build catalogue list and item form screens ([c9693fe](https://github.com/qgithaka/clod/commit/c9693fef87b43f5250f7b3c4d3c4f2de7a30acd1))
* **`credit_statement_service.dart`:** implement dynamic pdf statement generation ([13a0613](https://github.com/qgithaka/clod/commit/13a0613e09a0e246d8ea7f6c2a332bb205328485))
* **`customer_detail_view.dart`:** build detail screen and repayment flow ([e95fe7c](https://github.com/qgithaka/clod/commit/e95fe7c273dbd38172b648434dad2b825e747284))
* **`customer_repository.dart`:** implement customer domain and repo ([ae4fc77](https://github.com/qgithaka/clod/commit/ae4fc77cef12005bfd2c9cbd4b8399f15c6112f3))
* **`customers_view.dart`:** build customer directory UI ([7a98ada](https://github.com/qgithaka/clod/commit/7a98adaf89540225532fbcea6b288d8936293ffb))
* **`daos.dart`:** implement drift daos with streams and crud ([239be81](https://github.com/qgithaka/clod/commit/239be81370840bc87dda6dfe525fdedd4fde4fb6))
* **`dashboard_view.dart`:** build credit ledger dashboard ([82cc141](https://github.com/qgithaka/clod/commit/82cc1416c05f3bf3bc08d6afbb53fb5f766273f7))
* **`document_list_view.dart`:** implement Quotes and Invoices with PDF generation ([2a8d987](https://github.com/qgithaka/clod/commit/2a8d987912a4bc3bada2846ca5fbeae81b2c252d))
* **`file_storage_service.dart`:** implement logo storage service ([b679a6a](https://github.com/qgithaka/clod/commit/b679a6ad3a3ec30c95bce67243beccbbf58e4cba))
* **`item_entity.dart`:** implement item domain model and repository ([de314b6](https://github.com/qgithaka/clod/commit/de314b6bd164716224294b2b8e9e3efd1b89a9df))
* **`money.dart`:** create integer-cents money utility ([dc9d0db](https://github.com/qgithaka/clod/commit/dc9d0dbfbdc7423c2a8b39faf7b171298b513bd0))
* **`pos_view.dart`:** implement POS checkout flow and receipt generation ([413bd60](https://github.com/qgithaka/clod/commit/413bd60526f4666f70d0d5be76220a95570a0b3b))
* **`pubspec.yaml`:** add core dependencies for m00 ([f9f5a05](https://github.com/qgithaka/clod/commit/f9f5a050331d1851d8700e70209331de70e9c27a))
* **`responsive_shell.dart`:** implement responsive shell layout ([53922f3](https://github.com/qgithaka/clod/commit/53922f31cee492654a24e63434cb7c0b2b832e1f))
* **`router.dart`:** configure go_router with placeholder views ([013a8f5](https://github.com/qgithaka/clod/commit/013a8f50f468db65fa92f7ec2405623c9ede26be))
* **`tables.dart`:** define complete sqlite schema via drift ([57a7a5f](https://github.com/qgithaka/clod/commit/57a7a5f51f0614b4518c4120942d9094b6a62bfa))
* **`theme.dart`:** configure high-contrast material 3 theme ([72441c2](https://github.com/qgithaka/clod/commit/72441c257a18f3842188e91238db5a882cd32194))


### Bug Fixes

* **\lib/presentation/shell\:** resolve NavigationRail layout assertion in  ([3bb0002](https://github.com/qgithaka/clod/commit/3bb000241971a15b1e6d9e9fa86c8cdf6072c597))
* **`lib`:** resolve all flutter analyze warnings and infos ([3298f6f](https://github.com/qgithaka/clod/commit/3298f6fcc58c084fb27bc258d8667104dfe013f3))
* resolve lint warnings and missing dependency ([dedfaf3](https://github.com/qgithaka/clod/commit/dedfaf32e280ddd422b6a1cbb2d27d3e1d2aa7c3))


### Performance Improvements

* **`/lib/data/database`:** add drift SQLite indices in `tables.dart` ([beb6210](https://github.com/qgithaka/clod/commit/beb6210af7d4816196016c8532a1e2ac626b96de))
