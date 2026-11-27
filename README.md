# Instructions

0. Be running a docker daemon.
1. `./build-image.sh`
2. Put something like this in your bashrc:
  ```bash
  function pi() {
    VOLUMES=()
    VOLUMES+=(-v pi-agent-home:/root/.pi/agent)
    VOLUMES+=(-v pi-jj-config:/root/.config/jj)
    VOLUMES+=(-v "$PWD:/workspace")
    for D in $(\ls -d .direnv .git .jj .envrc 2> /dev/null); do
      VOLUMES+=(-v "${PWD}/${D}:/workspace/${D}:ro");
    done
    docker run --rm -it "${VOLUMES[@]}" pi-sandbox:latest "$@"
  }
  ```
3. Run `pi` inside some directory and it will probably not be able to do anything nefarious.
