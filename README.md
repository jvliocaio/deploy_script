# A bash script to do deploys
This script was designed for an architectural model, but because its structure is made up of functions, it is easily adaptable to almost any environment. I chose to do it this way so that in the future it would be easier and more practical to change and maintain.

Now a brief explanation about each functionality (the code is also commented). The only external commands inside the script are from Docker and Aws

##### To show all options 
```
$ ./script_deply --help
```
##### The message will be this

```
 $ script_deploy.sh - [MENU]

  -------------------------------------------------------
  | INFOS:                                              |
  |    --help : Help Menu                               |
  |    --about : Version && Maintener                   |
  -------------------------------------------------------
  -------------------------------------------------------
  | USAGE (hml/prod):                                   |
  |    service:0.0.0:tenant                             |
  -------------------------------------------------------
  | FUNCTIONS:                                          |
  |    --hml : Run in hml                               |
  |    --prod : Run in prod                             |
  |    --show-all : Show all services                   |
  |    --add-line : Add line in the .env                |
  -------------------------------------------------------
```

##### To run a deploy 
```
$ ./script_deply --hml || prod
```
##### The message will be this

```
$ You are running on HOMOLOGATION || PRODUCTION
Keep running?(y/N)
```
If your answer is y/Y, the next message will be

```
$ Enter the services and their respective versions:  
```
Here you need pass the service, version and tenant schema like this "version:0.1.0:tenant"

After passing the information, just press Enter and wait for the deploy to finish.
