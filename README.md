NOTE: We are not responsible for any trouble that may occur by using this scripts.

```bash
# on your machine

docker build . -t fetch:jmatsu
docker run --rm -v $(pwd):/usr/src  -it fetch:jmatsu /bin/bash

# in docker
./fetch <url>...
```

## Design policies

- Separate classes for each responsibilities
  - `fetch` is an entrypoint and is for module orchestration
  - modules
    - `lib/argv_parser` is to parse command-line arguments
    - `lib/file_system` is for file I/O and path normalization
    - `lib/http_client` is a thin wrapper for networking
    - `lib/metadata_reader` can read metadata from files
- Do not use 3rd party gems as much as possible
- Use `raise` without custom errors for developer issues
- Use custom errors when a problem may be propagated across modules.

## TODOs

See the code comments.