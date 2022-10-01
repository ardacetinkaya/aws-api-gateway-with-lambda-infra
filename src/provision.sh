
#!/usr/bin/env bash

set -e -u -o pipefail
[ "${DEBUG:-0}" = "1" ] && set -x       # set DEBUG=1 to enable tracing
VERSION="0.1"
# ---------------------------------------------------------------------------------------- #

# For more colors;
# Check: https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
Black='\033[0;30m'        
Red='\033[0;31m'          
Green='\033[0;32m'        
Yellow='\033[0;33m'       
# Yellow='\033[41m'
Blue='\033[0;34m'         
Purple='\033[0;35m'       
Cyan='\033[0;36m'         
White='\033[1;37m'        
ClearColor='\033[0m'

_commandIsSet=false
_environmentIsSet=false
_planFilePath=""
_planFileName=""
_timeStamp="NO"
_noChanges=false

echoDefault() {
    echo -e "${ClearColor}$@${ClearColor}"
}
 
echoMessage() {
    echo -e "${White}$@${ClearColor}"
}
 
echoWarning() {
    echo -e "${Yellow}$@${ClearColor}"
}
 
echoError() {
    echo -e "${Red}$@${ClearColor}"
}

echoResourceCreate() {
    echo -e "${Green}$@${ClearColor}"
}
 
echoResourceModification() {
    echo -e "${Yellow}$@${ClearColor}"
}
 
echoResourceRemove() {
    echo -e "${Red}$@${ClearColor}"
}

echoResourceReCreate() {
    echo -e "${Cyan}$@${ClearColor}"
}

help()
{
   echo ""
   echo "Helps to provision your terraform resources."
   echoMessage "Syntax:"
   echo "   ./provision.sh [-a|h|e|V]"
   echo ""
   echoMessage "Option     Description"
   echo " -a        Action for provisioning. init|plan|apply|destroy|validate"
   echo " -e        Provisioning environment."
   echo " -h        Print help."
   echo " -V        Print software version and exit."
   echo ""
   echoMessage "Example:"
   echo "   ./provision.sh -a plan -e test"
   echo ""
}

briefOutput() {
    planSummary=""
    resourceCreations=()
    resourceChanges=()
    resourceDestroys=()
    resourceDropCreates=()

    while IFS= read -r line
    do
        [[ $line == *"+ resource "* ]] && { resourceCreations+=${line% *}"\n"; continue; }
        [[ $line == *"~ resource "* ]] && { resourceChanges+=${line% *}"\n"; continue; }
        [[ $line == *"- resource "* ]] && { resourceDestroys+=${line% *}"\n"; continue; }
        [[ $line == *"-/+ resource "* ]] && { resourceDropCreates+=${line% *}"\n"; continue; }
        
        if [[ $line == *"Plan: "* ]]
        then
            planSummary+=($line)
            continue;
        elif [[ $line == "No changes. Your infrastructure matches the configuration."* ]]
        then
            planSummary=($line)
            _noChanges=true
            continue;
        fi
    done < "$1"
    
    echoMessage ""
    resourceCreationsCount=${#resourceCreations[@]}
    resourceDestroysCount=${#resourceDestroys[@]}
    resourceDropCreatesCount=${#resourceDropCreates[@]}
    resourceChangesCount=${#resourceChanges[@]}

    [ "$resourceChangesCount" -gt 0 ] && echoResourceModification ${resourceChanges[*]}
    [ "$resourceCreationsCount" -gt 0 ] && echoResourceCreate ${resourceCreations[*]}
    [ "$resourceDropCreatesCount" -gt 0 ] && echoResourceReCreate ${resourceDropCreates[*]}
    [ "$resourceDestroysCount" -gt 0 ] && echoResourceRemove ${resourceDestroys[*]}
    
    echoMessage ""
    echoMessage "${planSummary[*]}"

}

while getopts ":ha:e:Vt:" option; do
    case $option in
        h)  help
            exit;;
        a)  _commandIsSet=true
            _command=$OPTARG;;
        e)  _environmentIsSet=true
            _environment=$OPTARG;;
        t)  _timeStamp=$OPTARG;;
        V)  echoDefault "$(basename $BASH_SOURCE) v${VERSION}"
            terraform --version
            exit;;
        \?) echoError "Error: Invalid option"
            help
            exit;;
    esac
done

if [[ $_commandIsSet == false || $_environmentIsSet == false ]]; then
    echoError "Error: Invalid options value"
    help
    exit -999 
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ENVIRONMENTS_FOLDER=${SCRIPT_DIR}'/environments'
CURRENT_TIMESTAMP=$(date +%s)
CURRENT_DATE_TIME_STAMP=$(date '+%Y-%m-%d %H:%M:%S')
CURRENT_DATE_FOLDER_NAME=$(date '+%Y%m%d')

ENVIRONMENT_FOLDER=${ENVIRONMENTS_FOLDER}'/'${_environment} 
ENVIRONMENT_RESOURCES_FOLDER=${ENVIRONMENT_FOLDER}'/resources'
TFVAR_FILE_PATH=${ENVIRONMENT_RESOURCES_FOLDER}'/terraform.tfvars'
SENSITIVE_TFVAR_FILE_PATH=${ENVIRONMENT_RESOURCES_FOLDER}'/sensitive.auto.tfvars'
PLANS_FOLDER_PATH=${ENVIRONMENT_FOLDER}'/_plans'
TEMP_FOLDER_PATH=${ENVIRONMENT_FOLDER}'/_temps'
OUTPUTS_FOLDER_PATH=${ENVIRONMENT_FOLDER}'/_outputs'
STATE_FILE_NAME="terraform.tfstate"

