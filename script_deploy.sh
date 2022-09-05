#!/usr/bin/env bash

## Variables -----------------------------------

diff=("service")
all_services=("service1" "service2")
version="0.1.0"
maintener="Jvlio Ouverney"
use_message="
  $(basename $0) - [MENU]

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
"

## mistake proof

## This function is used to define in which environment 
## you will run the script and also to avoid errors,
decision(){
dec_choice=$1
if [[ "$dec_choice" = "prod" ]]; then
  echo -e "\e[1;31mYou are running in PRODUCTION\e[0m"
  read -p "Keep running?(y/N) " choice
  if [[ "$choice" != Y ]] && [[ "$choice" != y ]]; then
    exit
  fi
  runDeploy
fi

if [[ "$dec_choice" = "hml" ]]; then
  echo -e "\e[1;33mYou are running on HOMOLOGATION\e[0m"
  read -p "Keep running?(y/N) " choice
  if [[ "$choice" != Y ]] && [[ "$choice" != y ]]; then
    exit
  fi
  runDeploy
fi
}

## Here the service repositories are updated

updateRepos(){
  echo -e "\e[34mUpdating $repo\e[0m"
	cd ~/$repo && git pull
		if [[ $? == 0 ]]; then
			echo -e "\e[32m$repo updated\e[0m"
    else
      echo -e "\e[31m$repo update error\e[0m"
      exit 1
		fi
}

## Here the packages repositories are updated, these packages are proprietary
updatePackages(){
packages=("proprietary_pckg" "proprietary_pckg" "proprietary_pckg")

for pack in ${packages[@]}; do
  echo -e "\e[34mUpdating $pack\e[0m"
  cd ~/$pack && git pull
    if [[ $? == 0 ]]; then
      echo -e "\e[32m$pack updated\e[0m"
    else
      echo -e "\e[31m$pack update error\e[0m"
      exit 1
    fi
done
}

## Here the service version via .env is modified
modifyEnv(){
echo -e "\e[34mModifying .env: $arg\e[0m"
sed -i 's/\bAPP_VERSION=["]\?[0-9]*.[0-9]*.[0-9]*[.]\?[a-z]*["]\?/APP_VERSION="'$version'"/g' ~/$repo/docker-compose/envs/full.$dec_choice.env  
}

## This is the function where all the deployment is done
## copying the files, change the Dockerfile, up the container, login at the AWS

runScript(){
dc_path=~/$repo/docker-compose/
choix=$(echo $version | cut -c1-8)

  echo -e "\e[34mRunning deploy script\e[0m"

docker stop $repo
docker rm $repo

touch $dc_path'proprietary_pckg'
touch $dc_path'proprietary_pckg'
touch $dc_path'laravel'

rm -Rf $dc_path'proprietary_pckg' $dc_path'laravel' $dc_path'proprietary_pckg'

if [[ "$repo" = *"$diff"* ]]; then

  touch $dc_path'proprietary_pckg'

  rm -Rf $dc_path'proprietary_pckg'

  cp -Rp ~/proprietary_pckg $dc_path

fi

cp -Rp ~/$repo/laravel $dc_path
cp -Rp ~/proprietary_pckg $dc_path
cp -Rp ~/proprietary_pckg  $dc_path

cp $dc_path'envs'/full.$dec_choice.env $dc_path'laravel'/.env
cp $dc_path/manifests/$dec_choice.Dockerfile $dc_path'Dockerfile'
cp $dc_path'composer_files'/$dec_choice.composer.json $dc_path'laravel'/composer.json

chmod a-x $dc_path'Dockerfile'


if [[ "$dec_choice" = "prod" ]]; then

docker build -t amazonaws.com/enterprise_name-$repo:$choix $dc_path
aws ecr get-login-password --region region | docker login --username AWS --password-stdin amazonaws.com
docker push amazonaws.com/enterprise_name-$repo:$choix

fi

if [[ "$dec_choice" = "hml" ]]; then

docker build -t enterprise-$repo $dc_path
docker run -d --name $repo --rm --network enterprise enterprise-$repo

fi
}

## The laravel migration run here
runMigration(){
tenant=$(echo $arg | cut -f3 -d :)

  echo -e "\e[34mRunning migration\e[0m"
  docker exec -it $repo php artisan migrate
  
}

## This is the primary function, she call all the other function in a order
## The "for" is used because you can run this script for multiple services, in the --help u can see how
runDeploy(){

read -p "Enter the services and their respective versions: " repos
echo -e "The selected services were: " "\e[34m$repos\e[0m"

updatePackages

for arg in ${repos[@]}; do
repo=$(echo $arg | cut -f1 -d :)
version=$(echo $arg | cut -f2 -d :)

updateRepos
sleep 2
modifyEnv
sleep 2
runScript
sleep 2
runMigration

done

if [[ $? == 0 ]]; then
echo -e "\e[32mExecution successfully completed\e[0m"
else
 echo -e "\e[31mExecution completed with errors\e[0m"
fi
}

## A simple function to add lines in the .env
## first u pass the service and the environment and after u pass the lines
addLine(){
read -p "Enter the service and the environment (splitted by like'service:hml'): " environment
read -p "Enter the lines you want to add to .env (splitted by space): " text

repo=$(echo $environment | cut -f1 -d :)
amb=$(echo $environment | cut -f2 -d :)

for line in ${text[@]}; do
  echo $line ~/$repo/docker-compose/envs/full.$amb.env
done

}

## Here is the possible options to use this script
case "$1" in
    --help) echo "$use_message" && exit 0                 ;;
    --about) echo "$version - $maintener" && exit 0       ;;
    '') echo "Arguments missing, see --help." && exit 1   ;;
    --hml) decision hml                                   ;;
    --prod) decision prod                                 ;;
    --add-line) addLine                                   ;;
    --show-all) echo $all_services                        ;;
    *) echo "Unexistent option, see --help"               ;;
esac

