```bash
# on your machine

docker build . -t fetch:jmatsu
docker run --rm -v $(pwd):/usr/src  -it fetch:jmatsu /bin/bash

# in docker
./fetch <url>...
```