# Build Scripts

This folder contains scripts to help build a release

- [Build a Release](#build-a-release)

## Build a Release

To build a release simply run the command below. It is recommended that you build a release each time before running the release.

```bash
# Change "version" for your version number
./build.sh version
```

This script does the following:
- Scrapes the `views` and `packages` folder and generate `release/all_views.sql` and `release/all_packages.sql`
- Generates a script to map some OS environment variables to SQL (`release/load_env_vars.sql`)
- Generates the install commands for all the APEX applications and stores in `release/all_apex.sql`