STATE_FILE_STORAGE_NAME=""
REGION=""

while IFS= read -r line
do
  [[ $line == "state_file_s3_bucket" ]] && { STATE_FILE_STORAGE_NAME=(${line//=/ }); continue; }
  [[ $line == "region" ]] && { REGION=(${line//=/ }); continue; }
  
done < $TFVAR_FILE_PATH

case $_command in
  init)
    ;;
  plan)
    _planFileName="${_environment}-${_command}-${CURRENT_TIMESTAMP}.tfplan"
    ;;
  apply | destroy)
     [ "${_timeStamp}" == "NO" ] && { echoError "Invalid timestamp for plan"; exit -999; }
    _planFileName="${_environment}-plan-${_timeStamp}.tfplan"
    ;;
  validate)
    ;;
  *)
    echoError "Invalid action."
    exit -900
    ;;
esac

_outputFileName="${_environment}-${_command}-${CURRENT_TIMESTAMP}.log"

if [ ! -d ${ENVIRONMENT_FOLDER} ] 
then
    echoError "Directory ${PLANS_FOLDER_PATH} DOES NOT exists. Please create environment folder."
    exit -990
fi


[[ ! -d ${PLANS_FOLDER_PATH} ]] && { mkdir ${PLANS_FOLDER_PATH}; echoMessage "${PLANS_FOLDER_PATH} is created."; } 
[[ ! -d ${TEMP_FOLDER_PATH} ]] && { mkdir ${TEMP_FOLDER_PATH}; echoMessage "${TEMP_FOLDER_PATH} is created."; }
[[ ! -d ${OUTPUTS_FOLDER_PATH} ]] && { mkdir ${OUTPUTS_FOLDER_PATH}; echoMessage "${OUTPUTS_FOLDER_PATH} is created."; }
[[ ! -d ${OUTPUTS_FOLDER_PATH}/${CURRENT_DATE_FOLDER_NAME} ]] && { mkdir ${OUTPUTS_FOLDER_PATH}/${CURRENT_DATE_FOLDER_NAME}; echoMessage "${OUTPUTS_FOLDER_PATH}/${CURRENT_DATE_FOLDER_NAME} is created."; }

OUTPUTS_FOLDER_PATH="${OUTPUTS_FOLDER_PATH}/${CURRENT_DATE_FOLDER_NAME}"

_outputFilePath="${OUTPUTS_FOLDER_PATH}/${_outputFileName}"
_planFilePath="${PLANS_FOLDER_PATH}/${_planFileName}"

echoDefault "Started... [${CURRENT_DATE_TIME_STAMP}]"

if [ "${_command}" == 'init' ]
then
    terraform -chdir=${ENVIRONMENT_RESOURCES_FOLDER} init -upgrade=true -no-color -force-copy \
        -backend-config bucket=${STATE_FILE_STORAGE_NAME[1]} \
        -backend-config region=${REGION[1]} \
        -backend-config key=${STATE_FILE_NAME} > $_outputFilePath

elif [ "${_command}" == 'plan' ]
then
    terraform -chdir=${ENVIRONMENT_RESOURCES_FOLDER} plan -parallelism=20 \
        -no-color \
        -refresh=true \
        -var-file=${TFVAR_FILE_PATH} \
        -var-file=${SENSITIVE_TFVAR_FILE_PATH} \
        -out=${_planFilePath} > ${_outputFilePath}
    
    briefOutput ${_outputFilePath}

elif [ "${_command}" == 'apply' ]
then
      terraform -chdir="${ENVIRONMENT_RESOURCES_FOLDER}" apply -parallelism=2 \
        ${_planFilePath} \
        -no-color > ${_outputFilePath}

elif [ "${_command}" == 'validate' ]
then
      terraform -chdir="${ENVIRONMENT_RESOURCES_FOLDER}" validate -no-color
elif [ "${_command}" == 'destroy' ]
then
      terraform -chdir="${ENVIRONMENT_RESOURCES_FOLDER}" destroy -no-color \
        -refresh=true \
        -var-file="$tfResourcesVarFilePath" \
        -var-file="$tfResourcesSensitiveVarFilePath" \
        -auto-approve > ${_outputFilePath}
fi

echoDefault "------------------------------------------------------------------------------"
echoDefault "Plan: ${_planFilePath}"
echoDefault "Log: ${_outputFilePath}"
echoDefault "------------------------------------------------------------------------------"
echoDefault "Finished.  [$(date '+%Y-%m-%d %H:%M:%S')]"

if [[ "${_command}" == "plan" && $_noChanges == false ]]
then
    echoDefault "------------------------------------------------------------------------------"
    echoDefault ""
    echoDefault "Please check plan output. If plan is correct, apply it;"
    echoDefault ""
    echoDefault "       ./provision.sh -a apply -e ${_environment} -t ${CURRENT_TIMESTAMP}"
    echoDefault ""
    echoDefault "------------------------------------------------------------------------------"
fi
