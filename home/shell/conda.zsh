#!/bin/zsh
# =====================================================
# Conda Configuration
# =====================================================

# Conda initialization
if [[ -f "/opt/miniconda3/bin/conda" ]]; then
    __conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [[ $? -eq 0 ]]; then
        eval "${__conda_setup}"
    else
        if [[ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]]; then
            source "/opt/miniconda3/etc/profile.d/conda.sh"
        else
            export PATH="/opt/miniconda3/bin:${PATH}"
        fi
    fi
    unset __conda_setup

    # Cryptography fix for conda
    export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
fi
