# circleci-orb
Orb repo for circleCI

## Creating and updating apprl orbs

### Create orb
[Quick guide](https://github.com/CircleCI-Public/config-preview-sdk/blob/master/docs/orbs-authoring.md#quick-start)
 1. `circleci namespace create apprl github apprl` (only run once, apprl namespace is already created)
 2. `circleci orb create apprl/apprl-circleci-tools` (Change apprl-circleci-tools to the orb you are creating)

### Publish/update
`Create a dev release`
```
circleci orb publish orb/apprl-circleci-tools/orb.yml apprl/apprl-circleci-tools@dev:first
```

`Create first published version`
```
circleci orb publish promote apprl/apprl-circleci-tools@dev:first major
```

`Increment a release`
```
circleci orb increment promote apprl/apprl-circleci-tools@dev:first [major|minor|patch]
```

### circleCI Orbs
 - https://circleci.com/orbs/registry/
 - https://github.com/CircleCI-Public/config-preview-sdk/blob/master/docs/orbs-authoring.md
 - https://circleci.com/docs/2.0/configuration-reference/#orbs-requires-version-21
 - https://circleci.com/docs/2.0/jobs-steps/#section=getting-started
