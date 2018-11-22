# A Basic Zoneminder Installation


With great thanks to Zoneminder's docker repo: https://github.com/ZoneMinder/zmdockerfiles

This is a quick change to make Zoneminder suit my needs - a quick installation. 
Among others, the main changes are:

1. Seperate out Zoneminder from the database (MariaDB tools are still installed)
2. Create a docker-compose.yml for easier distribution
3. Simplify the entrypoint script
4. Bake in a moved content directory for use with voulmes or mapping

## TODO:
1. Actually upload the image, and provide a compose file that uses the generated image
2. Properly simplify the startup script
3. Add a letsencrypt certificate (or a hook for a user to load their own)
4. Create a docker-stack.yml

## I just want to run it:
`$ docker-compose up -d app`
Note, that you might want to provide a path for the data volume, so that your default drive dosen't get filled by ZoneMinder doing it's thing. 
https://docs.docker.com/compose/compose-file/#short-syntax-3



## To stop it:
`docker-compose down`


## Using docker swarm:
Change the compose file to use a restart policy instead. 

