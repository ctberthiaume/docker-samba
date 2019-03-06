# samba
Ubuntu 18.04 Samba server

## Build
`docker build -t samba .`

## Usage
The default user is "user", password is "password", share name is "data", and domain is "WORKGROUP". Password, user, and share name can be changed at runtime with environment variables:

* `SAMBA_USER`
* `SAMBA_PASSWORD`
* `SAMBA_SHARE_NAME`

The password can also be supplied in `SAMBA_PASSWORD_FILE` for compatibility with Docker secrets. It is recommended to change the default password in all cases.

Data is written to `/data`. Map any volumes or bind mounts to this location.

Ports 137-139 and 445 should be exposed.

### Examples
Assuming an image has been created called samba.

Using a bind mount
`docker run -itd -p 137-139:137-139 -p 445:445 -v $(pwd):/data samba`

Using a named volume
`docker run -itd -p 137-139:137-139 -p 445:445 -v samba-storage:/data samba`

Using custom user, password, and share names
```
docker run -itd -p 137-139:137-139 -p 445:445 \
    -e SAMBA_USER=picard \
    -e SAMBA_PASSWORD=fourlights \
    -e SAMBA_SHARE_NAME=enterprise \
      samba
```

The shell can be entered as usual using `docker run -it samba bash`.
