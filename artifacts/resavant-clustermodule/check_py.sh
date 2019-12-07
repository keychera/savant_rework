# check python command
if [ -x "$(command -v python)" ]
then
    PY_COMMAND=python
elif [ -x "$(command -v python3)" ]
then
    PY_COMMAND=python3
else
    echo 'Error: python is either not installed' >&2
    echo 'or the command to call python is not' >&2
    echo '`python` or `python3`' >&2
    exit 1
fi