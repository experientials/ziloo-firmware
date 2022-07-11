# Continuous Integration

GitHub Actions are used to build the firmware images which then produces artifacts.

The actions are triggered when a Hardware branch(`hw/*`) receives a push.
The actions are defined to trigger for the specific branch producing artifacts for the specific platform.


To run from a developer machine

> docker compose build builder-amd
> docker compose run builder-amd

To run with GitHub Actions the plugin is configured to link the right compose script.