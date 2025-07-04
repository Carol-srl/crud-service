# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- bug that prevented partial index to be updated at startup
- improved `_rawp` filtering logic to extend support for variable fields containing numbers

## 7.2.3 - 2025-03-10

### Changed

- overhauled Mongo view update logic to avoid requesting [`dropCollection`](https://www.mongodb.com/docs/manual/reference/privilege-actions/#mongodb-authaction-dropCollection) privilege action
- introduce abort controller to NodeJS stream pipeline to ensure the pipeline object is cleaned up when the response stream is destroyed

### Fixed

- prevent a memory leak the service was experiencing when it was not able to fulfill incoming requests
- corrected a typo in option `maxIdleTimeMS` within Mongo client configuration, which prevented the environment variable `MONGODB_MAX_IDLE_TIME_MS` to take effect

## 7.2.2 - 2024-12-13

### Changed

- updated service dependencies
- upgrade NodeJS version in Docker image to v22.12.0

### CI

- added step for generating SBOM (Software Bill of Materials)
- added step for scanning the built image

## 7.2.1 - 2024-10-08

### Fixed

- improve how query parser discriminates update _operator modifiers_ (e.g. `$each`) from actual record value
- introduce support for `$eq` operator also for integer fields (the ones defined in nested array and objects)

## 7.2.0 - 2024-09-23

### Added

- introduce support for Array of ObjectIds at document root level
- introduce support for `$size` operator in `_q` for fields of type `array`

### Fixed

- resolved a regression introduced starting from v7, where the pod would remain running despite index creation errors; now, the service does not start in case it encounters an error creating an index, providing a log describing the issue
- enable bom stripping when importing CSV files
- change CSV _escape_ character to align it with CSV field _quote_ character, as recommended by [RFC 4180](https://datatracker.ietf.org/doc/html/rfc4180)

## 7.1.1 - 2024-08-29

### Changed

- extend to `/bulk` endpoint the requests preprocessing performed on exposed routes of View with lookup feature enabled

## 7.1.0 - 2024-08-26

### Added

- new optional environment variable `CRYPT_SHARED_LIB_PATH` that specify
where `crypt_shared` MongoDB dynamic library is located. This variable
is already set within the Docker image and it points to the correct location, so that it is not necessary to customize it.

### Changed

- replace `mongocryptd` libraries with Mongo `crypt_shared`
- upgrade NodeJS version in Docker image to v20.17.0
- enforce quoting all strings in CSV export to prevent issues with delimiter character

### Fixed

- when the service was configured to run with the (CSFLE)[https://www.mongodb.com/docs/manual/core/csfle/] feature enabled and a Mongo View was defined alongside the collections models, the service crashed at startup due to an incompatibility between Mongo Views and the auto-encryption feature.  
This issue has been resolved and the service can now properly start, creating the Mongo Views even in such situation.

## 7.0.4 - 2024-06-28

### Fixed

- bug that made compilers collide with collections having the same prefix.

## 7.0.3 - 2024-06-20

### Changed

- hooks and serializer compiler are not registered anymore on every `httpInterface.js`, but only once in `index.js`, to avoid multiple registers for collections;
- validator compiler is still applied to each HTTP interface to avoid OOM, but it has been moved to `compilers.js`;
- `AdditionalCaster` class does not need to compute the fields that are either `ObjectId`, `Date`, or `Geopoint`: in the new `castItem` method, field types are inferred with the `instanceof` keyword;
- upgrade NodeJS version in Docker image to v20.14.0
- added `await` keyword when registering Fastify plugins

### Fixed

- fixed projection example in json schema generator
- `serializerCompiler` has been added to use explicitly [`fastifiy-fast-json`](https://github.com/fastify/fast-json-stringify), along with `AdditionalCaster`  
- `$eq` operator can now be used also for array fields
- [#286](https://github.com/mia-platform/crud-service/issues/286): `/-/schemas` accept header defaults to `application/json`
- [#326](https://github.com/mia-platform/crud-service/issues/326): `/schemas` and `/-/schemas` endpoints now return also `required` property

## 7.0.2 - 2024-05-06

### Added

- added `_exportOpts` query parameter for `GET /export` calls

### Fixed 

- fixed `GET /export` with `csv` format: `csv` files contain all the requested fields as columns without omissions
- fixed `GET /export` with `excel` format: `excel` files contain all the requested fields as columns instead of containing always all the collection fields
- allow running raw queries with `_q` over fields containing a digit in their name

## 7.0.1 - 2024-04-08

### Added

- `OPEN_API_SPECIFICATION` env to choose specification used for exposing Swagger

### Changed

- improve internal logic bulk `POST` and `PATCH` operations

## 7.0.0 - 2024-02-01

### BREAKING CHANGES

- [#189](https://github.com/mia-platform/crud-service/pull/189) introduce support to MongoDB v7.0 and remove support to MongoDB v4.2
- [#140](https://github.com/mia-platform/crud-service/pull/140) changed response code on unique constraint violation with respect to [mia-platform/#175](https://github.com/mia-platform/community/discussions/175)
- [#53](https://github.com/mia-platform/crud-service/issues/53) request to transition to a disallowed state now returns HTTP error 400 instead of 404
- [#55](https://github.com/mia-platform/crud-service/issues/55) additional query \_q now return _400 Bad Request_ in case a field is not included in the collection definition schema
- [#144](https://github.com/mia-platform/crud-service/pull/144) method `GET /:id` returns document containing only fields defined in the JSON Schema of the collection

### Added

- [#236](https://github.com/mia-platform/crud-service/issues/236) added `defaultSorting` field to collection definition: the field applies a sorting object document to find queries, if no explicit `_s` parameter is set on request 

### Changed

- remove `additionalProperties` constraints from collection definition schema to allow greater flexibility in adding further config entries
- updated NodeJS version in Dockerfile to v20.11.0
- updated `@fastify/mongodb` to v8.0.0
- updated `@fastify/multipart` to v8.0.0

## 6.10.4 - 2024-12-13

### CI

- added step for generating SBOM (Software Bill of Materials)
- added step for scanning the built image

## 6.10.3 - 2024-06-06

### Changed

- downgrade debian image to bullseye, aligning the behavior of the service with that prior to v6.10.1.

## 6.10.2 - 2024-06-06

### Changed

- upgrade NodeJS version in Docker image to v20.14.0

## 6.10.1 - 2024-05-17

### Fixed

- fixed projection example in json schema generator

## 6.10.0 - 2024-02-01

### Added

- introduce new query parameter `_useEstimate` on `GET /count` request. In this manner the endpoint employs the `estimatedDocumentCount`
method of MongoDB, returning the number of documents from the collection metadata
- added `/-/schemas` and `/<collection>/schema` routes to discover/inspect the data models' of each collection as JSON schema

### Fixed

- [#237](https://github.com/mia-platform/crud-service/issues/237): casting values in `_q` queries are now executed even in case of nested fields

## 6.9.6 - 2024-01-23

### Fixed

- improved excel export to ensure column consistency

## 6.9.5 - 2024-01-19

### Added

- [#247](https://github.com/mia-platform/crud-service/pull/247): `xls` and `xlsx` export formats

### Changed

- updated service dependencies
- updated NodeJS version in Dockerfile to v18.19.0

## 6.9.4 - 2023-11-22

### Added

- [#225](https://github.com/mia-platform/crud-service/pull/225): `MONGODB_MAX_IDLE_TIME_MS` env to control MongoDB `maxIdleTimeMs` connection option (default set to 0 for backward compatibility, meaning the opened connection remain opened indefinitely)

### Fixed

- [#227](https://github.com/mia-platform/crud-service/pull/227): create indexes limiting promises concurrency to prevent connection creation spikes at boot

## 6.9.3 - 2023-11-21

### Changed

- review writable views to introduce a proper support of multi-lookup references (_one-to-many relationship_), addressing the point raised in this [discussion](https://github.com/mia-platform/community/discussions/328)
- rewritten writable views documentation to clarify their motivation and configuration

## 6.9.2 - 2023-10-25

### Fixed

- add optional chaining to allow not to specify `pipeline` field in `$lookup` views when `enabledLookup` is set

### Changed

- upgrade `tap` to `v18.5.2`
- updated NodeJS version in Dockerfile to v18.18.2

## 6.9.1 - 2023-09-08

### Fixed

- [#172](https://github.com/mia-platform/crud-service/issues/172) collection _export_ endpoint can now parse multiple accept header
values and select the one with the highest weight

## 6.9.0 - 2023-08-23

### Added

- [#119](https://github.com/mia-platform/crud-service/pull/119) created route to import collection files (json, ndjson and csv)
- [#137](https://github.com/mia-platform/crud-service/pull/137) export route allows different file formats (json, ndjson and csv)
- CRUD Service image is now pushed also on the internal Mia-Platform registry
- new Github Action that cleans up the cache generated by actions carried out when working on PRs

### Changed

- updated NodeJS version in Dockerfile to v18.17.1
- updated service minor and patch dependencies
- [#154](https://github.com/mia-platform/crud-service/pull/154) import route with PATCH method now does an upsert instead of a simple update

### Fixed

- [#138](https://github.com/mia-platform/crud-service/pull/138) patch import route validate the presence for the `_id` field
- [#145](https://github.com/mia-platform/crud-service/pull/145) increased get response performances

## 6.8.0 - 2023-07-11

### Added

- [#129](https://github.com/mia-platform/crud-service/pull/129) introduce the option to enable strict validation on service responses

### Fixed

- [#125](https://github.com/mia-platform/crud-service/pull/125) handled streaming error on GET / and GET /export
- [#123](https://github.com/mia-platform/crud-service/pull/123) resolved performance issues on many collections

### Added

- [mia-platform/#256](https://github.com/mia-platform/community/discussions/256) configurable collection tags.

### Fixed

- $text search query now working on aggregation
- [#158](https://github.com/mia-platform/community/discussions/158) fixed wrong validation on nested objects.
- endpoint tag format has been updated to correctly display paths with underscores

## 6.7.0 - 2023-06-19

### Added

- #92 abstraction for view writing support with the "enableLookup" flag in views configuration.

## 6.6.1 - 2023-06-15

### Fixed

- #88 dot (`.`) notation with operator `$set` is now correctly supported
- #89 operators `$addToSet` and `$pull` are now supported on properties added via `additionalProperties` JSON schema definition
- collection definition validation is now carried out only once per collection

### Changed

- update minor and patch dependencies

## 6.6.0 - 2023-06-09

### Added

- add option to enable tracing

### Changed

- upgrade lc39 to v7, which upgrade fastify to v4
- updated documentation regarding service configuration to clarify the database name in the connection string
- call to configure MongoDB are now concurrent
- JSON Schema Generator refactoring to reduce duplicated operations

### Fixed

- updated broken links in documentation
- wrong swagger configuration

## 6.5.2 - 2023-05-08

### Changed

- `__mia_configuration` property in a collection `schema` now accepts additional properties
- improved validation message for "body must NOT have additional properties" Ajv error, now it also says the unwanted property
- optimization of the `__STATE__` query sent to MongoDB: $in operator has been removed when not necessary

## 6.5.1 - 2023-04-20

### Fixed

- encryption not working with JSON Schema collection definition

## 6.5.0 - 2023-04-20

### Added

- Collections configuration files can now accept a new field `schema` which allows to define the collection data model by means of a JSON Schema.
  The property `schema` in the configuration files is an _opt-in_ feature and when defined it takes precedence over the `fields` property.  
  Though the latter property is still supported, it is recommended to convert your collections to adopt a JSON schema definition to access the new functionality offered by JSON schema.
- `$pull` operator support
- `$addToSet` supports mongo operators

### Deprecated

- Collections definition via `fields` property is now considered deprecated and it will be removed in future versions.

## 6.4.0 - 2023-03-21

### Added

- Support to [$addToSet](https://www.mongodb.com/docs/manual/reference/operator/update/addToSet/) operations for array fields

### Changed

- Upgraded service libraries
- Refactored tests to further reduce their execution time and prevent tests timeouts
- Improved service documentation

## 6.3.0 - 2023-02-08

### Fixed

- .npmrc file added to .dockerignore and .gitignore

### Changed

- `README.md` improved with instructions on how to run the service in a local environment and how to configure collections and views;
- Refactored `./tests` folder to support parallel run of tests in CI pipelines
- Improved description of API methods exposed in API specification;

## 6.2.0 - 2023-01-13

### Changed

- Dockerfile: remove `crud-service-base-image` and merge its configuration into crud-service image definition
- upgrade NodeJS to `v18`
- upgrade `mongodb-enterprise-cryptd` to `v5.0.14`
- upgrade `libmongocrypt` to `v1.6.2-0`

## 6.1.4 - 2023-01-10

### Changed

- Removal of references to Mia s.r.l. internal documents, minor updates on the code for readability
- JSON definitions of MongoDB Views does not require the property `type` anymore (it will be automatically added with the `view` value)

## 6.1.3 - 2022-12-02

### Fix

- `ALLOW_DISK_USE_IN_QUERIES` supports `/count` operations

## 6.1.2 - 2022-11-24

### Fix

### Changed

- Fields stored as string are casted to number if requested by schema

## 6.1.1 - 2022-11-22

### Changed

- support for `$dateToString` project operator in `_rawp` query param.

## 6.1.0 - 2022-11-22

- The CRUD Service officially supports MongoDB v6.0. See the [official MongoDB release note](https://www.mongodb.com/docs/manual/release-notes/6.0-compatibility/) for more information.

## 6.0.2 - 2022-10-25

### Added

- Add new environment variable `ALLOW_DISK_USE_IN_QUERIES` to set `allowDiskUse` option in MongoDB queries, useful when working with MongoDB Views (works with MongoDB >= 4.4).

## 6.0.1 - 2022-10-06

### Added

- Added header `json-query-params-encoding` for the json query params encoding.

### Deprecated

- the header `json_query_params_encoding` is marked as deprecated and its support is going to be dropped in the next major release.

## 6.0.0 - 2022-09-23

### BREAKING CHANGES

- `Ajv` major upgrade to v8. Look at its [release notes](https://github.com/ajv-validator/ajv/releases/tag/v8.0.0).
- Remove multi-type definition for nullable objects, in order to favor the `nullable` property.
  The service expected behavior will be equivalent, but the API Schemas will change if compared to the previous versions.
- Refactored Partial Indexes configuration properties

### Fixed

- object `nullable` field attribute is now recognized
- array `nullable` field attribute is now recognized
- export route works also when an array field is set to null
- failing tests on Mongo encryption lib

### Changed

- Refactored Partial Indexes configuration properties, in order to be more aligned to what is displayed on the Console Frontend
- replaced deprecated `fastify-mongodb` and `fastify-env` with their respective
  namespace scoped version `@fastify/mongodb` and `fastify/env`
- remove multi-type definitions (`["<type>", "null"]`) to exploit only `nullable` attribute
  when defining that a property can be set to `null`
- replace `standard` and `snazzy` with Mia `eslint` configuration,
  refactoring code where needed to match the latest code styles
- set Fastify to use Ajv v8 compiler
- upgraded Ajv to v8, adopting its newer (and stricter) default configs.
  This required to review source code and tests according to the [migration guide](https://ajv.js.org/v6-to-v8-migration.html).
- upgraded service dependencies

### Add

- Added support for base64 encoded (json) query params to support the ODI HTTP Client
- Added support to partial indexes

## 5.4.2 - 2022-07-28

### Fixed

- Fixed $currentDate operator behavior for patchById, patchMany, patchBulk and upsertOne APIs

## 5.4.1 - 2022-07-18

- security fixes

## 5.4.0 - 2022-06-22

### Add

- Add new \_rawp's operators: $eq, $gt, $gte, $lt, $lte, $ne, $nin, $and, $not, $nor, $or, $exists, $type, $all, $elemMatch, $size, $cond, $regexMatch, $map, $mod

- Add the `CRUD_MAX_LIMIT` environment variable, for setting up the maximum limit of object per query

### Updated

- Docker Image base file @1.1.1

## 5.3.1 - 2022-05-30

### Updated

- `standard`@^17.0.0

### Fixed

- prevent query with empty object in `$and` to avoid full scan

## 5.3.0 - 2022-05-12

### Added

- sorting by nested and multiple fields

### Updated

- lc39 to v6.0.0

### Fixed

- Throw error on findAll stream error event

## 5.2.3 - 2022-05-04

### Fixed

- removed check on text indexes presence when $text operator is used, mongodb performs the check by itself

## 5.2.2 - 2022-04-22

### Fixed

- resolved a regression introduced in version 5.1.0. Now all of the endpoints of a collection are correctly exposed.

## 5.2.1 - 2022-03-30

### Fixed

- null values in `_q` query filter are correctly handled for GET endpoints

## 5.2.0 - 2022-03-29

### Added

- support for `$first` project operator in `_rawp` query param

## 5.1.0 - 2022-03-21 [Found regression in this version on date 2022-04-22]

### Added

- supports MongoDB views

## 5.0.2 - 2022-02-25

### Updated

- mongocryptd v2

## 5.0.1 - 2021-11-08

### Fixed

- added pino to dependencies
- remove async from get list handler

### Updated

- node.js to v16
- dependency pino to ^7.1.0

### Chores

- added tests and improved documentation

## 5.0.0 - 2021-10-15

### BREAKING CHANGES

This version brings Mongo breaking changes from Mongo v4.4 to v5. Specially, if you are using some query (e.g. with `_q` parameter) no more supported by new Mongo version or new driver version, it will return an error.

Known limitation in this version:

- before, it would be possible to make a count using `$nearSphere` operator. This operator is not permitted by mongo v4.4 and mongo v5, so in this version the count with this filter will throw.

### Added

- support to mongo v5.0

### Updated

- update mongo driver to use v4
- handle mongo stream error in findAll

## 4.4.0 - 2021-09-30

### Added

- Client side field level encryption

### Fixed

- Corrected JSON schema for text indexes.
- Corrected some logs that were not showing objects
- PATCH: $.merge operator on multiple nested array

## 4.3.0 - 2021-09-10

### Updated

- Upgraded `lc39` to version 5 (handled with retrocompatibility by setting swagger in order to avoid breaking changes)

### Added

- new parameter `_rawp` to perform raw projections with aggregation operators on MongoDB v4.4 or above
- error handling for `_rawp` trying to override `acl_read_columns` header
- check on not allowed operators used during `_rawp`

### Changed

- Changed base image from `node:12.22.3-alpine` to `node:14.17.6-slim`
- Installed version 4.4.8 of `mongocryptd` inside the Docker image
- Installed version 1.2.2 of `libmongocrypt` inside the Docker image
- Upgrade node version in `nvm`
- Required node engine is now v14.17.6
- Inserted `KMS` configuration variables

## 4.2.0 - 2021-08-05

### Added

- support to text search indexes (with weights and language options) and $text queries on findAll

## 4.1.0 - 2021-07-06

### Changed

- projection regex pattern is removed in order to allow the projection over nested fields.

## 4.0.0 - 2021-06-17

## 3.3.0 - 2021-06-17 [Unpublished]

### Added

- support `__STATE__` change of multiple documents using a filter and without knowing the `_id` of each one.

### Breaking Change

- installed `@mia-platform/mongodb-healthchecker` for mongo healthchecks

## 3.2.3 - 2021-04-29

### Fixed

- fix `checkNormalIndexEquality` comparison

## 3.2.2 - 2021-03-04

### Updated

- lc39 v3.3.0

## 3.2.1 - 2021-01-29

### Fixed

- patch with unset of ObjectId field no longer fails

## 3.2.0 - 2020-12-02

### Added

- support json schema for RawObject and array of RawObject field properties

## 3.1.2 - 2020-11-04

### Added

- castToObjectId allow also null value as input and return null itself.

## 3.1.1

### Updated

- lc39 v3.1.4
- Updated gitlab-ci.yml mongo dependency, from this version mongo 4.4 support is guaranteed.

## 3.1.0 - 2020-10-06

### Added

- Allow $inc, $set, $unset on sub properties of raw object

## 3.0.1 - 2020-10-02

### Update

- update lc39 to v3.1.3.

## 3.0.0 - 2020-09-29

### Update

**BREAKING CHANGE**

- lc39 to v3.1.2. The update is breaking since it's bringing up lc39 v3.x with the newer logging format.

## 2.2.0 - 2020-07-14

### Added

- Expose some metrics about collections

### Update

- lc39 to v3.1.0

## 2.1.6 - 2020-05-26

### Fixed

- Omit required if empty

## 2.1.5 - 2020-05-26

**BROKEN: do not use this version**

## 2.1.4 - 2020-04-15

### Changed

- Remove default limit from /export

## 2.1.3 - 2020-01-31

### Changed

- Update package-lock for zero-downtime
- passing `{useUnifiedTopology: false}` to fastify-mongo to avoid that isConnected() always return true

## 2.1.1 - 2019-12-16

### Fix

- fix CRUD startup with 0 collections

## 2.1.0 - 2019-12-09

### Added

- handle ttl index
- support \_id of type string

## 2.0.1 - 2019-10-16

### Fix

- Fixed missing data in **STATE** field of post and post-bulk json schema

## v2.0.0 - 2019-07-03

### BREAKING CHANGE

- Implement nullable flag.
  Before this, the nullable flag is ignored. The default behavior is to convert `null` into falsy value for the field type type.
  For example, for an integer `null` value is converted to `0`, for a string to `''` (empty string).

### Added

- Both the handlers of `/-/check-up` and `/-/healthz` route check the connection to Mongo.

## v1.2.0 (Jun 25, 2019)

### Added:

- Support for the CRUD_LIMIT_CONSTRAINT_ENABLED env variables to enable constraints on minimum,
  maximum and default values. New limits are: maximum 200, minimum 1 and default 25

## v1.1.0

Changes that have landed in master but are not yet released.

### Added:

- Support for patching array items. The `$set` command works properly on both primitive and `RawObject` item types, by using `array.$.replace` and `array.$.merge` as keys in the `$set` command object.
  This feature involves the following CRUD operations:
  - Patch by ID
  - Patch many
  - Patch bulk
- `array.$.replace` Replace entirely the query-matching array item with the content passed as value.
- `array.$.merge` Edits only the specified fields of the query-matching array item with the content passed as value.

See below for some sample cURLs for **/PATCH** _/books-endpoint/{:id}_ where `_q={"attachments.name": "John Doe", _st: "PUBLIC"}`

**Case Merge**

```
curl -X PATCH "http://crud-service:3000/books-endpoint/5cf83b600000000000000000?_q=%7B%22attachments.name%22%3A%20%22John%20Doe%22%7D&_st=PUBLIC" -H "accept: application/json" -H "Content-Type: application/json" -d "{ "$set": { "attachments.$.merge": { "name": "renamed attachment" } }}"

```

**Case Replace**

```
curl -X PATCH "http://crud-service:3000/books-endpoint/5cf83b600000000000000000?_q=%7B%22attachments.name%22%3A%20%22John%20Doe%22%7D&_st=PUBLIC" -H "accept: application/json" -H "Content-Type: application/json" -d "{ "$set": { "attachments.$.replace": { "name": "renamed attachment", content: "Lorem ipsum dolor sit amet", "state": "attached" } }}"
```
