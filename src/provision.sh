
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

START_LINE=0
END_LINE=0

briefOutput() {
    planSummary=""
    resourceCreations=()
    resourceChanges=()
    resourceDestroys=()
    resourceDropCreates=()

    COUNT=0
    while IFS= read -r line
    do
        COUNT=$(($COUNT+1))
        [[ $line == *"+ resource "* ]] && { resourceCreations+=${line% *}"\n"; continue; }
        [[ $line == *"~ resource "* ]] && { resourceChanges+=${line% *}"\n"; continue; }
        [[ $line == "- resource "* ]] && {  resourceDestroys+=${line% *}"\n"; continue; }
        [[ $line == "+/- resource "* ]] && { resourceDropCreates+=${line% *}"\n"; continue; }
        
        [[ $line == *"Terraform will perform the following actions"* ]] && { START_LINE=$COUNT; continue; }

        if [[ $line == *"Plan: "* ]]
        then
            END_LINE=$COUNT
            planSummary+=($line)
            continue;
        elif [[ $line == "No changes. Your infrastructure matches the configuration."* ]]
        then
            planSummary=($line)
            _noChanges=true
            continue;
        fi
    done < "$1"
    

    [ ${#resourceChanges[@]} -gt 0 ] && echoResourceModification ${resourceChanges[*]}
    [ ${#resourceCreations[@]} -gt 0 ] && echoResourceCreate ${resourceCreations[*]}
    [ ${#resourceDropCreates[@]} -gt 0 ] && echoResourceReCreate ${resourceDropCreates[*]}
    [ ${#resourceDestroys[@]} -gt 0 ] && echoResourceRemove ${resourceDestroys[*]}
    
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
    [[ $line == "state_file_s3_bucket"* ]] && { stateFileLine=(${line//=/ }); STATE_FILE_STORAGE_NAME="${stateFileLine[1]//\"/}"; continue; }
    [[ $line == "region"* ]] && { regionLine=(${line//=/ }); REGION="${regionLine[1]//\"/}"; continue; }
  
done < $TFVAR_FILE_PATH

# if [ -z "${STATE_FILE_STORAGE_NAME}" ]
# then
#     if [ -z ${ENV_STATE_FILE_STORAGE_NAME+x} ]
#     then 
#         echoError "Invalid ENV value [StorageName]"; 
#     else 
#         STATE_FILE_STORAGE_NAME=$ENV_STATE_FILE_STORAGE_NAME
#     fi
# fi

# if [ -z "${REGION}" ]
# then
#     if [ -z ${ENV_AWS_REGION+x} ]
#     then 
#         echoError "Invalid ENV value [Region]"; 
#     else 
#         REGION=$ENV_AWS_REGION
#     fi
# fi


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
    set +e
    terraform -chdir=${ENVIRONMENT_RESOURCES_FOLDER} init -upgrade=true -no-color -force-copy \
        -backend-config bucket="${STATE_FILE_STORAGE_NAME}" \
        -backend-config region="${REGION}" \
        -backend-config key=${STATE_FILE_NAME} > $_outputFilePath

elif [ "${_command}" == 'plan' ]
then
    set +e
    terraform -chdir=${ENVIRONMENT_RESOURCES_FOLDER} plan -parallelism=20 \
        -no-color \
        -refresh=true \
        -var-file=${TFVAR_FILE_PATH} \
        -out=${_planFilePath} > ${_outputFilePath} 2>&1
    
    exitcode=$?
    briefOutput ${_outputFilePath}
    if [[ $exitcode -eq 0 ]]; then
        echo '::set-output name=planHasChanges::true'
        if [[ $START_LINE -gt 0 ]]; then
            START_LINE=$(($START_LINE-1))
            END_LINE=$(($END_LINE-1))
            head -$END_LINE ${_outputFilePath} | tail -n $(($END_LINE-$START_LINE))
        fi
    else
        echoError "$(<${_outputFilePath})"
        exit $exitcode
    fi
    
    
elif [ "${_command}" == 'apply' ]
then
    aws s3 cp s3://${STATE_FILE_STORAGE_NAME}/${_planFileName} ${PLANS_FOLDER_PATH}/

    set +e
    terraform -chdir="${ENVIRONMENT_RESOURCES_FOLDER}" apply -parallelism=2 \
        ${_planFilePath} \
        -no-color > ${_outputFilePath}

elif [ "${_command}" == 'validate' ]
then
    set +e
    terraform -chdir="${ENVIRONMENT_RESOURCES_FOLDER}" validate -no-color
elif [ "${_command}" == 'destroy' ]
then
    set +e
    terraform -chdir="${ENVIRONMENT_RESOURCES_FOLDER}" destroy -no-color \
        -refresh=true \
        -var-file="$tfResourcesVarFilePath" \
        -var-file="$tfResourcesSensitiveVarFilePath" \
        -auto-approve > ${_outputFilePath}
fi

echoDefault "------------------------------------------------------------------------------"
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

    aws s3 cp ${_planFilePath} s3://${STATE_FILE_STORAGE_NAME}/

fi
