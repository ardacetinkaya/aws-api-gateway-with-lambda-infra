#!/usr/bin/env bash

set -e -u -o pipefail
[ "${DEBUG:-0}" = "1" ] && set -x # set DEBUG=1 to enable tracing
VERSION="0.1"
# ---------------------------------------------------------------------------------------- #
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ENVIRONMENTS_FOLDER=${SCRIPT_DIR}'/environments'
CURRENT_TIMESTAMP=$(date +%s)
CURRENT_DATE_TIME_STAMP=$(date '+%Y-%m-%d %H:%M:%S')
CURRENT_DATE_FOLDER_NAME=$(date '+%Y%m%d')
STATE_FILE_NAME="terraform.tfstate"

# For more colors;
# Check: https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
CLEAR_COLOR='\033[0m'

_commandIsSet=false
_environmentIsSet=false
_planFilePath=""
_planFileName=""
_timeStamp="NO"
_noChanges=false
_startLine=0
_endLine=0
_stateFileStorageName=""
_region=""

echoDefault() {
    echo -e "${CLEAR_COLOR}$@${CLEAR_COLOR}"
}

echoMessage() {
    echo -e "${WHITE}$@${CLEAR_COLOR}"
}

echoWarning() {
    echo -e "${YELLOW}$@${CLEAR_COLOR}"
}

echoError() {
    echo -e "${RED}$@${CLEAR_COLOR}"
}

echoResourceCreate() {
    echo -e "${GREEN}$@${CLEAR_COLOR}"
}

echoResourceModification() {
    echo -e "${YELLOW}$@${CLEAR_COLOR}"
}

echoResourceRemove() {
    echo -e "${RED}$@${CLEAR_COLOR}"
}

echoResourceReCreate() {
    echo -e "${CYAN}$@${CLEAR_COLOR}"
}

