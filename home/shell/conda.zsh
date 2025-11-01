#!/bin/zsh
# =====================================================
# Conda Configuration
# =====================================================

# Detect conda installation location
CONDA_PATH=""
if [[ -f "/opt/miniconda3/bin/conda" ]]; then
    CONDA_PATH="/opt/miniconda3"
elif [[ -f "${HOME}/miniconda3/bin/conda" ]]; then
    CONDA_PATH="${HOME}/miniconda3"
fi

# Conda initialization
if [[ -n "${CONDA_PATH}" ]]; then
    __conda_setup="$("${CONDA_PATH}/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
    if [[ $? -eq 0 ]]; then
        eval "${__conda_setup}"
    else
        if [[ -f "${CONDA_PATH}/etc/profile.d/conda.sh" ]]; then
            source "${CONDA_PATH}/etc/profile.d/conda.sh"
        else
            export PATH="${CONDA_PATH}/bin:${PATH}"
        fi
    fi
    unset __conda_setup

    # Cryptography fix for conda
    export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
fi

unset CONDA_PATH
