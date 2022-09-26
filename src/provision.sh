
#!/usr/bin/env bash

set -e -u -o pipefail
[ "${DEBUG:-0}" = "1" ] && set -x       # set DEBUG=1 to enable tracing
VERSION="0.1"
# ---------------------------------------------------------------------------------------- #
echoDefault() {
    echo -e "${_terminalColorClear}$1${_terminalColorClear}"
}
 
echoMessage() {
    echo -e "${_terminalColorMessage}$1${_terminalColorClear}"
}
 
echoWarning() {
    echo -e "${_terminalColorWarning}$1${_terminalColorClear}"
}
 
echoError() {
    echo -e "${_terminalColorError}$1${_terminalColorClear}"
}

help()
{
   echo "Add description of the script functions here."
   echo
   echo "Syntax: ./provision.sh [-a|h|e|V]"
   echo ""
   echo "Option     Description"
   echo " -a        Action for provisioning. init|plan|apply|destroy|validate"
   echo " -e        Provisioning environment."
   echo " -h        Print help."
   echo " -V        Print software version and exit."
   echo ""
   echo "Example:"
   echo "   ./provision.sh -a plan -e test"
   echo ""
}

briefOutput() {
    planSummaryLine=""
    resourceCreations=()
    resourceChanges=()
    resourceDestroys=()
    resourceDropCreates=()

    while IFS= read -r line
    do
        [[ $line == *"+ resource" ]] && { resourceCreations+=${line% *}; continue; }
        [[ $line == *"~ resource"* ]] && { resourceChanges+=${line% *}; continue; }
        [[ $line == *"- resource"* ]] && { resourceDestroys+=${line% *}; continue; }
        [[ $line == *"-/+ resource"* ]] && { resourceDropCreates+=${line% *}; continue; }
        
        if [[ $line == *"Plan: "* ]]
        then
            planSummaryLine+=($line)
            continue;
        elif [[ $line == "No changes. Infrastructure is up-to-date."* ]]
        then
            planSummaryLine=($line)
            continue;
        fi
    done < "$1"

    resourceCreationsCount=${#resourceCreations[@]}
    resourceDestroysCount=${#resourceDestroys[@]}
    resourceDropCreatesCount=${#resourceDropCreates[@]}
    resourceChangesCount=${#resourceChanges[@]}

    [ "$resourceChangesCount" -gt 0 ] && echo ${resourceChanges[*]}
    [ "$resourceCreationsCount" -gt 0 ] && echo ${resourceCreations[*]}
    [ "$resourceDropCreatesCount" -gt 0 ] && echo ${resourceDropCreates[*]}
    [ "$resourceDestroysCount" -gt 0 ] && echo ${resourceDestroys[*]}
    
    echoMessage "${planSummaryLine[*]}"

}

_terminalColorClear='\033[0m'
_terminalColorError='\033[1;31m'
_terminalColorMessage='\033[1;33m'
_terminalColorWarning='\033[1;34m'

_commandIsSet=false
_environmentIsSet=false
_planFilePath=""
_planFileName=""
_timeStamp="NO"

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
TFVAR_FILEPATH=${ENVIRONMENT_RESOURCES_FOLDER}'/terraform.tfvars'
SENSITIVE_TFVAR_FILE_PATH=${ENVIRONMENT_RESOURCES_FOLDER}'/sensitive.auto.tfvars'
PLANS_FOLDER_PATH=${ENVIRONMENT_FOLDER}'/plans'
TEMP_FOLDER_PATH=${ENVIRONMENT_FOLDER}'/temps'
OUTPUTS_FOLDER_PATH=${ENVIRONMENT_FOLDER}'/outputs'
STATE_FILE_NAME="terraform.tfstate"


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

_outputKeyFileName="${_environment}-${_command}-${CURRENT_TIMESTAMP}.log"

if [ ! -d ${ENVIRONMENT_FOLDER} ] 
then
    echoError "Directory ${PLANS_FOLDER_PATH} DOES NOT exists. Please create environment folder."
    exit -990
fi

if [ ! -d ${PLANS_FOLDER_PATH} ] 
then
    mkdir ${PLANS_FOLDER_PATH}
    echoMessage "${PLANS_FOLDER_PATH} is created."
fi

if [ ! -d ${TEMP_FOLDER_PATH} ] 
then
    mkdir ${TEMP_FOLDER_PATH}
    echoMessage "${TEMP_FOLDER_PATH} is created."
fi

if [ ! -d ${OUTPUTS_FOLDER_PATH} ] 
then
    mkdir ${OUTPUTS_FOLDER_PATH}
    echoMessage "${OUTPUTS_FOLDER_PATH} is created."
fi

if [ ! -d "${OUTPUTS_FOLDER_PATH}/${CURRENT_DATE_FOLDER_NAME}" ] 
then
    mkdir "${OUTPUTS_FOLDER_PATH}/${CURRENT_DATE_FOLDER_NAME}"
    echoMessage "${OUTPUTS_FOLDER_PATH}/${CURRENT_DATE_FOLDER_NAME} is created."
fi


OUTPUTS_FOLDER_PATH="${OUTPUTS_FOLDER_PATH}/${CURRENT_DATE_FOLDER_NAME}"

_outputFilePath="${OUTPUTS_FOLDER_PATH}/${_outputKeyFileName}"
_planFilePath="${PLANS_FOLDER_PATH}/${_planFileName}"

echoDefault "Started... [${CURRENT_DATE_TIME_STAMP}]"

if [ "${_command}" == 'init' ]
then
    terraform -chdir=${ENVIRONMENT_RESOURCES_FOLDER} init -upgrade=true -no-color \
        -backend-config key=${STATE_FILE_NAME} > $_outputFilePath

elif [ "${_command}" == 'plan' ]
then
    terraform -chdir=${ENVIRONMENT_RESOURCES_FOLDER} plan -parallelism=20 \
        -no-color \
        -refresh=true \
        -var-file=${TFVAR_FILEPATH} \
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

if [ "${_command}" == "plan" ]
then
    echoDefault "------------------------------------------------------------------------------"
    echoDefault ""
    echoDefault "Please check plan output. If plan is correct, apply it;"
    echoDefault ""
    echoDefault "       ./provision.sh -a apply -e ${_environment} -t ${CURRENT_TIMESTAMP}"
    echoDefault ""
    echoDefault "------------------------------------------------------------------------------"
fi