help() {
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

    COUNT=0
    while IFS= read -r line; do
        COUNT=$(($COUNT + 1))
        [[ $line == *"+ resource "* ]] && {
            resourceCreations+=${line% *}"\n"
            continue
        }
        [[ $line == *"~ resource "* ]] && {
            resourceChanges+=${line% *}"\n"
            continue
        }
        [[ $line == "- resource "* ]] && {
            resourceDestroys+=${line% *}"\n"
            continue
        }
        [[ $line == "+/- resource "* ]] && {
            resourceDropCreates+=${line% *}"\n"
            continue
        }

        [[ $line == *"Terraform will perform the following actions"* ]] && {
            _startLine=$COUNT
            continue
        }

        if [[ $line == *"Plan: "* ]]; then
            _endLine=$COUNT
            planSummary+=($line)
            continue
        elif [[ $line == "No changes. Your infrastructure matches the configuration."* ]]; then
            planSummary=($line)
            _noChanges=true
            continue
        fi
    done <"$1"

    [[ ${#resourceChanges[@]} -gt 0 ]] && echoResourceModification ${resourceChanges[*]}
    [[ ${#resourceCreations[@]} -gt 0 ]] && echoResourceCreate ${resourceCreations[*]}
    [[ ${#resourceDropCreates[@]} -gt 0 ]] && echoResourceReCreate ${resourceDropCreates[*]}
    [[ ${#resourceDestroys[@]} -gt 0 ]] && echoResourceRemove ${resourceDestroys[*]}

    echoMessage "${planSummary[*]}"
}

main() {

    while getopts ":ha:e:Vt:" option; do
        case $option in
        h)
            help
            exit
            ;;
        a)
            _commandIsSet=true
            _command=$OPTARG
            ;;
        e)
            _environmentIsSet=true
            _environment=$OPTARG
            ;;
        t) _timeStamp=$OPTARG ;;
        V)
            echoDefault "$(basename $BASH_SOURCE) v${VERSION}"
            terraform --version
            exit
            ;;
        \?)
            echoError "Error: Invalid option"
            help
            exit
            ;;
        esac
    done

    if [[ $_commandIsSet == false || $_environmentIsSet == false ]]; then
        echoError "Error: Invalid options value"
        help
        exit -999
    fi

    ENVIRONMENT_FOLDER=${ENVIRONMENTS_FOLDER}'/'${_environment}
    ENVIRONMENT_RESOURCES_FOLDER=${ENVIRONMENT_FOLDER}'/resources'
    PLANS_FOLDER_PATH=${ENVIRONMENT_FOLDER}'/_plans'
    TEMP_FOLDER_PATH=${ENVIRONMENT_FOLDER}'/_temps'
    OUTPUTS_FOLDER_PATH=${ENVIRONMENT_FOLDER}'/_outputs'

    TFVAR_FILE_PATH=${ENVIRONMENT_RESOURCES_FOLDER}'/terraform.tfvars'
    SENSITIVE_TFVAR_FILE_PATH=${ENVIRONMENT_RESOURCES_FOLDER}'/sensitive.auto.tfvars'

    while IFS= read -r line; do
        [[ $line == "state_file_s3_bucket"* ]] && {
            stateFileLine=(${line//=/ })
            _stateFileStorageName="${stateFileLine[1]//\"/}"
            continue
        }
        [[ $line == "region"* ]] && {
            regionLine=(${line//=/ })
            _region="${regionLine[1]//\"/}"
            continue
        }

    done <$TFVAR_FILE_PATH

    case $_command in
    init) ;;

    plan)
        _planFileName="${_environment}-${_command}-${CURRENT_TIMESTAMP}.tfplan"
        ;;
    apply)
        [ "${_timeStamp}" == "NO" ] && {
            echoError "Invalid timestamp for ${_command}"
            exit -999
        }
        _planFileName="${_environment}-plan-${_timeStamp}.tfplan"
        ;;
    validate | destroy) ;;

    *)
        echoError "Invalid action."
        exit -900
        ;;
    esac

    _outputFileName="${_environment}-${_command}-${CURRENT_TIMESTAMP}.log"

    if [[ ! -d ${ENVIRONMENT_FOLDER} ]]; then
        echoError "Directory ${PLANS_FOLDER_PATH} DOES NOT exists. Please create environment folder."
        exit -990
    fi

    [[ ! -d ${PLANS_FOLDER_PATH} ]] && {
        mkdir ${PLANS_FOLDER_PATH}
        echoMessage "${PLANS_FOLDER_PATH} is created."
    }

    [[ ! -d ${TEMP_FOLDER_PATH} ]] && {
        mkdir ${TEMP_FOLDER_PATH}
        echoMessage "${TEMP_FOLDER_PATH} is created."
    }

    [[ ! -d ${OUTPUTS_FOLDER_PATH} ]] && {
        mkdir ${OUTPUTS_FOLDER_PATH}
        echoMessage "${OUTPUTS_FOLDER_PATH} is created."
    }

    [[ ! -d ${OUTPUTS_FOLDER_PATH}/${CURRENT_DATE_FOLDER_NAME} ]] && {
        mkdir ${OUTPUTS_FOLDER_PATH}/${CURRENT_DATE_FOLDER_NAME}
        echoMessage "${OUTPUTS_FOLDER_PATH}/${CURRENT_DATE_FOLDER_NAME} is created."
    }

    OUTPUTS_FOLDER_PATH="${OUTPUTS_FOLDER_PATH}/${CURRENT_DATE_FOLDER_NAME}"

    _outputFilePath="${OUTPUTS_FOLDER_PATH}/${_outputFileName}"
    _planFilePath="${PLANS_FOLDER_PATH}/${_planFileName}"

    echoDefault "Started... [${CURRENT_DATE_TIME_STAMP}]"

    if [[ "${_command}" == 'init' ]]; then
        set +e
        terraform -chdir=${ENVIRONMENT_RESOURCES_FOLDER} init -upgrade=true -no-color -force-copy \
            -backend-config bucket="${_stateFileStorageName}" \
            -backend-config region="${_region}" \
            -backend-config key=${STATE_FILE_NAME} >$_outputFilePath

    elif [[ "${_command}" == 'plan' ]]; then
        set +e
        terraform -chdir=${ENVIRONMENT_RESOURCES_FOLDER} plan -parallelism=20 \
            -no-color \
            -refresh=true \
            -var-file=${TFVAR_FILE_PATH} \
            -out=${_planFilePath} >${_outputFilePath} 2>&1

        exitcode=$?
        briefOutput ${_outputFilePath}
        if [[ $exitcode -eq 0 ]]; then
            if [[ $_startLine -gt 0 ]]; then
                _startLine=$(($_startLine - 1))
                _endLine=$(($_endLine - 1))
                head -$_endLine ${_outputFilePath} | tail -n $(($_endLine - $_startLine))
            fi
        else
            echoError "$(<${_outputFilePath})"
            exit $exitcode
        fi

    elif [[ "${_command}" == 'apply' ]]; then

        aws s3 cp s3://${_stateFileStorageName}/${_planFileName} ${PLANS_FOLDER_PATH}/

        set +e
        terraform -chdir="${ENVIRONMENT_RESOURCES_FOLDER}" apply -parallelism=2 \
            ${_planFilePath} \
            -no-color >${_outputFilePath}

    elif [[ "${_command}" == 'validate' ]]; then
        set +e
        terraform -chdir="${ENVIRONMENT_RESOURCES_FOLDER}" validate -no-color
    elif [[ "${_command}" == 'destroy' ]]; then
        set +e
        terraform -chdir="${ENVIRONMENT_RESOURCES_FOLDER}" destroy -no-color -refresh=true -auto-approve \
            -var-file=${TFVAR_FILE_PATH} >${_outputFilePath}

    fi

    echoDefault "------------------------------------------------------------------------------"
    echoDefault "Log: ${_outputFilePath}"
    echoDefault "------------------------------------------------------------------------------"
    echoDefault "Finished.  [$(date '+%Y-%m-%d %H:%M:%S')]"

    if [[ "${_command}" == "plan" && $_noChanges == false ]]; then
        echoDefault "------------------------------------------------------------------------------"
        echoDefault ""
        echoDefault "Please check plan output. If plan is correct, apply it;"
        echoDefault ""
        echoDefault "       ./provision.sh -a apply -e ${_environment} -t ${CURRENT_TIMESTAMP}"
        echoDefault ""
        echoDefault "------------------------------------------------------------------------------"

        aws s3 cp ${_planFilePath} s3://${_stateFileStorageName}/

    fi

}

main "$@"
