#/bin/bash
case "$1" in
  "login")
    docker login
    ;;
  "clean")
    docker rmi swiftlabs/zoneminder
    docker rmi $(docker images -f dangling=true -q)
    ;;
  "build")
    docker build -t swiftlabs/zoneminder:latest .
    docker tag swiftlabs/zoneminder
    docker push swiftlabs/zoneminder
    ;;
  *)
    echo "login, clean, build"
    exit 1
    ;;
esac
